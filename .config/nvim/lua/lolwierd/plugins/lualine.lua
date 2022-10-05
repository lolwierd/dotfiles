require('lualine').setup({
    options = {
        theme = 'ayu_dark',
        component_separators = '',
        section_separators = '',
        icons_enabled = true,
        globalstatus = true,
    },
    extensions = { 'quickfix', 'nvim-tree' },
})
