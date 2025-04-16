-- TypeScript specific plugins and configuration

return {
  -- TypeScript language server is configured in lsp.lua

  -- TypeScript tools
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = {
      "typescript",
      "javascript",
      "typescriptreact",
      "javascriptreact",
    },
    opts = {
      settings = {
        -- spawn additional server for big projects
        separate_diagnostic_server = true,
        -- specify a list of plugins to load by TypeScript server
        tsserver_plugins = {
          -- for TypeScript v4.9+
          "@styled/typescript-styled-plugin",
          -- or for older TypeScript versions
          -- "typescript-styled-plugin",
        },
        -- tsserver_max_memory = "auto",
        -- tsserver_format_options = {},
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },

  -- TypeScript snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Create a directory for TypeScript snippets
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets/typescript"
      vim.fn.mkdir(snippets_dir, "p")

      -- Create TypeScript class snippet
      local ts_class = [[
{
  "TypeScript Class": {
    "prefix": "class",
    "body": [
      "class ${1:Name} {",
      "  ${2:property}: ${3:type};",
      "",
      "  constructor(${4:parameters}) {",
      "    ${5:// initialization}",
      "  }",
      "",
      "  ${6:method}(${7:parameters}): ${8:returnType} {",
      "    ${0:// method body}",
      "  }",
      "}"
    ],
    "description": "Create a TypeScript class"
  }
}
      ]]

      -- Create TypeScript interface snippet
      local ts_interface = [[
{
  "TypeScript Interface": {
    "prefix": "interface",
    "body": [
      "interface ${1:Name} {",
      "  ${2:property}: ${3:type};",
      "  ${0}",
      "}"
    ],
    "description": "Create a TypeScript interface"
  }
}
      ]]

      -- Create TypeScript type snippet
      local ts_type = [[
{
  "TypeScript Type": {
    "prefix": "type",
    "body": [
      "type ${1:Name} = ${2:Type};"
    ],
    "description": "Create a TypeScript type"
  }
}
      ]]

      -- Create TypeScript enum snippet
      local ts_enum = [[
{
  "TypeScript Enum": {
    "prefix": "enum",
    "body": [
      "enum ${1:Name} {",
      "  ${2:Key} = ${3:Value},",
      "  ${0}",
      "}"
    ],
    "description": "Create a TypeScript enum"
  }
}
      ]]

      -- Create TypeScript function snippet
      local ts_function = [[
{
  "TypeScript Function": {
    "prefix": "function",
    "body": [
      "function ${1:name}(${2:parameters}): ${3:returnType} {",
      "  ${0:// function body}",
      "}"
    ],
    "description": "Create a TypeScript function"
  }
}
      ]]

      -- Create TypeScript arrow function snippet
      local ts_arrow = [[
{
  "TypeScript Arrow Function": {
    "prefix": "arrow",
    "body": [
      "const ${1:name} = (${2:parameters}): ${3:returnType} => {",
      "  ${0:// function body}",
      "};"
    ],
    "description": "Create a TypeScript arrow function"
  }
}
      ]]

      -- Create TypeScript async function snippet
      local ts_async = [[
{
  "TypeScript Async Function": {
    "prefix": "async",
    "body": [
      "async function ${1:name}(${2:parameters}): Promise<${3:returnType}> {",
      "  ${0:// function body}",
      "}"
    ],
    "description": "Create a TypeScript async function"
  }
}
      ]]

      -- Create TypeScript async arrow function snippet
      local ts_async_arrow = [[
{
  "TypeScript Async Arrow Function": {
    "prefix": "asyncarrow",
    "body": [
      "const ${1:name} = async (${2:parameters}): Promise<${3:returnType}> => {",
      "  ${0:// function body}",
      "};"
    ],
    "description": "Create a TypeScript async arrow function"
  }
}
      ]]

      -- Create TypeScript import snippet
      local ts_import = [[
{
  "TypeScript Import": {
    "prefix": "import",
    "body": [
      "import { ${2:module} } from '${1:package}';"
    ],
    "description": "Create a TypeScript import statement"
  }
}
      ]]

      -- Create TypeScript export snippet
      local ts_export = [[
{
  "TypeScript Export": {
    "prefix": "export",
    "body": [
      "export { ${1:module} };"
    ],
    "description": "Create a TypeScript export statement"
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

      write_snippet("class.json", ts_class)
      write_snippet("interface.json", ts_interface)
      write_snippet("type.json", ts_type)
      write_snippet("enum.json", ts_enum)
      write_snippet("function.json", ts_function)
      write_snippet("arrow.json", ts_arrow)
      write_snippet("async.json", ts_async)
      write_snippet("asyncarrow.json", ts_async_arrow)
      write_snippet("import.json", ts_import)
      write_snippet("export.json", ts_export)
    end,
  },
}
