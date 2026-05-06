-- ~/.config/nvim/plugin/git_diff_qf.lua (or lua/git_diff_qf.lua if using require)
local M = {}

-- Shared setup: get repo root and run git diff against base using ... syntax.
local function get_diff(base)
  local repo_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    vim.notify('Not in a git repository', vim.log.levels.ERROR)
    return nil
  end

  local cmd = string.format('git diff --no-color --unified=0 %s...HEAD', vim.fn.shellescape(base))
  local diff_lines = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify('git diff failed', vim.log.levels.ERROR)
    return nil
  end

  return diff_lines, repo_root
end

local function setup_fugitive_autocmd(base)
  local group = vim.api.nvim_create_augroup('GitDiffQfFugitive', { clear = true })
  vim.api.nvim_create_autocmd('BufWinEnter', {
    group = group,
    pattern = '*',
    callback = function(args)
      -- Only react to jumps initiated from the quickfix list.
      local qf_idx = vim.fn.getqflist({ idx = 0 }).idx
      if qf_idx == 0 then return end

      -- Skip special buffers: quickfix itself, fugitive diffs, help, etc.
      if vim.bo[args.buf].buftype ~= '' then return end
      local bufname = vim.api.nvim_buf_get_name(args.buf)
      if bufname == '' or bufname:match('^fugitive://') then return end

      -- Find the window currently displaying the buffer that just opened.
      -- BufWinEnter fires before the current window has necessarily switched,
      -- so we locate the target window explicitly and switch to it.
      local target_win = nil
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_get_buf(win) == args.buf then
          target_win = win
          break
        end
      end
      if not target_win then return end

      -- Close any existing fugitive diff split so we don't stack them.
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        -- Don't close the window we're about to work in.
        if win ~= target_win then
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          if name:match('^fugitive://') then
            vim.api.nvim_win_close(win, false)
          end
        end
      end

      -- Defer to let BufWinEnter fully settle (quickfix's :cc does some
      -- window juggling that can leave transient state). schedule() puts us
      -- on the main loop after the current event finishes.
      vim.schedule(function()
        -- Re-check the window still exists and still shows our buffer —
        -- the user could have navigated away in the meantime.
        if not vim.api.nvim_win_is_valid(target_win) then return end
        if vim.api.nvim_win_get_buf(target_win) ~= args.buf then return end

        vim.api.nvim_set_current_win(target_win)

        local ok, err = pcall(vim.cmd, 'Gvdiffsplit ' .. base .. '...HEAD')
        if not ok then
          vim.notify('Gvdiffsplit failed: ' .. tostring(err), vim.log.levels.WARN)
          return
        end

        -- After Gvdiffsplit, focus is on the fugitive (left) side.
        -- Move back to the working-copy window, which is now target_win.
        if vim.api.nvim_win_is_valid(target_win) then
          vim.api.nvim_set_current_win(target_win)
        end
      end)
    end,
  })
end

-- Additions/modifications, grouped by hunk.
function M.diff_against_develop()
  local base = 'develop'
  local diff_lines, repo_root = get_diff(base)
  if not diff_lines then return end

  local qf_items = {}
  local current_file = nil

  -- Hunk accumulator. We flush when a new hunk starts or a new file begins.
  local hunk = nil

  local function flush_hunk()
    if hunk and hunk.file and hunk.plus_count > 0 then
      -- Build a compact summary: first changed line + "(+N, -M)" counts.
      -- The first '+' line is usually the most informative anchor; fall back
      -- to the hunk's starting line number if something weird happened.
      local summary
      if hunk.first_plus_text then
        summary = string.format('(+%d -%d) %s',
          hunk.plus_count, hunk.minus_count, hunk.first_plus_text)
      else
        summary = string.format('(+%d -%d)', hunk.plus_count, hunk.minus_count)
      end

      table.insert(qf_items, {
        filename = hunk.file,
        lnum = hunk.first_plus_lnum or hunk.new_start,
        text = summary,
      })
    end
    hunk = nil
  end

  for _, line in ipairs(diff_lines) do
    local file = line:match('^%+%+%+ b/(.+)$')
    if file then
      flush_hunk()
      current_file = repo_root .. '/' .. file
    elseif line:match('^%+%+%+ /dev/null') then
      flush_hunk()
      current_file = nil
    else
      local new_start = line:match('^@@ %-%d+,?%d* %+(%d+),?%d* @@')
      if new_start then
        flush_hunk()
        hunk = {
          file = current_file,
          new_start = tonumber(new_start),
          cursor_lnum = tonumber(new_start),
          plus_count = 0,
          minus_count = 0,
          first_plus_lnum = nil,
          first_plus_text = nil,
        }
      elseif hunk and line:sub(1, 1) == '+' and not line:match('^%+%+%+') then
        local content = line:sub(2)
        if not hunk.first_plus_text then
          -- Capture the first non-blank added line as the anchor, if we can.
          -- A purely whitespace addition gets recorded, but we prefer content.
          hunk.first_plus_lnum = hunk.cursor_lnum
          hunk.first_plus_text = content
        elseif hunk.first_plus_text:match('^%s*$') and not content:match('^%s*$') then
          -- Upgrade from blank anchor to first real content line.
          hunk.first_plus_lnum = hunk.cursor_lnum
          hunk.first_plus_text = content
        end
        hunk.plus_count = hunk.plus_count + 1
        hunk.cursor_lnum = hunk.cursor_lnum + 1
      elseif hunk and line:sub(1, 1) == '-' and not line:match('^%-%-%-') then
        hunk.minus_count = hunk.minus_count + 1
      end
    end
  end
  flush_hunk()

  if #qf_items == 0 then
    vim.notify('No changes against ' .. base, vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, ' ', {
    title = 'git diff ' .. base .. '...HEAD (hunks)',
    items = qf_items,
  })
  setup_fugitive_autocmd(base)
  vim.cmd('copen')
end

-- Pure deletions — one entry per deletion hunk rather than per deleted line.
function M.diff_deletions_against_develop()
  local base = 'develop'
  local diff_lines, repo_root = get_diff(base)
  if not diff_lines then return end

  vim.fn.setqflist({}, 'r')

  local qf_items = {}
  local current_file = nil
  local hunk = nil

  local function flush_hunk()
    if hunk and hunk.file and hunk.minus_count > 0 and hunk.plus_count == 0 then
      local target_lnum = math.max(hunk.new_start or 1, 1)
      local summary = string.format('[deleted %d line%s] %s',
        hunk.minus_count,
        hunk.minus_count == 1 and '' or 's',
        hunk.first_minus_text or '')
      table.insert(qf_items, {
        filename = hunk.file,
        lnum = target_lnum,
        text = summary,
      })
    end
    hunk = nil
  end

  for _, line in ipairs(diff_lines) do
    local file = line:match('^%+%+%+ b/(.+)$')
    if file then
      flush_hunk()
      current_file = repo_root .. '/' .. file
    elseif line:match('^%+%+%+ /dev/null') then
      flush_hunk()
      local old_file = line:match('^%-%-%- a/(.+)$')
      current_file = old_file and (repo_root .. '/' .. old_file) or nil
    else
      local new_start = line:match('^@@ %-%d+,?%d* %+(%d+),?%d* @@')
      if new_start then
        flush_hunk()
        hunk = {
          file = current_file,
          new_start = tonumber(new_start),
          plus_count = 0,
          minus_count = 0,
          first_minus_text = nil,
        }
      elseif hunk and line:sub(1, 1) == '-' and not line:match('^%-%-%-') then
        local content = line:sub(2)
        if not hunk.first_minus_text or (hunk.first_minus_text:match('^%s*$') and not content:match('^%s*$')) then
          hunk.first_minus_text = content
        end
        hunk.minus_count = hunk.minus_count + 1
      elseif hunk and line:sub(1, 1) == '+' and not line:match('^%+%+%+') then
        hunk.plus_count = hunk.plus_count + 1
      end
    end
  end
  flush_hunk()

  if #qf_items == 0 then
    vim.notify('No pure deletions against ' .. base, vim.log.levels.INFO)
    return
  end

  vim.fn.setqflist({}, ' ', {
    title = 'git diff ' .. base .. '...HEAD (deletion hunks)',
    items = qf_items,
  })
  setup_fugitive_autocmd(base)
  vim.cmd('copen')
end

-------------------------------------------------------------------------------
-- PR Mode (unchanged from previous iteration)
-------------------------------------------------------------------------------

vim.g.pr_mode_active = false

local saved_maps = {}

local function save_and_map(mode, lhs, rhs, desc)
  local existing = vim.fn.maparg(lhs, mode, false, true)
  if existing and vim.tbl_count(existing) > 0 then
    saved_maps[mode .. lhs] = existing
  end
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

local function restore_maps()
  for key, mapping in pairs(saved_maps) do
    local mode = key:sub(1, 1)
    pcall(vim.fn.mapset, mode, false, mapping)
    saved_maps[key] = nil
  end
end

local function unmap(mode, lhs)
  if not saved_maps[mode .. lhs] then
    pcall(vim.keymap.del, mode, lhs)
  end
end

local function qf_cycle_next()
  local qf = vim.fn.getqflist({ size = 0, idx = 0 })
  if qf.size == 0 then
    vim.notify('Quickfix list is empty', vim.log.levels.WARN)
    return
  end
  if qf.idx >= qf.size then
    vim.cmd('cfirst')
  else
    vim.cmd('cnext')
  end
  vim.cmd('normal! z.')
end

local function qf_cycle_prev()
  local qf = vim.fn.getqflist({ size = 0, idx = 0 })
  if qf.size == 0 then
    vim.notify('Quickfix list is empty', vim.log.levels.WARN)
    return
  end
  if qf.idx <= 1 then
    vim.cmd('clast')
  else
    vim.cmd('cprev')
  end
  vim.cmd('normal! z.')
end

function M.pr_mode_start()
  if vim.g.pr_mode_active then
    vim.notify('PR mode already active', vim.log.levels.INFO)
    return
  end

  M.diff_against_develop()

  save_and_map('n', ']c', qf_cycle_next, 'PR: next change')
  save_and_map('n', '[c', qf_cycle_prev, 'PR: previous change')
  save_and_map('n', '<leader>pq', M.pr_mode_stop, 'PR: quit PR mode')
  save_and_map('n', '<leader>pa', M.diff_against_develop, 'PR: show additions')
  save_and_map('n', '<leader>pd', M.diff_deletions_against_develop, 'PR: show deletions')

  vim.g.pr_mode_active = true
  vim.cmd('redrawstatus')
  vim.notify('PR mode: ]c/[c cycle, <leader>pa/pd swap lists, <leader>pq to quit', vim.log.levels.INFO)
end

function M.pr_mode_stop()
  if not vim.g.pr_mode_active then return end

  unmap('n', ']c')
  unmap('n', '[c')
  unmap('n', '<leader>pq')
  unmap('n', '<leader>pa')
  unmap('n', '<leader>pd')
  restore_maps()

  pcall(vim.api.nvim_del_augroup_by_name, 'GitDiffQfFugitive')

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match('^fugitive://') then
      vim.api.nvim_win_close(win, false)
    end
  end
  vim.cmd('cclose')

  vim.g.pr_mode_active = false
  vim.cmd('redrawstatus')
  vim.notify('PR mode: off', vim.log.levels.INFO)
end

function M.pr_mode_toggle()
  if vim.g.pr_mode_active then
    M.pr_mode_stop()
  else
    M.pr_mode_start()
  end
end

function M.statusline()
  return vim.g.pr_mode_active and '[PR]' or ''
end

local orig_statusline = vim.o.statusline
vim.api.nvim_create_autocmd('User', {
  pattern = 'PRModeChanged',
  callback = function()
    if vim.g.pr_mode_active then
      vim.o.statusline = '%#WarningMsg#[PR]%* ' .. (orig_statusline ~= '' and orig_statusline or '%f %m%r%=%l,%c %P')
    else
      vim.o.statusline = orig_statusline
    end
  end,
})

local _start = M.pr_mode_start
M.pr_mode_start = function()
  _start()
  vim.api.nvim_exec_autocmds('User', { pattern = 'PRModeChanged' })
end
local _stop = M.pr_mode_stop
M.pr_mode_stop = function()
  _stop()
  vim.api.nvim_exec_autocmds('User', { pattern = 'PRModeChanged' })
end

vim.api.nvim_create_user_command('GitDiffDevelop', M.diff_against_develop, {})
vim.api.nvim_create_user_command('GitDiffDevelopDeletions', M.diff_deletions_against_develop, {})
vim.api.nvim_create_user_command('PRMode', M.pr_mode_toggle, {})
vim.api.nvim_create_user_command('PRModeStart', M.pr_mode_start, {})
vim.api.nvim_create_user_command('PRModeStop', M.pr_mode_stop, {})

return M
