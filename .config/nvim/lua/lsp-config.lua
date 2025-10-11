require('mason-lspconfig').setup({
  ensure_installed = {
    'ts_ls',
    'eslint',
    'html',
    'cssls',
    'rust_analyzer',
    'pylsp',
    'zls',
  }
})

local lsp_cmds = vim.api.nvim_create_augroup('lsp_cmds', {clear = true})

vim.api.nvim_create_autocmd('LspAttach', {
  group = lsp_cmds,
  desc = 'LSP actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      vim.keymap.set(mode, lhs, rhs, {buffer = true})
    end

    bufmap('n', '<leader>rn', vim.lsp.buf.rename, {})
    -- bufmap('n', '<leader>ca', vim.lsp.buf.code_action, {})
    bufmap('n', '<leader>ca', ':CodeActionMenu<CR>', {})

    bufmap('n', 'gd', vim.lsp.buf.definition, {})
    bufmap('n', 'gi', vim.lsp.buf.implementation, {})
    bufmap('n', 'gr', require('telescope.builtin').lsp_references, {})
    bufmap('n', 'M', vim.lsp.buf.hover, {})
  end
})

vim.opt.completeopt = {'menu', 'menuone', 'noselect'}

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = true,
})

vim.o.updatetime = 250
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]

local signs = { Error = "", Warn = "", Hint = "", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Zig format
vim.api.nvim_create_autocmd('BufWritePre',{
  pattern = {"*.zig", "*.zon"},
  callback = function(ev)
    vim.lsp.buf.format()
  end
})

-- Zig build
vim.lsp.config('zls', {
  settings = {
    enable_build_on_save = true
  },
})
