local map = vim.keymap.set

local function duplicate_visual_selection()
  local register_value = vim.fn.getreg('0')
  vim.cmd([[normal! gvy`>p]])
  vim.fn.setreg('0', register_value)
end

local function duplicate_line()
  vim.cmd('t.')
end

map('n', '<c-s>', ':update<cr>', { silent = true })
map('v', '<c-s>', '<c-c>:update<cr>', { silent = true })
map('i', '<c-s>', '<c-o>:update<cr><esc>', { silent = true })

map('n', '<a-right>', ':bn<cr>', { silent = true })
map('n', '<a-left>', ':bp<cr>', { silent = true })

map('n', '<c-a-right>', ':wincmd l<cr>', { silent = true })
map('n', '<c-a-left>', ':wincmd h<cr>', { silent = true })
map('n', '<c-a-down>', ':wincmd j<cr>', { silent = true })
map('n', '<c-a-up>', ':wincmd k<cr>', { silent = true })

if vim.fn.has('nvim') == 1 then
  map('i', '<esc>', '<esc><esc>')
end

map('n', '<esc><esc>', ':<c-u>nohlsearch<CR>', { silent = true })
map({'n', 'v'}, '<c-w>', ':Sayonara<cr>', { silent = true, nowait = true })
map('n', '<a-d>', duplicate_line, { silent = true })
map('x', '<a-d>', duplicate_visual_selection, { silent = true })
map({'n', 'v'}, '<c-a>', '<esc>ggVG<CR>')
map('n', '<F3>', ':set list!<CR>', { silent = true })
map('n', 'Q', '<nop>')

-- Undo tree
map('n', '<F5>', ':MundoToggle<CR>', { silent = true })

-- Move lines/blocks
map('n', '<C-Up>', '<Plug>MoveLineUp')
map('n', '<C-Down>', '<Plug>MoveLineDown')
map('v', '<C-Up>', '<Plug>MoveBlockUp')
map('v', '<C-Down>', '<Plug>MoveBlockDown')
