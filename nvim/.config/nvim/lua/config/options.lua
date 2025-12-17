local opt = vim.opt
local g = vim.g

-- Python providers
g.python_host_skip_check = 1
g.python3_host_skip_check = 1
g.python_host_prog = '/usr/bin/python2'
g.python3_host_prog = '/usr/bin/python3'

-- Disable built-in plugins we do not use
local disabled_builtins = {
  'getscript', 'getscriptPlugin', 'gzip', 'logiPat', 'matchit', 'netrw',
  'netrwPlugin', 'netrwFileHandlers', 'netrwSettings', 'rrhelper', 'shada_plugin',
  'tar', 'tarPlugin', 'tutor_mode_plugin', '2html_plugin', 'vimball',
  'vimballPlugin', 'zip', 'zipPlugin',
}
for _, plugin in ipairs(disabled_builtins) do
  g['loaded_' .. plugin] = 1
end
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- Colorscheme preferences
g.nord_uniform_status_lines = 1
g.nord_cursor_line_number_background = 1
g.nord_bold_vertical_split_line = 0
g.nord_underline = 1
g.nord_italic = 0
g.nord_italic_comments = 0
g.nord_bold = 0

opt.ttyfast = true
opt.termguicolors = vim.fn.has('termguicolors') == 1
opt.background = 'dark'

vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

opt.updatetime = 0
opt.scrolloff = 5
opt.autoread = true
opt.foldenable = false
opt.undofile = true
opt.undolevels = 30
opt.undoreload = 1000
opt.history = 100
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.synmaxcol = 400
opt.mouse = 'a'
opt.clipboard = 'unnamedplus'

opt.showcmd = true
opt.showmatch = true
opt.showmode = false
opt.ruler = false
opt.number = true
opt.formatoptions:append('o')
opt.formatoptions:append('1')
opt.formatoptions:remove('t')
opt.textwidth = 0

opt.expandtab = true
opt.copyindent = true
opt.cindent = true
opt.smartindent = true
opt.preserveindent = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.shiftround = true

opt.belloff = 'all'
opt.visualbell = false
opt.errorbells = false

opt.modeline = true
opt.linespace = 0
opt.joinspaces = false
opt.smartcase = true
opt.smarttab = true
opt.wildignore = {
  '*.swp', '*.bak', '*.pyc', '*.class', '*.aux', '*.out', '*.toc', '*.o', '*.so',
  '*.a', '*.obj', '*.exe', '*.dll', '*.jar', '*.rbc', '*.ai', '*.bmp', '*.gif',
  '*.ico', '*.jpg', '*.jpeg', '*.png', '*.psd', '*.webp', '*.avi', '*.m4a',
  '*.mp3', '*.oga', '*.ogg', '*.wav', '*.webm', '*.eot', '*.otf', '*.ttf',
  '*.woff', '*.doc', '*.pdf', '*.zip', '*.tar.gz', '*.tar.bz2', '*.rar', '*.tar.xz',
}
opt.hidden = true
opt.splitbelow = true
opt.splitright = true

opt.listchars = {
  eol = '¬',
  tab = '» ',
  space = '·',
  extends = '>',
  precedes = '<',
  trail = '•',
}

opt.cursorline = true
opt.cursorcolumn = true
opt.startofline = false
opt.encoding = 'utf-8'
opt.showtabline = 2
opt.laststatus = 2
opt.cmdheight = 2
opt.wildmenu = true
opt.wildmode = 'full'
opt.wildignorecase = true
opt.completeopt = { 'menu', 'menuone', 'noselect' }

opt.inccommand = 'nosplit'

-- Sign column for git status and diagnostics
opt.signcolumn = 'yes'
