-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.x',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use({
    'nvim-treesitter/nvim-treesitter',
    { run = ':TSUpdate' }
  })
  use 'nvim-treesitter/playground'
  use 'theprimeagen/harpoon'
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' },
      {
        'williamboman/mason.nvim',
        run = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'L3MON4D3/LuaSnip' },
      -- { 'mfussenegger/nvim-dap' },
    }
  }
  use({ 'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" } })

  use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

  use 'mbbill/undotree'
  use 'tpope/vim-fugitive'

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use { "catppuccin/nvim", as = "catppuccin" }

  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }
  use "numToStr/FTerm.nvim"

  use "lukas-reineke/indent-blankline.nvim"

  use({
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  })

  use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  }

  use({
    "ggandor/leap.nvim",
    config = function() require("leap").add_default_mappings() end,
    requires = 'tpope/vim-repeat'
  })

  use 'rcarriga/nvim-notify'
  use 'xiyaowong/transparent.nvim'
end)
