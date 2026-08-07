-- =====================================================
--              NEOVIM MASTER CONFIG
-- =====================================================
-- SECTIONS:
--   PLUGINS
--   SETTINGS
--   KEYMAPS
--   LSP
--   AIRLINE
--   OIL

-- =====================================================
-- PLUGINS
-- =====================================================

local plug = vim.fn['plug#']

vim.call('plug#begin')

plug('vim-airline/vim-airline')
plug('vim-airline/vim-airline-themes')

-- Theme
plug('Shatur/neovim-ayu')

-- Telescope
plug('nvim-lua/plenary.nvim')
plug('nvim-telescope/telescope.nvim')

-- LSP
plug('neovim/nvim-lspconfig')

-- Bracket pairs
plug('jiangmiao/auto-pairs')

-- File Explorer
plug('stevearc/oil.nvim')

-- Sublime Text style find and replace
plug('MagicDuck/grug-far.nvim')

vim.call('plug#end')


-- =====================================================
-- SETTINGS
-- =====================================================

vim.opt.background    = 'dark'
vim.cmd('colorscheme ayu-dark')

vim.opt.relativenumber = true
vim.opt.number         = true

-- Show tabs and file status + open file name on top
vim.opt.showtabline = 2
vim.opt.laststatus  = 2

vim.opt.scrolloff = 8

vim.opt.encoding = 'utf-8'

-- Some servers have issues with backup files, see #649
vim.opt.backup      = false
vim.opt.writebackup = false

-- vim.opt.tabstop     = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth  = 4
vim.opt.smartindent = true
-- vim.opt.autoindent  = true

vim.opt.termguicolors = true

-- Prevents cursor from changing from solid rectangle
vim.opt.guicursor = ''

if vim.g.colors_name == 'ayu' then
  vim.api.nvim_set_hl(0, 'LineNr',       { fg = '#8A9199' })
  vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#E6B450', bold = true })
  vim.api.nvim_set_hl(0, 'Visual',       { bg = '#3E4B59' })
  vim.api.nvim_set_hl(0, 'VisualNOS',    { bg = '#3E4B59' })
end


-- =====================================================
-- KEYMAPS
-- =====================================================

vim.g.mapleader = ' '

local map = vim.keymap.set

-- Switch to next/previous buffer
map('n', '<leader>bn', ':bn<CR>')
map('n', '<leader>bp', ':bp<CR>')

-- Open new buffer
map('n', '<leader>be', ':e ')

-- Close buffer
map('n', '<leader>bc', ':bw')

-- Fuzzy finder
map('n', '<leader>F',  '<cmd>Telescope find_files<CR>')
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')

-- Open oil.nvim
map('n', '<leader>e', '<cmd>Oil<CR>')

-- Open Grug-Far find and replace in new buffer
map('n', '<leader>G', function()
  require('grug-far').open()
  vim.schedule(function()
    vim.cmd('only')
  end)
end)

-- Open Grug-Far find and replace for word under cursor in new buffer
map('n', '<leader>*', function()
  require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
  vim.schedule(function()
    vim.cmd('only')
  end)
end)


-- =====================================================
-- LSP
-- =====================================================

vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'

-- Prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { 'menuone', 'noselect', 'popup' }

vim.diagnostic.config({
  virtual_text = true,
  signs        = true,
  underline    = true,
})

local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil
  local opts = { buffer = bufnr, silent = true }

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  map('i', '<C-Space>', vim.lsp.completion.get, opts)

  -- Trigger LSP completion after typing 1+ keyword character
  vim.api.nvim_create_autocmd('TextChangedI', {
    buffer = bufnr,
    callback = function()
      local word = vim.fn.matchstr(vim.fn.getline('.'), '\\k\\+$')
      if #word >= 1 then vim.lsp.completion.get() end
    end,
  })

  map('n', 'gd',          vim.lsp.buf.definition,      opts)
  map('n', 'gy',          vim.lsp.buf.type_definition,  opts)
  map('n', 'gi',          vim.lsp.buf.implementation,   opts)
  map('n', 'gr',          vim.lsp.buf.references,        opts)
  map('n', 'K',           vim.lsp.buf.hover,             opts)
  map('n', '<leader>rn',  vim.lsp.buf.rename,            opts)
  map('n', '<leader>ac',  vim.lsp.buf.code_action,       opts)
  map('n', '<leader>f',   vim.lsp.buf.format,            opts)
  map('n', '[g',          vim.diagnostic.goto_prev,      opts)
  map('n', ']g',          vim.diagnostic.goto_next,      opts)

  map('i', '<Tab>', function()
    return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
  end, { buffer = bufnr, expr = true })
  map('i', '<S-Tab>', function()
    return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
  end, { buffer = bufnr, expr = true })
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.lsp.start({
      name      = 'clangd',
      cmd       = { 'clangd' },
      on_attach = on_attach,
      root_dir  = vim.fs.root(0, { '.git', 'Makefile', 'compile_commands.json' }),
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = function()
    vim.lsp.start({
      name      = 'pylsp',
      cmd       = { 'pylsp' },
      on_attach = on_attach,
      root_dir  = vim.fs.root(0, { '.git', 'setup.py', 'pyproject.toml' }),
    })
  end,
})


-- =====================================================
-- AIRLINE
-- =====================================================

vim.g['airline#extensions#tabline#enabled'] = 1
vim.g.airline_theme = 'minimalist'


-- =====================================================
-- GRUG-FAR
-- =====================================================
require("grug-far").setup({
  engines = {
    ripgrep = {
      extraArgs = '--no-ignore --hidden'
    }
  }
})


-- =====================================================
-- OIL
-- =====================================================
require("oil").setup({
	default_file_explorer = true,
	buf_options = {
		buflisted = true,
		bufhidden = "hide"
	},
	watch_for_changes = true,
	view_options      = { show_hidden = true },
	float = {
		padding     = 2,
		max_width   = 0.8,
		max_height  = 0.8,
		border      = 'rounded',
		win_options = { winblend = 0 },
	},
	preview_split = "auto"
})

-- This ai-generated block makes oil not open a bajillion new
-- buffers every time you navigate to a different directory
vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'oil://*',
  callback = function(args)
    -- delete previous oil buffer when entering a new one
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if bufnr ~= args.buf
        and vim.bo[bufnr].filetype == 'oil'
        and vim.api.nvim_buf_is_valid(bufnr) then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end
  end,
})

