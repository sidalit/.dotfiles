local map = vim.keymap.set

local function configure_nord()
  vim.opt.background = 'dark'
  vim.cmd.colorscheme('nord')
end

local function configure_fzf()
  vim.opt.rtp:append(vim.env.HOME .. '/.fzf')
  vim.env.FZF_DEFAULT_OPTS = (vim.env.FZF_DEFAULT_OPTS or '') .. ' --no-border'

  map('n', '<C-o>', ':Files<CR>', { silent = true })
  map('n', '<C-p>', ':History<CR>', { silent = true })
  map('n', '<A-r>', ':BTags<CR>', { silent = true })
  map('n', '<A-S-r>', ':Tags<CR>', { silent = true })
  map('n', '<A-f>', ':Rg<CR>', { silent = true })
  map('n', '<A-s>', ':Snippets<CR>', { silent = true })

  vim.g.fzf_action = {
    ['ctrl-t'] = 'tab split',
    ['ctrl-h'] = 'split',
    ['ctrl-v'] = 'vsplit',
  }
  vim.g.fzf_preview_window = 'right:50%'
  vim.g.fzf_layout = { window = { width = 0.9, height = 0.6, border = 'sharp' } }
  vim.g.fzf_history_dir = '$HOME/.local/share/fzf-history'
  vim.g.fzf_buffers_jump = 1
  vim.g.fzf_commits_log_options = '--format="%Cgreen[%h]%Creset %C(cyan)%an%Creset %C(yellow)%d%Creset - %s"'
  vim.g.fzf_tags_command = 'ctags'
  vim.g.fzf_nvim_statusline = 0

  vim.api.nvim_create_user_command('Rga', function(opts)
    vim.fn['fzf#vim#grep'](
      'rg --column --color=always --hidden --no-heading ' .. vim.fn.shellescape(opts.args),
      { options = { '--tiebreak=end', '--delimiter=:', '--nth=3' } },
      vim.fn['fzf#vim#with_preview'](),
      opts.bang
    )
  end, { bang = true, nargs = '*' })

  vim.api.nvim_create_user_command('Snippets', function()
    require('luasnip.loaders').edit_snippet_files()
  end, { desc = 'Edit available snippets' })

  local fzf_group = vim.api.nvim_create_augroup('FzfStatusline', { clear = true })
  vim.api.nvim_create_autocmd('User', {
    pattern = 'FzfStatusLine',
    group = fzf_group,
    callback = function()
      vim.cmd('highlight fzf_green ctermfg=2 ctermbg=0')
      vim.opt_local.statusline = '%#fzf_green# >>> fzf'
    end,
  })
end

local function configure_alpha()
  local alpha = require('alpha')
  local startify = require('alpha.themes.startify')

  local header = {
    '      $$\\      $$\\           $$\\',
    '      $$ | $\\  $$ |          $$ |',
    '      $$ |$$$\\ $$ | $$$$$$\\  $$ | $$$$$$$\\  $$$$$$\\  $$$$$$\\$$$$\\   $$$$$$\\',
    '      $$ $$ $$\\$$ |$$  __$$\\ $$ |$$  _____|$$  __$$\\ $$  _$$  _$$\\ $$  __$$\\',
    '      $$$$  _$$$$ |$$$$$$$$ |$$ |$$ /      $$ /  $$ |$$ / $$ / $$ |$$$$$$$$ |',
    '      $$$  / \\$$$ |$$   ____|$$ |$$ |      $$ |  $$ |$$ | $$ | $$ |$$   ____|',
    '      $$  /   \\$$ |\\$$$$$$$\\ $$ |\\$$$$$$$\\ \\$$$$$$  |$$ | $$ | $$ |\\$$$$$$$\\',
    '      \\__/     \\__| \\_______|\\__| \\_______| \\______/ \\__| \\__| \\__| \\_______|',
  }

  startify.section.header.val = header
  startify.section.header.opts = { position = 'center' }
  startify.section.top_buttons.val = {
    startify.button('e', '  New file', '<cmd>ene <BAR> startinsert<CR>'),
  }

  local function section_title(title)
    return { type = 'text', val = '   ' .. title, opts = { hl = 'SpecialComment', position = 'center' } }
  end

  local bookmarks = {
    { key = 'c', path = '~/.dotfiles/nvim/.config/nvim/init.lua' },
    { key = 'o', path = '~/.dotfiles/nvim/.config/nvim/lua/config/options.lua' },
    { key = 'm', path = '~/.dotfiles/nvim/.config/nvim/lua/config/keymaps.lua' },
    { key = 'p', path = '~/.dotfiles/nvim/.config/nvim/lua/plugins/init.lua' },
    { key = 's', path = '~/.dotfiles/nvim/.config/nvim/lua/config/commands.lua' },
  }

  local bookmarks_section = {
    type = 'group',
    val = {
      section_title('Bookmarks'),
      { type = 'padding', val = 1 },
    },
  }

  for _, bookmark in ipairs(bookmarks) do
    table.insert(
      bookmarks_section.val,
      startify.button(bookmark.key, bookmark.path, '<cmd>edit ' .. bookmark.path .. '<CR>')
    )
  end

  local commands = {
    { key = 'U', description = 'Update plugins', command = 'Lazy sync' },
    { key = 'C', description = 'Check health', command = 'checkhealth' },
  }

  local commands_section = {
    type = 'group',
    val = {
      section_title('Commands'),
      { type = 'padding', val = 1 },
    },
  }

  for _, command in ipairs(commands) do
    table.insert(
      commands_section.val,
      startify.button(command.key, command.description, '<cmd>' .. command.command .. '<CR>')
    )
  end

  local function session_section(max_sessions)
    local session_dir = vim.fn.stdpath('data') .. '/session'
    local sessions = vim.fn.globpath(session_dir, '*', false, true)
    table.sort(sessions, function(a, b)
      return vim.fn.getftime(a) > vim.fn.getftime(b)
    end)

    local entries = {
      section_title('Sessions'),
      { type = 'padding', val = 1 },
    }

    for index, session in ipairs(sessions) do
      if index > max_sessions then
        break
      end
      local name = vim.fn.fnamemodify(session, ':t')
      table.insert(entries, startify.button(tostring(index), name, '<cmd>source ' .. session .. '<CR>'))
    end

    return { type = 'group', val = entries }
  end

  startify.section.mru.val = {
    section_title('MRU'),
    { type = 'padding', val = 1 },
    startify.mru(5, false),
  }

  startify.section.mru_cwd.val = {
    section_title('MRU ' .. vim.fn.getcwd()),
    { type = 'padding', val = 1 },
    startify.mru(5, true),
  }

  startify.section.bottom_buttons.val = {
    startify.button('q', 'Quit', ':qa<CR>'),
  }

  startify.opts.layout = {
    { type = 'padding', val = 2 },
    startify.section.header,
    { type = 'padding', val = 2 },
    startify.section.top_buttons,
    { type = 'padding', val = 1 },
    startify.section.mru,
    { type = 'padding', val = 1 },
    startify.section.mru_cwd,
    { type = 'padding', val = 1 },
    session_section(5),
    { type = 'padding', val = 1 },
    bookmarks_section,
    { type = 'padding', val = 1 },
    commands_section,
    { type = 'padding', val = 1 },
    startify.section.bottom_buttons,
  }

  startify.opts.opts.noautocmd = true
  alpha.setup(startify.opts)
end

local function configure_lualine()
  require('lualine').setup({
    options = {
      theme = 'nord',
      icons_enabled = true,
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      globalstatus = true,
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', 'diff', 'diagnostics' },
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'encoding', 'fileformat', 'filetype' },
      lualine_y = { 'progress' },
      lualine_z = { { 'location', fmt = function(str) return ' ' .. str end } },
    },
    tabline = {
      lualine_a = {
        {
          'buffers',
          show_filename_only = false,
          mode = 0,
          symbols = { modified = ' •', alternate_file = '#', directory = '' },
        },
      },
      lualine_z = { 'tabs' },
    },
  })
end

local function configure_completion()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  local lspkind = require('lspkind')

  require('luasnip.loaders.from_vscode').lazy_load()

  luasnip.config.set_config({
    history = true,
    updateevents = 'TextChanged,TextChangedI',
    region_check_events = 'CursorHold,InsertLeave',
  })

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    formatting = {
      format = lspkind.cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
        ellipsis_char = '…',
      }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
    }),
  })
end

local function configure_gitgutter()
  if vim.fn.exists('&signcolumn') == 1 then
    vim.opt.signcolumn = 'yes'
  else
    vim.g.gitgutter_sign_column_always = 1
  end
  vim.g.gitgutter_max_signs = 300
  vim.g.gitgutter_map_keys = 0
  vim.g.gitgutter_sign_added = '•'
  vim.g.gitgutter_sign_modified = '•'
  vim.g.gitgutter_sign_removed = '•'
  vim.g.gitgutter_sign_modified_removed = '•'
  vim.g.gitgutter_sign_removed_first_line = '•'
end

local function configure_hexokinase()
  vim.g.Hexokinase_highlighters = { 'virtual' }
  vim.g.Hexokinase_virtualText = '•••'
  vim.g.Hexokinase_ftAutoload = { 'xdefaults', 'css' }
  vim.g.Hexokinase_optInPatterns = { 'full_hex', 'rgb', 'rgba' }
end

return {
  { 'arcticicestudio/nord-vim', priority = 1000, config = configure_nord },
  { 'airblade/vim-gitgutter', init = configure_gitgutter },
  { 'junegunn/fzf', build = './install --bin' },
  { 'junegunn/fzf.vim', dependencies = { 'junegunn/fzf' }, config = configure_fzf },
  { 'mhinz/vim-sayonara', cmd = 'Sayonara' },
  { 'kergoth/vim-bitbake' },
  { 'ntpeters/vim-better-whitespace', init = function() vim.g.better_whitespace_guicolor = '#BF616A' end },
  { 'tpope/vim-commentary' },
  { 'simnalamburt/vim-mundo' },
  { 'matze/vim-move' },
  { 'goolord/alpha-nvim', dependencies = { 'nvim-tree/nvim-web-devicons' }, config = configure_alpha },
  {
    'farmergreg/vim-lastplace',
    init = function()
      vim.g.lastplace_ignore = 'gitcommit,gitrebase,svn,hgcommit'
      vim.g.lastplace_ignore_buftype = 'quickfix,nofile,help'
      vim.g.lastplace_open_folds = 1
    end,
  },
  { 'rrethy/vim-illuminate' },
  { 'rrethy/vim-hexokinase', build = 'make hexokinase', init = configure_hexokinase },
  {
    'tpope/vim-abolish',
    config = function()
      vim.cmd([[
        Abolish afterword{,s}                         afterward{}
        Abolish anomol{y,ies}                         anomal{}
        Abolish austrail{a,an,ia,ian}                 austral{ia,ian}
        Abolish cal{a,e}nder{,s}                      cal{e}ndar{}
        Abolish {c,m}arraige{,s}                      {}arriage{}
        Abolish {,in}consistan{cy,cies,t,tly}         {}consisten{}
        Abolish destionation{,s}                      destination{}
        Abolish delimeter{,s}                         delimiter{}
        Abolish {,non}existan{ce,t}                   {}existen{}
        Abolish despara{te,tely,tion}                 despera{}
        Abolish d{e,i}screp{e,a}nc{y,ies}             d{i}screp{a}nc{}
        Abolish euphamis{m,ms,tic,tically}            euphemis{}
        Abolish hense                                 hence
        Abolish {,re}impliment{,s,ing,ed,ation}       {}implement{}
        Abolish improvment{,s}                        improvement{}
        Abolish inherant{,ly}                         inherent{}
        Abolish lastest                               latest
        Abolish {les,compar,compari}sion{,s}          {les,compari,compari}son{}
        Abolish {,un}nec{ce,ces,e}sar{y,ily}          {}nec{es}sar{}
        Abolish {,un}orgin{,al}                       {}origin{}
        Abolish persistan{ce,t,tly}                   persisten{}
        Abolish referesh{,es}                         refresh{}
        Abolish {,ir}releven{ce,cy,t,tly}             {}relevan{}
        Abolish rec{co,com,o}mend{,s,ed,ing,ation}    rec{om}mend{}
        Abolish reproducable                          reproducible
        Abolish resouce{,s}                           resource{}
        Abolish restraunt{,s}                         restaurant{}
        Abolish seperat{e,es,ed,ing,ely,ion,ions,or}  separat{}
        Abolish segument{,s,ed,ation}                 segment{}
        Abolish {,f,s}pritn{,f}                       {}print{,f}
      ]])
    end,
  },
  { 'TaDaa/vimade' },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = configure_lualine,
  },
  { 'junegunn/vim-easy-align' },
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({})

      local wanted = { 'c', 'lua', 'python', 'bash', 'vim', 'vimdoc', 'markdown' }
      local installed = require('nvim-treesitter').get_installed()
      local installed_set = {}
      for _, lang in ipairs(installed) do
        installed_set[lang] = true
      end

      local missing = {}
      for _, lang in ipairs(wanted) do
        if not installed_set[lang] then
          missing[#missing + 1] = lang
        end
      end

      if #missing > 0 then
        require('nvim-treesitter.install').install(missing)
      end
    end,
  },
  { 'neovim/nvim-lspconfig' },
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim',
    },
    config = configure_completion,
  },
  {
    'ojroques/nvim-lspfuzzy',
    dependencies = { 'junegunn/fzf', 'junegunn/fzf.vim' },
    config = function()
      require('lspfuzzy').setup({})
    end,
  },
}
