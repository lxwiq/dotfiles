-- Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- General autocommands
local general = augroup("General", { clear = true })

-- Highlight on yank
autocmd("TextYankPost", {
  group = general,
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Remove whitespace on save
autocmd("BufWritePre", {
  group = general,
  pattern = "*",
  command = ":%s/\\s\\+$//e",
})

-- Don't auto comment new lines
autocmd("BufEnter", {
  group = general,
  pattern = "*",
  command = "set fo-=c fo-=r fo-=o",
})

-- Restore cursor position
autocmd("BufReadPost", {
  group = general,
  pattern = "*",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- File type specific settings
local filetypes = augroup("FileTypes", { clear = true })

-- Set indentation for specific file types
autocmd("FileType", {
  group = filetypes,
  pattern = { "html", "css", "scss", "javascript", "typescript", "typescriptreact", "json", "yaml" },
  command = "setlocal tabstop=2 shiftwidth=2 expandtab",
})

autocmd("FileType", {
  group = filetypes,
  pattern = { "rust" },
  command = "setlocal tabstop=4 shiftwidth=4 expandtab",
})

-- Set wrap and spell for text files
autocmd("FileType", {
  group = filetypes,
  pattern = { "markdown", "text" },
  command = "setlocal wrap linebreak spell spelllang=en",
})

-- Angular specific settings
autocmd("FileType", {
  group = filetypes,
  pattern = { "typescript", "typescriptreact", "html" },
  callback = function()
    -- Set Angular-specific settings here
    vim.opt_local.path:append("src")
    vim.opt_local.includeexpr = "substitute(v:fname, '^@/', 'src/', '')"
  end,
})

-- Terminal settings
local terminal = augroup("Terminal", { clear = true })

-- Enter insert mode when opening terminal
autocmd("TermOpen", {
  group = terminal,
  pattern = "*",
  command = "startinsert",
})

-- Don't show line numbers in terminal
autocmd("TermOpen", {
  group = terminal,
  pattern = "*",
  command = "setlocal nonumber norelativenumber signcolumn=no",
})

-- LSP autocommands
local lsp = augroup("LSP", { clear = true })

-- Show diagnostics on hover
autocmd("CursorHold", {
  group = lsp,
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      border = "rounded",
      source = "always",
      prefix = " ",
      scope = "cursor",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})
