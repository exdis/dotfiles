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

  -- Lualine
  'hoob3rt/lualine.nvim',

  -- Language support
  'sheerun/vim-polyglot',

  -- FuzzyFinder
  'nvim-lua/plenary.nvim',

  -- Telescope
  'nvim-telescope/telescope.nvim',

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

  -- IndentLine
  'Yggdroot/indentLine',

  -- Find/replace
  'nvim-lua/plenary.nvim',
  'windwp/nvim-spectre',

  -- Smooth scroll
  'karb94/neoscroll.nvim',

  -- Editorconfig
  'editorconfig/editorconfig-vim',

  -- TagBar
  'preservim/tagbar',

  -- LSP
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'neovim/nvim-lspconfig',

  -- Autocomplete
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',

  -- Code actions menu
  { 'weilbith/nvim-code-action-menu', cmd = 'CodeActionMenu' },

  -- Snippets
  'L3MON4D3/LuaSnip',
  'saadparwaiz1/cmp_luasnip',

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
  'simrat39/symbols-outline.nvim'
})
