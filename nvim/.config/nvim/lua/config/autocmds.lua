local group = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local ft_group = group('LocalFiletypeSettings', { clear = true })
autocmd('FileType', {
  pattern = { 'sh', 'c', 'cpp' },
  group = ft_group,
  callback = function()
    vim.opt_local.colorcolumn = '80'
  end,
})

autocmd('FileType', {
  pattern = { 'python' },
  group = ft_group,
  callback = function()
    vim.opt_local.colorcolumn = '120'
  end,
})
