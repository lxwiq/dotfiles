-- Core Neovim settings

local opt = vim.opt
local g = vim.g

-- Leader key
g.mapleader = " "
g.maplocalleader = " "

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
-- Utiliser le presse-papiers du système
if vim.fn.has('mac') == 1 then
  opt.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 0,
  }
else
  opt.clipboard:append("unnamedplus")
end

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Scroll settings
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Update time
opt.updatetime = 100

-- Disable swap and backup files
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Persistent undo
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- Completion
opt.completeopt = "menu,menuone,noselect"

-- Wild menu
opt.wildmenu = true
opt.wildmode = "longest:full,full"

-- Encoding
opt.fileencoding = "utf-8"
opt.encoding = "utf-8"

-- Mouse support
opt.mouse = "a"

-- Netrw settings (built-in file explorer)
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 0
g.netrw_winsize = 25

-- Disable providers we don't need
g.loaded_python3_provider = 0
g.loaded_ruby_provider = 0
g.loaded_perl_provider = 0
g.loaded_node_provider = 0
