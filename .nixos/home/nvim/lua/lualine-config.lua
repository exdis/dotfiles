require('lualine').setup {
  options = {
    theme = 'alabaster'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_c = {{'filename', path=1}},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'lsp_progress'},
    lualine_z = {'location'}
  },
  extensions = {'quickfix', 'nvim-tree'}
}
