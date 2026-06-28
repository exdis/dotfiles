local Map = require('utils').Map

Map('n', '<leader>S', ':lua require("spectre").open()<CR>')
Map('n', '<leader>sw', ':lua require("spectre").open_visual({select_word=true})<CR>')
Map('n', '<leader>s', 'viw:lua require("spectre").open_file_search()<cr>')
