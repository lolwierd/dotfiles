-- local fterm = require("FTerm")

require'FTerm'.setup({
    border = 'single',
    dimensions  = {
        height = 0.9,
        width = 0.9,
    },
})

-- local btop = fterm:new({
--     ft = 'fterm_btop',
--     cmd = "btop"
-- })

 -- Use this to toggle btop in a floating terminal
-- vim.keymap.set('n', '<C-b>', function()
--     btop:toggle()
-- end)

vim.keymap.set('t', '<C-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('n', '<C-i>', '<CMD>lua require("FTerm").toggle()<CR>')
