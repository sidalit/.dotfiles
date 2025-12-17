local command = vim.api.nvim_create_user_command

local function set_spacing(width)
  if width then
    local value = tonumber(width)
    if value then
      vim.opt.tabstop = value
      vim.opt.softtabstop = value
      vim.opt.shiftwidth = value
    end
  end
end

local function convert_to_tab(width)
  set_spacing(width)
  vim.opt.expandtab = false
  vim.cmd('%retab!')
end

local function convert_to_space(width)
  set_spacing(width)
  vim.opt.expandtab = true
  vim.cmd('%retab!')
end

command('UseTab', function(opts)
  convert_to_tab(opts.fargs[1])
end, { bang = true, nargs = '?' })

command('UseSpace', function(opts)
  convert_to_space(opts.fargs[1])
end, { bang = true, nargs = '?' })

local function window_toggle_tab()
  if vim.fn.winnr('$') > 1 then
    if vim.b.maximized_window_id then
      vim.fn.win_gotoid(vim.b.maximized_window_id)
    else
      vim.b.origin_window_id = vim.fn.win_getid()
      vim.cmd('tab sp')
      vim.b.maximized_window_id = vim.fn.win_getid()
    end
  else
    if vim.b.origin_window_id then
      local origin = vim.b.origin_window_id
      vim.cmd('tabclose')
      vim.fn.win_gotoid(origin)
      vim.b.maximized_window_id = nil
      vim.b.origin_window_id = nil
    end
  end
end

command('ToggleOnly', window_toggle_tab, {})
