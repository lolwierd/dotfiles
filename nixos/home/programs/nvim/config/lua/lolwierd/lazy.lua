require("lazy").setup({
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-tree/nvim-web-devicons",
  --     "MunifTanjim/nui.nvim",
  --   }
  -- },
  {
    "nvim-telescope/telescope.nvim",
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate"
  },
  "nvim-treesitter/playground",
  {
    "theprimeagen/harpoon",
    branch = 'harpoon2'
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = 'v3.x'
  },
  "neovim/nvim-lspconfig",
  "ray-x/lsp_signature.nvim",
  "hrsh7th/cmp-nvim-lsp",
  "code-biscuits/nvim-biscuits",
  "hrsh7th/nvim-cmp",
  "L3MON4D3/LuaSnip",
  {
    "williamboman/mason.nvim",
    run = ':MasonUpdate',
    opts = {}
  },
  "williamboman/mason-lspconfig.nvim",
  {
    "ray-x/go.nvim",
    dependencies = {
      "ray-x/guihua.lua",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()'
  },
  "kevinhwang91/nvim-ufo",
  "kevinhwang91/promise-async",
  "mbbill/undotree",
  "tpope/vim-fugitive",
  -- "nvim-lualine/lualine.nvim",
  {
    "nvim-tree/nvim-web-devicons",
    opt = true
  },
  "catppuccin/nvim",
  "yorik1984/newpaper.nvim",
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },
  { "lukas-reineke/indent-blankline.nvim" },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {}
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {}
  },
  {
    "ggandor/leap.nvim",
    config = function() require("leap").add_default_mappings() end,
  },
  "tpope/vim-repeat",
  "rcarriga/nvim-notify",
  "xiyaowong/transparent.nvim",
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
    }
  },
  "lambdalisue/suda.vim",
  {
    "shortcuts/no-neck-pain.nvim",
    version = "*",
    config = require("no-neck-pain").setup({
      width = 120,
      fallbackOnBufferDelete = true,
      autocmds = {
        enableOnVimEnter = true,
        reloadOnColorSchemeChange = true,
      },
    }),
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
  }
})
