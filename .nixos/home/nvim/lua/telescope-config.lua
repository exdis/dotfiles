local Map = require('utils').Map

local telescope = require('telescope')

telescope.load_extension('fzf')

Map('n', '<C-p>', '<cmd>Telescope find_files<cr>')
Map('n', '<C-g>', '<cmd>Telescope live_grep<cr>')
Map('n', '<C-b>', '<cmd>Telescope buffers<cr>')
