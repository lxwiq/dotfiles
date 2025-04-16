-- Rust specific plugins and configuration

return {
  -- Rust language server is configured in lsp.lua

  -- Rust tools
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
    },
    config = function()
      local rt = require("rust-tools")

      rt.setup({
        server = {
          on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "K", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<Leader>la", rt.code_action_group.code_action_group, { buffer = bufnr })
            -- Move item up/down
            vim.keymap.set("n", "<A-k>", function()
              vim.cmd.RustMoveItemUp()
            end, { buffer = bufnr, desc = "Move item up" })
            vim.keymap.set("n", "<A-j>", function()
              vim.cmd.RustMoveItemDown()
            end, { buffer = bufnr, desc = "Move item down" })
            -- Other keybindings
            vim.keymap.set("n", "<leader>re", rt.expand_macro.expand_macro, { buffer = bufnr, desc = "Expand macro" })
            vim.keymap.set(
              "n",
              "<leader>rp",
              "<cmd>RustParentModule<CR>",
              { buffer = bufnr, desc = "Go to parent module" }
            )
            vim.keymap.set("n", "<leader>rd", rt.debuggables.debuggables, { buffer = bufnr, desc = "Rust debuggables" })
            vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, { buffer = bufnr, desc = "Rust runnables" })
          end,
          settings = {
            -- rust-analyzer settings
            ["rust-analyzer"] = {
              -- enable clippy on save
              checkOnSave = {
                command = "clippy",
              },
              -- inlay hints
              inlayHints = {
                bindingModeHints = {
                  enable = true,
                },
                chainingHints = {
                  enable = true,
                },
                closingBraceHints = {
                  enable = true,
                  minLines = 25,
                },
                closureReturnTypeHints = {
                  enable = "always",
                },
                lifetimeElisionHints = {
                  enable = "always",
                  useParameterNames = true,
                },
                maxLength = 25,
                parameterHints = {
                  enable = true,
                },
                reborrowHints = {
                  enable = "always",
                },
                renderColons = true,
                typeHints = {
                  enable = true,
                  hideClosureInitialization = false,
                  hideNamedConstructor = false,
                },
              },
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                runBuildScripts = true,
              },
              -- procMacro = {
              --   enable = true,
              --   ignored = {
              --     ["async-trait"] = { "async_trait" },
              --     ["napi-derive"] = { "napi" },
              --     ["async-recursion"] = { "async_recursion" },
              --   },
              -- },
            },
          },
        },
        tools = {
          -- Automatically set inlay hints (type hints)
          autoSetHints = true,
          -- Whether to show hover actions inside the hover window
          hover_with_actions = true,
          -- These apply to the default RustRunnables command
          runnables = {
            -- Use telescope for selection menu
            use_telescope = true,
            -- rest of the opts are forwarded to telescope
          },
          -- These apply to the default RustDebuggables command
          debuggables = {
            -- Use telescope for selection menu
            use_telescope = true,
          },
          -- Options for hover actions
          hover_actions = {
            -- Whether the hover action window gets automatically focused
            auto_focus = false,
            -- Border style for hover actions window
            border = "rounded",
          },
          -- settings for showing the crate graph based on graphviz and the dot
          -- command
          crate_graph = {
            -- Backend used for displaying the graph
            -- see: https://graphviz.org/docs/outputs/
            -- default: x11
            backend = "x11",
            -- where to store the output, nil for no output stored (relative
            -- path from pwd)
            -- default: nil
            output = nil,
            -- true for all crates.io and external crates, false only the local
            -- crates
            -- default: true
            full = true,
            -- List of backends found on: https://graphviz.org/docs/outputs/
            -- Is used for input validation and autocompletion
            -- Last updated: 2021-08-26
            enabled_graphviz_backends = {
              "bmp",
              "cgimage",
              "canon",
              "dot",
              "gv",
              "xdot",
              "xdot1.2",
              "xdot1.4",
              "eps",
              "exr",
              "fig",
              "gd",
              "gd2",
              "gif",
              "gtk",
              "ico",
              "cmap",
              "ismap",
              "imap",
              "cmapx",
              "imap_np",
              "cmapx_np",
              "jpg",
              "jpeg",
              "jpe",
              "jp2",
              "json",
              "json0",
              "dot_json",
              "xdot_json",
              "pdf",
              "pic",
              "pct",
              "pict",
              "plain",
              "plain-ext",
              "png",
              "pov",
              "ps",
              "ps2",
              "psd",
              "sgi",
              "svg",
              "svgz",
              "tga",
              "tiff",
              "tif",
              "tk",
              "vml",
              "vmlz",
              "wbmp",
              "webp",
              "xlib",
              "x11",
            },
          },
        },
        -- All the opts to send to nvim-lspconfig
        -- These override the defaults set by rust-tools.nvim
        -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
        dap = {
          adapter = {
            type = "executable",
            command = "lldb-vscode",
            name = "rt_lldb",
          },
        },
      })
    end,
  },

  -- Crates.io integration
  {
    "saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
        popup = {
          border = "rounded",
        },
      })
    end,
  },

  -- Rust snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Create a directory for Rust snippets
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets/rust"
      vim.fn.mkdir(snippets_dir, "p")

      -- Create Rust struct snippet
      local rust_struct = [[
{
  "Rust Struct": {
    "prefix": "struct",
    "body": [
      "struct ${1:Name} {",
      "    ${2:field}: ${3:Type},",
      "    $0",
      "}"
    ],
    "description": "Create a struct"
  }
}
      ]]

      -- Create Rust impl snippet
      local rust_impl = [[
{
  "Rust Implementation": {
    "prefix": "impl",
    "body": [
      "impl ${1:Type} {",
      "    $0",
      "}"
    ],
    "description": "Create an implementation block"
  }
}
      ]]

      -- Create Rust trait snippet
      local rust_trait = [[
{
  "Rust Trait": {
    "prefix": "trait",
    "body": [
      "trait ${1:Name} {",
      "    $0",
      "}"
    ],
    "description": "Create a trait"
  }
}
      ]]

      -- Create Rust enum snippet
      local rust_enum = [[
{
  "Rust Enum": {
    "prefix": "enum",
    "body": [
      "enum ${1:Name} {",
      "    ${2:Variant},",
      "    $0",
      "}"
    ],
    "description": "Create an enum"
  }
}
      ]]

      -- Create Rust function snippet
      local rust_fn = [[
{
  "Rust Function": {
    "prefix": "fn",
    "body": [
      "fn ${1:name}(${2:args}) ${3:-> ${4:ReturnType} }{",
      "    $0",
      "}"
    ],
    "description": "Create a function"
  }
}
      ]]

      -- Create Rust test snippet
      local rust_test = [[
{
  "Rust Test": {
    "prefix": "test",
    "body": [
      "#[test]",
      "fn ${1:test_name}() {",
      "    $0",
      "}"
    ],
    "description": "Create a test function"
  }
}
      ]]

      -- Create Rust derive snippet
      local rust_derive = [[
{
  "Rust Derive": {
    "prefix": "derive",
    "body": [
      "#[derive(${1:Debug, Clone})]",
      "$0"
    ],
    "description": "Add derive attribute"
  }
}
      ]]

      -- Write snippets to files
      local function write_snippet(filename, content)
        local file = io.open(snippets_dir .. "/" .. filename, "w")
        if file then
          file:write(content)
          file:close()
        end
      end

      write_snippet("struct.json", rust_struct)
      write_snippet("impl.json", rust_impl)
      write_snippet("trait.json", rust_trait)
      write_snippet("enum.json", rust_enum)
      write_snippet("fn.json", rust_fn)
      write_snippet("test.json", rust_test)
      write_snippet("derive.json", rust_derive)
    end,
  },
}
