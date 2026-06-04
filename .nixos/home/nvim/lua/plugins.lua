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
  -- Themes ------------------------------------------------------------------
  -- gruvbox is kept around (commented use in main-config) but not loaded.
  { "ellisonleao/gruvbox.nvim", lazy = true },
  -- alabaster is the active colorscheme -> must load before main-config runs.
  { "p00f/alabaster.nvim", lazy = false, priority = 1000 },

  -- Core libs (deps only, never loaded standalone) --------------------------
  { "nvim-lua/plenary.nvim", lazy = true },
  { "kyazdani42/nvim-web-devicons", lazy = true },

  -- TreeSitter --------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPre", "BufNewFile" },
    build = ":TSUpdate",
    dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
    config = function() require("treesitter") end,
  },

  -- Statusline --------------------------------------------------------------
  {
    "hoob3rt/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "arkav/lualine-lsp-progress" },
    config = function() require("lualine-config") end,
  },

  -- Telescope ---------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<C-g>", "<cmd>Telescope live_grep<cr>",  desc = "Live grep" },
      { "<C-b>", "<cmd>Telescope buffers<cr>",    desc = "Buffers" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function() require("telescope-config") end,
  },

  -- FFF (File Finder) -------------------------------------------------------
  {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    opts = {},
    keys = {
      {
        "ff",
        function() require("fff").find_files() end,
        desc = "Open file picker",
      },
      {
        "fg",
        function() require("fff").live_grep() end,
        desc = "LiFFFe grep",
      },
      {
        "fz",
        function()
          require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
        end,
        desc = "Live fffuzy grep",
      },
    },
  },

  -- File Explorer -----------------------------------------------------------
  {
    "kyazdani42/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeOpen" },
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<CR>",   desc = "Toggle file tree" },
      { "<C-f>", "<cmd>NvimTreeFindFile<CR>", desc = "Find current file in tree" },
    },
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function() require("nvimtree-config") end,
  },

  -- Bufferline (tabline) ----------------------------------------------------
  {
    "akinsho/nvim-bufferline.lua",
    event = "VeryLazy",
    dependencies = { "kyazdani42/nvim-web-devicons" },
    config = function() require("bufferline-config") end,
  },

  -- Surround / Commentary ---------------------------------------------------
  { "tpope/vim-surround",   event = "VeryLazy" },
  { "tpope/vim-commentary", event = "VeryLazy" },

  -- Flash (Easymotion) ------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
      { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
      { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
      { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
    },
    config = function()
      require("flash").setup()
      vim.api.nvim_set_hl(0, "FlashLabel",      { fg = "#282828", bg = "#fabd2f", bold = true })
      vim.api.nvim_set_hl(0, "FlashMatch",      { fg = "#fb4934", bold = true })
      vim.api.nvim_set_hl(0, "FlashCurrent",    { fg = "#83a598", underline = true })
      vim.api.nvim_set_hl(0, "FlashBackdrop",   { fg = "#504945" })
      vim.api.nvim_set_hl(0, "FlashPromptIcon", { fg = "#fe8019" })
      vim.api.nvim_set_hl(0, "FlashPrompt",     { fg = "#b8bb26", bold = true })
    end,
  },

  -- Argwrap -----------------------------------------------------------------
  {
    "exdis/argwrap.nvim",
    keys = {
      { "<leader>a", function() require("argwrap").toggle() end, desc = "Toggle argument wrap" },
    },
    opts = {
      tail_comma = true,
      wrap_closing_brace = true,
      padded_braces = "{",
      line_prefix = "",
    },
    config = function(_, opts) require("argwrap").setup(opts) end,
  },

  -- Autopairs ---------------------------------------------------------------
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Indent guides -----------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require("indentline-config") end,
  },

  -- Find/replace ------------------------------------------------------------
  {
    "windwp/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- stylua: ignore
    keys = {
      { "<leader>S",  function() require("spectre").open() end,                                  desc = "Spectre: open" },
      { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end,     desc = "Spectre: word" },
      { "<leader>s",  'viw:lua require("spectre").open_file_search()<cr>',                       desc = "Spectre: file search" },
    },
  },

  -- Smooth scroll -----------------------------------------------------------
  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    config = function() require("neoscroll").setup() end,
  },

  -- Editorconfig ------------------------------------------------------------
  {
    "editorconfig/editorconfig-vim",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- TagBar ------------------------------------------------------------------
  {
    "preservim/tagbar",
    cmd = "TagbarToggle",
    keys = {
      { "<leader>t", ":TagbarToggle<CR>", desc = "Toggle Tagbar" },
    },
  },

  -- LSP ---------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      {
        "mason-org/mason-lspconfig.nvim",
        dependencies = { { "mason-org/mason.nvim", opts = {} } },
        opts = {
          ensure_installed = { "lua_ls", "rust_analyzer" },
        },
      },
    },
    config = function() require("lsp-config") end,
  },

  -- Completion --------------------------------------------------------------
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets", "onsails/lspkind.nvim" },
    version = "1.*",
    opts = {
      keymap = { preset = "super-tab" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = false } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- Code actions menu -------------------------------------------------------
  { "weilbith/nvim-code-action-menu", cmd = "CodeActionMenu" },

  -- Trouble -----------------------------------------------------------------
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    keys = {
      { "tt", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
    },
    opts = {},
  },

  -- Formatter ---------------------------------------------------------------
  {
    "sbdchd/neoformat",
    cmd = "Neoformat",
    -- `init` runs at startup (cheap: just vim.g + autocmds); the plugin
    -- itself only loads when :Neoformat is invoked by the autocmd.
    init = function() require("neoformat-config") end,
  },

  -- Scrollbar ---------------------------------------------------------------
  {
    "petertriho/nvim-scrollbar",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "lewis6991/gitsigns.nvim" },
    config = function() require("scrollbar-config") end,
  },

  -- Git signs ---------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup()
      pcall(function() require("scrollbar.handlers.gitsigns").setup() end)
    end,
  },

  -- Tmux navigation ---------------------------------------------------------
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
  },

  -- Dressing ----------------------------------------------------------------
  { "stevearc/dressing.nvim", event = "VeryLazy" },

  -- Copilot -----------------------------------------------------------------
  { "git@github.com:github/copilot.vim.git", event = "InsertEnter" },
})
