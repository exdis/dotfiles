local Map = require('utils').Map

require('icons')
require('nvim-tree').setup()
require('bufferline').setup {
  highlights ={
    fill = { bg = 'none' },
    background = { bg = 'none' },
    tab = { bg = 'none' },
    tab_selected = { bg = 'none' },
    buffer_selected = { bg = 'none', bold = true, italic = false },
    numbers_selected = { bg = 'none', bold = true, italic = false },
    numbers = { bg = 'none' },
    numbers_visible = { bg = 'none' },
    buffer_visible = { bg = 'none' },
    separator = { bg = 'none' },
    separator_visible = { bg = 'none' },
    indicator_selected = { fg = 'orange', bg = 'none' },
  },
  options = {
    numbers = function(opts)
      return string.format('%s', opts.id)
    end,
    left_trunc_marker = "",
    right_trunc_marker = "",
    offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "left"}},
    show_tab_indicators = true,
    show_close_icon = false,
    show_buffer_close_icons = false,
    separator_style = { '', '' }
  }
}

Map('n', '<C-n>', '<cmd>NvimTreeToggle<CR>')
Map('n', '<C-f>', '<cmd>NvimTreeFindFile<CR>')
vim.cmd [[
  highlight NvimTreeFolderIcon guifg=orange
  highlight NvimTreeFolderName guifg=fg0
  highlight NvimTreeGitDirty guifg=red
  highlight NvimTreeOpenedFolderName guifg=fg0
  highlight NvimTreeEmptyFolderName guifg=fg0
  highlight NvimTreeIndentMarker guifg=orange
]]
