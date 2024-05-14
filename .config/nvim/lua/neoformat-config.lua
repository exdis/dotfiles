vim.g['prettier#exec_cmd_async'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0
vim.g['prettier#autoformat_config_present'] = 1

-- NeoFormat
vim.g['neoformat_try_node_exe'] = 1

vim.cmd [[
let g:neoformat_javascript_prettier = {
  \ 'exe': 'node_modules/.bin/prettier',
  \ 'args': ['--stdin', '--stdin-filepath', '"%:p"'],
  \ 'stdin': 1,
  \ 'try_node_exe': 1,
  \ }

let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_python = ['yapf']
]]

vim.cmd [[
  autocmd BufWritePre *.js Neoformat
  autocmd BufWritePre *.jsx Neoformat
  autocmd BufWritePre *.ts Neoformat
  autocmd BufWritePre *.tsx Neoformat
  autocmd BufWritePre *.py Neoformat
]]

