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
  'morhetz/gruvbox',

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
  'sheerun/vim-polyglot',

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

  -- Hop (Easymotion)
  'phaazon/hop.nvim',

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
  { 'git@github.com:github/copilot.vim.git', event = 'VeryLazy' }
})
