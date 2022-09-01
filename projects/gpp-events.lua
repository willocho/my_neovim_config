local handle = io.popen('node-gyp -- configure -f=gyp.generator.compile_commands_json.py')
handle:read('*a')
suc, _, code = handle:close()
if(not suc) then
    print("node_gyp failed to run")
end

local clangd_file = io.open(".clangd", "r")
if clangd_file == nil then
    clangd_file = io.open(".clangd", "w")
    io.output(clangd_file)
    io.write(
        'CompileFlags:\n' ..
        '  Add:\n' ..
        '    - "--include-directory=~/.nvm/versions/node/v12.22.7/lib/node_modules/nan/"'
      )
end
io.close(clangd_file)
