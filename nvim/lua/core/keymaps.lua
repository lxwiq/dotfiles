-- Key mappings

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- General keymaps

-- Leader key is set to space in options.lua

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", opts) -- Left window
keymap.set("n", "<C-j>", "<C-w>j", opts) -- Down window
keymap.set("n", "<C-k>", "<C-w>k", opts) -- Up window
keymap.set("n", "<C-l>", "<C-w>l", opts) -- Right window

-- Resize windows with arrows
keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap.set("n", "<S-l>", ":bnext<CR>", opts)
keymap.set("n", "<S-h>", ":bprevious<CR>", opts)

-- Stay in indent mode when indenting
keymap.set("v", "<", "<gv", opts)
keymap.set("v", ">", ">gv", opts)

-- Move text up and down
keymap.set("v", "<A-j>", ":m .+1<CR>==", opts)
keymap.set("v", "<A-k>", ":m .-2<CR>==", opts)
keymap.set("v", "p", '"_dP', opts) -- Don't yank replaced text

-- Move text up and down in visual block mode
keymap.set("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap.set("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap.set("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Copier-coller avec les raccourcis standards
keymap.set("v", "<C-c>", "\"+y", opts)           -- Copier en mode visuel avec Ctrl+C
keymap.set("n", "<C-v>", "\"+p", opts)           -- Coller en mode normal avec Ctrl+V
keymap.set("i", "<C-v>", "<C-r>+", opts)         -- Coller en mode insertion avec Ctrl+V
keymap.set("c", "<C-v>", "<C-r>+", opts)         -- Coller en mode commande avec Ctrl+V
keymap.set("v", "<C-v>", "<C-r>+", opts)         -- Coller en mode visuel avec Ctrl+V

-- Clear search highlights
keymap.set("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Close buffer
keymap.set("n", "<leader>c", ":bd<CR>", opts)

-- Save file
keymap.set("n", "<leader>w", ":w<CR>", opts)

-- Quit
keymap.set("n", "<leader>q", ":q<CR>", opts)

-- Better terminal navigation
keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h", opts)
keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j", opts)
keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k", opts)
keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l", opts)

-- File explorer
keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Telescope (will be available after plugin installation)
keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap.set("n", "<leader>ft", ":Telescope live_grep<CR>", opts)
keymap.set("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>", opts)

-- LSP keymaps (will be available after LSP setup)
-- These will be set in the LSP on_attach function

-- Formatting
keymap.set("n", "<leader>fm", ":lua vim.lsp.buf.format()<CR>", opts)

-- Diagnostics
keymap.set("n", "<leader>d", ":lua vim.diagnostic.open_float()<CR>", opts)
keymap.set("n", "[d", ":lua vim.diagnostic.goto_prev()<CR>", opts)
keymap.set("n", "]d", ":lua vim.diagnostic.goto_next()<CR>", opts)

-- Terminal
keymap.set("n", "<leader>t", ":ToggleTerm<CR>", opts)

-- Markdown preview
keymap.set("n", "<leader>mp", ":MarkdownPreview<CR>", opts)
keymap.set("n", "<leader>ms", ":MarkdownPreviewStop<CR>", opts)

-- Git
keymap.set("n", "<leader>gg", ":LazyGit<CR>", opts)
keymap.set("n", "<leader>gj", ":lua require('gitsigns').next_hunk()<CR>", opts)
keymap.set("n", "<leader>gk", ":lua require('gitsigns').prev_hunk()<CR>", opts)
keymap.set("n", "<leader>gl", ":lua require('gitsigns').blame_line()<CR>", opts)
keymap.set("n", "<leader>gp", ":lua require('gitsigns').preview_hunk()<CR>", opts)
keymap.set("n", "<leader>gr", ":lua require('gitsigns').reset_hunk()<CR>", opts)
keymap.set("n", "<leader>gs", ":lua require('gitsigns').stage_hunk()<CR>", opts)
keymap.set("n", "<leader>gu", ":lua require('gitsigns').undo_stage_hunk()<CR>", opts)
keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>", opts)
