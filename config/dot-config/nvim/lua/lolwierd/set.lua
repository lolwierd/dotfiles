vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.nvim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 12
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")


vim.opt.updatetime = 50

vim.g.mapleader = " "
-- vim.opt.colorcolumn = "80"
-- vim.g.netrw_liststyle = 3

vim.o.foldcolumn = '0' -- '0' is not bad
vim.o.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true


local function set_theme_by_system()
  -- returns "Dark\n" when dark mode is on, nonzero exit in light mode
  local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
  local out = handle and handle:read('*a') or ''
  local ok = handle and handle:close()
  local is_dark = (out:gsub('%s+$', '') == 'Dark')

  if is_dark then
    vim.o.background = 'dark'
    -- pick your dark theme
    vim.cmd.colorscheme "catppuccin-mocha"
  else
    vim.o.background = 'light'
    -- pick your light theme
    vim.cmd.colorscheme "catppuccin-latte"
  end
end

local grp = vim.api.nvim_create_augroup('macos_theme', { clear = true })
vim.api.nvim_create_autocmd({ 'VimEnter', 'FocusGained' }, {
  group = grp,
  callback = set_theme_by_system
})

--poll every 60s
local timer = vim.uv.new_timer()
timer:start(0, 60000, function()
  vim.schedule(set_theme_by_system)
end)

-- NOTE: Format on save is handled by lsp-zero's buffer_autoformat() in after/plugin/lsp.lua

vim.opt.clipboard:append('unnamedplus')

vim.cmd('set cmdheight=1')

vim.api.nvim_create_autocmd("VimLeave", {
  pattern = "*",
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkon1"
  end
})
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3

vim.cmd("highlight Normal ctermbg=NONE guibg=NONE")
vim.cmd("highlight NonText ctermbg=NONE guibg=NONE")
