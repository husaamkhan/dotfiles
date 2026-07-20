"""""""""""""""""""""""
"  VIM MASTER CONFIG  "
"""""""""""""""""""""""

" SECTIONS:
"   PLUGINS
"   SETTINGS
"   KEYMAPS
"   LSP
"   AIRLINE


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" PLUGINS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" theme
Plug 'morhetz/gruvbox'
Plug 'Shatur/neovim-ayu'

" Telescope
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

" LSP
Plug 'neovim/nvim-lspconfig'

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" SETTINGS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set background=dark
colorscheme ayu-dark

set relativenumber
set number

" Show tabs and file status + open file name on top
set showtabline=2
set laststatus=2

set scrolloff=8

set encoding=utf-8

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

"set tabstop=4
"set softtabstop=4
"set shiftwidth=4
set smartindent
"set autoindent

set termguicolors

" Prevents cursor from changing from solid rectangle
set guicursor=

if g:colors_name ==# 'ayu'
  highlight LineNr guifg=#8A9199
  highlight CursorLineNr guifg=#E6B450 gui=bold

  highlight Visual guibg=#3E4B59
  highlight VisualNOS guibg=#3E4B59
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" KEYMAPS
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader = " "

""" BUFFERS """
" Switch to next/previous buffer
nnoremap <leader>bn :bn<CR>
nnoremap <leader>bp :bp<CR>

" Open new buffer
nnoremap <leader>be :e 

" Close buffer
nnoremap <leader>bc :bw

" Open fuzzy finder
nnoremap <leader>F <cmd>Telescope find_files<CR>
nnoremap <leader>G  <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>

" Split current line into multiple indented lines
function! SplitLineIntoLines()
  let line = getline('.')
  let indent = matchstr(line, '^\s*')
  let inner_indent = indent . '    '
  let line = substitute(line, '{\s*', '{\n' . inner_indent, '')
  let line = substitute(line, '\s*,\s*', ',\n' . inner_indent, 'g')
  let line = substitute(line, '\s*}$', '\n' . indent . '}', '')
  let lines = split(line, '\n')
  call setline('.', lines[0])
  call append('.', lines[1:])
endfunction
nnoremap <leader>Js :call SplitLineIntoLines()<CR>

" Split chained method calls on dots onto indented new lines
function! SplitOnDots()
  let line = getline('.')
  let indent = matchstr(line, '^\s*')
  let parts = split(line, '\.')
  call setline('.', parts[0])
  call append('.', map(parts[1:], {_, v -> indent . '    .' . v}))
endfunction
nnoremap <leader>Jd :call SplitOnDots()<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LSP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set updatetime=300
set signcolumn=yes

lua << EOF
-- prevent the built-in vim.lsp.completion autotrigger from selecting the first item
vim.opt.completeopt = { "menuone", "noselect", "popup" }

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
})

local on_attach = function(client, bufnr)
  client.server_capabilities.semanticTokensProvider = nil
  local opts = { buffer = bufnr, silent = true }

  vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
  vim.keymap.set('i', '<C-Space>', vim.lsp.completion.get, opts)
  -- trigger LSP completion after typing 1+ keyword character
  vim.api.nvim_create_autocmd('TextChangedI', {
    buffer = bufnr,
    callback = function()
      local word = vim.fn.matchstr(vim.fn.getline('.'), '\\k\\+$')
      if #word >= 1 then vim.lsp.completion.get() end
    end,
  })

  vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,     opts)
  vim.keymap.set('n', 'gy',         vim.lsp.buf.type_definition, opts)
  vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,  opts)
  vim.keymap.set('n', 'gr',         vim.lsp.buf.references,      opts)
  vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename,          opts)
  vim.keymap.set('n', '<leader>ac', vim.lsp.buf.code_action,     opts)
  vim.keymap.set('n', '<leader>f',  vim.lsp.buf.format,          opts)
  vim.keymap.set('n', '[g',         vim.diagnostic.goto_prev,    opts)
  vim.keymap.set('n', ']g',         vim.diagnostic.goto_next,    opts)

  vim.keymap.set('i', '<Tab>',   function()
    return vim.fn.pumvisible() == 1 and '<C-n>' or '<Tab>'
  end, { buffer = bufnr, expr = true })
  vim.keymap.set('i', '<S-Tab>', function()
    return vim.fn.pumvisible() == 1 and '<C-p>' or '<S-Tab>'
  end, { buffer = bufnr, expr = true })
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c', 'cpp' },
  callback = function()
    vim.lsp.start({
      name = 'clangd',
      cmd = { 'clangd' },
      on_attach = on_attach,
      root_dir = vim.fs.root(0, { '.git', 'Makefile', 'compile_commands.json' }),
    })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python' },
  callback = function()
    vim.lsp.start({
      name = 'pylsp',
      cmd = { 'pylsp' },
      on_attach = on_attach,
      root_dir = vim.fs.root(0, { '.git', 'setup.py', 'pyproject.toml' }),
    })
  end,
})
EOF


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" AIRLINE
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='minimalist'
