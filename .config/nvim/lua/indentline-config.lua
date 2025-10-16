vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = "#C0C0C0", nocombine = true })
vim.api.nvim_set_hl(0, "IndentBlanklineScope", { fg = "#B0B0B0", nocombine = true })
require("ibl").setup({
   indent = {
      char = '▏',
      highlight = "IndentBlanklineChar",
   },
   scope = {
      show_start = false,
      show_end = false,
      include = {
         node_type = { ["*"] = { "*" } },
      },
      highlight = "IndentBlanklineScope",
   },
})
