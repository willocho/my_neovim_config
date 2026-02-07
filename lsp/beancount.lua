return {
    commands = { "beancount-language-server", "--stdio" },
    root_markers = { "main.bean", ".git" },
    -- init_options are optional
    init_options = {
        -- Optional: Only needed for multi-file projects with include directives
        journal_file = "main.bean",
    },
    settings = {
        beancount = {
            formatting = {
                prefix_width = 30,
                currency_column = 60,
                number_currency_spacing = 1,
            }
        }
    }
}
