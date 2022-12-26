vim.g['prettier#exec_cmd_async'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0
vim.g['prettier#autoformat_config_present'] = 1

-- NeoFormat
vim.g[':neoformat_try_node_exe'] = 1
vim.cmd [[
  autocmd BufWritePre *.js Neoformat
  autocmd BufWritePre *.jsx Neoformat
  autocmd BufWritePre *.ts Neoformat
  autocmd BufWritePre *.tsx Neoformat
]]

