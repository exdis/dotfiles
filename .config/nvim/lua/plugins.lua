local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--single-branch",
      "https://github.com/folke/lazy.nvim.git",
      lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

require("lazy").setup({
  -- Theme
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },

  -- TreeSitter,
  {
    "nvim-treesitter/nvim-treesitter",
    event = { 'BufReadPre', 'BufNewFile' },
    build = ":TSUpdate",
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects'
    }
  },

  -- Lualine
  'hoob3rt/lualine.nvim',

  -- Language support
  {
    'sheerun/vim-polyglot',
    init = function()
      vim.g.polyglot_disabled = { "ftdetect" }
    end,
  },

  -- FuzzyFinder
  'nvim-lua/plenary.nvim',

  -- Telescope
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    }
  },

  -- FileExplorer
  'kyazdani42/nvim-web-devicons',
  'kyazdani42/nvim-tree.lua',

  -- TabLine
  'akinsho/nvim-bufferline.lua',

  -- Surround Vim
  'tpope/vim-surround',

  -- Commentary
  'tpope/vim-commentary',

  -- Flash (Easymotion)
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
    config = function()
      require("flash").setup()
      vim.api.nvim_set_hl(0, "FlashLabel",       { fg = "#282828", bg = "#fabd2f", bold = true })
      vim.api.nvim_set_hl(0, "FlashMatch",       { fg = "#fb4934", bold = true })
      vim.api.nvim_set_hl(0, "FlashCurrent",     { fg = "#83a598", underline = true })
      vim.api.nvim_set_hl(0, "FlashBackdrop",    { fg = "#504945" })
      vim.api.nvim_set_hl(0, "FlashPromptIcon",  { fg = "#fe8019" })
      vim.api.nvim_set_hl(0, "FlashPrompt",      { fg = "#b8bb26", bold = true })
    end,
  },

  -- Argwrap
  'FooSoft/vim-argwrap',

  -- Autoclose
  'windwp/nvim-autopairs',

  -- Indent Blankline
  -- 'Yggdroot/indentLine',
  'lukas-reineke/indent-blankline.nvim',

  -- Find/replace
  'nvim-lua/plenary.nvim',
  'windwp/nvim-spectre',

  -- Smooth scroll
  'karb94/neoscroll.nvim',

  -- Editorconfig
  'editorconfig/editorconfig-vim',

  -- TagBar
  'preservim/tagbar',

  -- Mason
  {
    'williamboman/mason.nvim',
    dependencies = {
      'williamboman/mason-lspconfig.nvim',
    }
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    }
  },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-cmdline',
      -- Snippets
      {
        'L3MON4D3/LuaSnip',
        version = 'v2.*',
        build = 'make install_jsregexp'
      },
      'saadparwaiz1/cmp_luasnip',
    }
  },

  -- Code actions menu
  { 'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu' },

  -- Suggest icons
  'onsails/lspkind.nvim',

  -- Trouble
  'folke/trouble.nvim',

  -- Prettier
  'sbdchd/neoformat',

  -- LSP progress
  'arkav/lualine-lsp-progress',

  -- Scrollbar
  'petertriho/nvim-scrollbar',

  -- Git signs
  'lewis6991/gitsigns.nvim',

  -- Symbols outline
  'simrat39/symbols-outline.nvim',

  -- Tmux navigation
  'christoomey/vim-tmux-navigator',

  -- Dressing
  { 'stevearc/dressing.nvim', event = 'VeryLazy' },

  -- Copilot
  { 'git@github.com:github/copilot.vim.git', event = 'VeryLazy' },

  -- NeOrg
  {
    "nvim-neorg/neorg",
    lazy = false,
    version = "*",
    after = "nvim-treesitter",
    ft = "norg",
    dependencies = { "vhyrro/luarocks.nvim", "nvim-treesitter" },
  },

  {
    "trackpad.nvim",
    dir = "~/dev/notes",
    config = function()
      require("trackpad").setup({
        dir = "/Users/dkolesnikov/dev/notes-repo/"
      })
    end,
  }
})
