-- =====================================================
--              NEOVIM MASTER CONFIG
-- =====================================================
-- SECTIONS:
--   PLUGINS
--   SETTINGS
--   KEYMAPS
--   LSP
--   AIRLINE
--   NVIMTREE


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

-- File tree (neo-tree and its deps)
plug('MunifTanjim/nui.nvim')
plug('nvim-tree/nvim-web-devicons')
plug('Crysthamus/nvim-file-operations')
plug('folke/snacks.nvim')
plug('snacks.rename')
plug('s1n7ax/nvim-window-picker')
plug('nvim-neo-tree/neo-tree.nvim')

-- Nvim tree
plug('nvim-tree/nvim-tree.lua')

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

--- BUFFERS ---
-- Switch to next/previous buffer
map('n', '<leader>bn', ':bn<CR>')
map('n', '<leader>bp', ':bp<CR>')

-- Open new buffer
map('n', '<leader>be', ':e ')

-- Close buffer
map('n', '<leader>bc', ':bw')

-- Fuzzy finder
map('n', '<leader>F',  '<cmd>Telescope find_files<CR>')
map('n', '<leader>G',  '<cmd>Telescope live_grep<CR>')
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>')

-- Open neo-tree
map('n', '<leader>n', '<cmd>Neotree<CR>')

-- Toggle nvim-tree
map('n', '<leader>e', '<cmd>NvimTreeToggle<CR>')


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
-- NVIMTREE
-- =====================================================

-- Disable netrw before nvim-tree loads
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

local ok, nvimtree = pcall(require, 'nvim-tree')
if ok then
  local HEIGHT_RATIO = 0.8
  local WIDTH_RATIO  = 0.5

  nvimtree.setup({
    disable_netrw     = true,
    hijack_netrw      = true,
    respect_buf_cwd   = true,
    sync_root_with_cwd = true,
    view = {
      relativenumber = true,
      float = {
        enable = true,
        open_win_config = function()
          local screen_w   = vim.opt.columns:get()
          local screen_h   = vim.opt.lines:get() - vim.opt.cmdheight:get()
          local window_w   = screen_w * WIDTH_RATIO
          local window_h   = screen_h * HEIGHT_RATIO
          local window_w_int = math.floor(window_w)
          local window_h_int = math.floor(window_h)
          local center_x   = (screen_w - window_w) / 2
          local center_y   = ((vim.opt.lines:get() - window_h) / 2)
                             - vim.opt.cmdheight:get()
          return {
            border   = 'rounded',
            relative = 'editor',
            row      = center_y,
            col      = center_x,
            width    = window_w_int,
            height   = window_h_int,
          }
        end,
      },
      width = function()
        return math.floor(vim.opt.columns:get() * WIDTH_RATIO)
      end,
    },
  })
end
