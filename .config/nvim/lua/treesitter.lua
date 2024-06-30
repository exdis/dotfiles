local treesitter = require('nvim-treesitter.configs')

treesitter.setup({
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  ensure_installed = {
    'json',
    'javascript',
    'typescript',
    'tsx',
    'graphql',
    'lua',
    'python',
    'gleam',
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['a='] = '@assignment.outer',
        ['i='] = '@assignment.inner',
        ['l='] = '@assignment.lhs',
        ['r='] = '@assignment.rhs',

        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',

        ['ai'] = '@conditional.outer',
        ['ii'] = '@conditional.inner',

        ['al'] = '@loop.outer',
        ['il'] = '@loop.inner',

        ['af'] = '@call.outer',
        ['if'] = '@call.inner',

        ['am'] = '@function.outer',
        ['im'] = '@function.inner',

        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      }
    },
  },
})
