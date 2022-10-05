local A = vim.api

-- Custom filetypes
vim.filetype.add({
    extension = {
        eslintrc = 'json',
        prettierrc = 'json',
        conf = 'conf',
        mdx = 'markdown',
        mjml = 'html',
    },
    pattern = {
        ['.*%.env.*'] = 'sh',
        ['ignore$'] = 'conf',
    },
    filename = {
        ['yup.lock'] = 'yaml',
    },
})

local lol_au = A.nvim_create_augroup('LOLWIERD', { clear = true })

-- Highlight the region on yank
A.nvim_create_autocmd('TextYankPost', {
    group = lol_au,
    callback = function()
        vim.highlight.on_yank({ higroup = 'Visual' })
    end,
})
