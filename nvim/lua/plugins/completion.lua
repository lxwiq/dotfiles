-- Autocompletion and snippets

return {
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",

      -- Additional user-friendly snippets
      "rafamadriz/friendly-snippets",

      -- Buffer and path completions
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Command line completion
      "hrsh7th/cmp-cmdline",

      -- Icons for completion menu
      "onsails/lspkind.nvim",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Add Angular snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/angular" } })

      -- Add Rust snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/rust" } })

      -- Add TypeScript snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/typescript" } })

      -- Add Markdown snippets
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets/markdown" } })

      -- Helper function for super-tab functionality (from TJ DeVries)
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"] = cmp.mapping.select_prev_item(), -- Previous suggestion
          ["<C-j>"] = cmp.mapping.select_next_item(), -- Next suggestion
          ["<C-b>"] = cmp.mapping.scroll_docs(-4), -- Scroll documentation up
          ["<C-f>"] = cmp.mapping.scroll_docs(4), -- Scroll documentation down
          ["<C-Space>"] = cmp.mapping.complete(), -- Show completion suggestions
          ["<C-e>"] = cmp.mapping.abort(), -- Close completion window
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item
          -- Super-Tab functionality
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        -- Sources for autocompletion
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 }, -- LSP
          { name = "luasnip", priority = 750 }, -- Snippets
          { name = "buffer", priority = 500 }, -- Text within current buffer
          { name = "path", priority = 250 }, -- File system paths
        }),
        -- Formatting of the completion menu
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "...",
            menu = {
              buffer = "[Buffer]",
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]",
              path = "[Path]",
            },
          }),
        },
        -- Window appearance
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- Completion behavior
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        -- Experimental features
        experimental = {
          ghost_text = true,
        },
      })

      -- Set configuration for specific filetype
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "buffer" },
        }),
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore)
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore)
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          { name = "cmdline" },
        }),
      })
    end,
  },
}
