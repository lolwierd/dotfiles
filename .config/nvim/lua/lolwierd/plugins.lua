-- Automatically run :PackerCompile whenever plugins.lua is updated with an autocommand:
 vim.api.nvim_create_autocmd('BufWritePost', {
     group = vim.api.nvim_create_augroup('PACKER', { clear = true }),
     pattern = 'plugins.lua',
     command = 'source <afile> | PackerCompile',
 })

return require('packer').startup({
    function(use)
        use('wbthomason/packer.nvim')
        use({
            {
                'nvim-treesitter/nvim-treesitter',
                run = ':TSUpdate',
                config = function()
                    require('lolwierd.plugins.treesitter')
                end,
            },
            { 'nvim-treesitter/playground', after = 'nvim-treesitter' },
            { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' },
            { 'nvim-treesitter/nvim-treesitter-refactor', after = 'nvim-treesitter' },
            { 'windwp/nvim-ts-autotag', after = 'nvim-treesitter' },
            { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' },
        })

        use('nvim-lua/plenary.nvim')
        use({
            'kyazdani42/nvim-web-devicons',
            config = function()
                require('nvim-web-devicons').setup()
            end,
        })

        use({
            {
                'nvim-lualine/lualine.nvim',
                config = function()
                    require('lolwierd.plugins.lualine')
                end,
            },
            {
                'j-hui/fidget.nvim',
                after = 'lualine.nvim',
                config = function()
                    require('fidget').setup()
                end,
            },
        })

         use({
            'kyazdani42/nvim-tree.lua',
            config = function()
                require('lolwierd.plugins.nvim-tree')
            end,
        })
        use({
            {
                'nvim-telescope/telescope.nvim',
                config = function()
                    require('lolwierd.plugins.telescope')
                end,
            },
            {
                'nvim-telescope/telescope-fzf-native.nvim',
                after = 'telescope.nvim',
                run = 'make',
                config = function()
                    require('telescope').load_extension('fzf')
                end,
            },
            {
                'nvim-telescope/telescope-symbols.nvim',
                after = 'telescope.nvim',
            },
        })
        use({
            'phaazon/hop.nvim',
            event = 'BufRead',
            config = function()
                require('lolwierd.plugins.hop')
            end,
        })
        use({
            'karb94/neoscroll.nvim',
            event = 'WinScrolled',
            config = function()
                require('neoscroll').setup({ hide_cursor = false })
            end,
        })
        use({
            'numToStr/Comment.nvim',
            event = 'BufRead',
            config = function()
                require('lolwierd.plugins.comment')
            end,
        })
        use({
            'tpope/vim-surround',
            event = 'BufRead',
            requires = {
                {
                    'tpope/vim-repeat',
                    event = 'BufRead',
                },
            },
        })
        use({
            'wellle/targets.vim',
            event = 'BufRead',
        })
        use({
            'AndrewRadev/splitjoin.vim',
            -- NOTE: splitjoin won't work with `BufRead` event
        })
        use({
            'numToStr/FTerm.nvim',
            config = function()
                require('lolwierd.plugins.fterm')
            end,
        })
        use({
            'neovim/nvim-lspconfig',
            event = 'BufRead',
            config = function()
                require('lolwierd.plugins.lsp.servers')
            end,
            requires = {
                {
                    -- WARN: Unfortunately we won't be able to lazy load this
                    'hrsh7th/cmp-nvim-lsp',
                },
            },
        })
        use({
            'jose-elias-alvarez/null-ls.nvim',
            event = 'BufRead',
            config = function()
                require('lolwierd.plugins.lsp.null-ls')
            end,
        })
        use({
          {
              'hrsh7th/nvim-cmp',
              event = 'InsertEnter',
              config = function()
                  require('lolwierd.plugins.lsp.nvim-cmp')
              end,
              requires = {
                  {
                      'L3MON4D3/LuaSnip',
                      event = 'InsertEnter',
                      config = function()
                          require('lolwierd.plugins.lsp.luasnip')

                      end,
                      requires = {
                          {
                              'rafamadriz/friendly-snippets',
                          },
                      },
                  },
              },
          },
          { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
          { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
          { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
      })
      use({
            'windwp/nvim-autopairs',
            event = 'InsertCharPre',
            after = 'nvim-cmp',
            config = function()
                require('lolwierd.plugins.pairs')
            end,
        })

    end,
    config = {
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'single' })
            end,
        },
    },
})
