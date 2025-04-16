-- Markdown specific plugins and configuration

return {
  -- Markdown language server is configured in lsp.lua

  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
      vim.g.mkdp_refresh_slow = 0
      vim.g.mkdp_command_for_global = 0
      vim.g.mkdp_open_to_the_world = 0
      vim.g.mkdp_open_ip = ""
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = 0
      vim.g.mkdp_browserfunc = ""
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        disable_sync_scroll = 0,
        sync_scroll_type = "middle",
        hide_yaml_meta = 1,
        sequence_diagrams = {},
        flowchart_diagrams = {},
        content_editable = false,
        disable_filename = 0,
        toc = {},
      }
      vim.g.mkdp_markdown_css = ""
      vim.g.mkdp_highlight_css = ""
      vim.g.mkdp_port = ""
      vim.g.mkdp_page_title = "${name}"
      vim.g.mkdp_filetypes = { "markdown" }
      vim.g.mkdp_theme = "dark"
    end,
  },

  -- Markdown table mode
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    config = function()
      vim.g.table_mode_corner = "|"
      vim.g.table_mode_corner_corner = "+"
      vim.g.table_mode_header_fillchar = "-"
    end,
  },

  -- Markdown TOC generator
  {
    "mzlogin/vim-markdown-toc",
    ft = { "markdown" },
    cmd = { "GenTocGFM", "GenTocRedcarpet", "GenTocGitLab", "UpdateToc" },
    config = function()
      vim.g.vmt_auto_update_on_save = 1
      vim.g.vmt_dont_insert_fence = 0
      vim.g.vmt_cycle_list_item_markers = 1
      vim.g.vmt_fence_text = "TOC"
      vim.g.vmt_fence_closing_text = "/TOC"
    end,
  },

  -- Markdown snippets
  {
    "L3MON4D3/LuaSnip",
    config = function()
      -- Create a directory for Markdown snippets
      local snippets_dir = vim.fn.stdpath("config") .. "/snippets/markdown"
      vim.fn.mkdir(snippets_dir, "p")

      -- Create Markdown header snippet
      local md_header = [[
{
  "Markdown Header": {
    "prefix": "header",
    "body": [
      "---",
      "title: ${1:Title}",
      "date: ${2:YYYY-MM-DD}",
      "tags: [${3:tag1, tag2}]",
      "---",
      "",
      "$0"
    ],
    "description": "Add YAML front matter header"
  }
}
      ]]

      -- Create Markdown table snippet
      local md_table = [[
{
  "Markdown Table": {
    "prefix": "table",
    "body": [
      "| ${1:Column1} | ${2:Column2} | ${3:Column3} |",
      "| --- | --- | --- |",
      "| ${4:Row1Cell1} | ${5:Row1Cell2} | ${6:Row1Cell3} |",
      "| ${7:Row2Cell1} | ${8:Row2Cell2} | ${9:Row2Cell3} |",
      "$0"
    ],
    "description": "Create a markdown table"
  }
}
      ]]

      -- Create Markdown link snippet
      local md_link = [[
{
  "Markdown Link": {
    "prefix": "link",
    "body": [
      "[${1:text}](${2:url})"
    ],
    "description": "Create a markdown link"
  }
}
      ]]

      -- Create Markdown image snippet
      local md_image = [[
{
  "Markdown Image": {
    "prefix": "image",
    "body": [
      "![${1:alt text}](${2:image_url})"
    ],
    "description": "Insert an image"
  }
}
      ]]

      -- Create Markdown code block snippet
      local md_code = [[
{
  "Markdown Code Block": {
    "prefix": "code",
    "body": [
      "```${1:language}",
      "${2:code}",
      "```",
      "$0"
    ],
    "description": "Insert a code block"
  }
}
      ]]

      -- Create Markdown task list snippet
      local md_tasks = [[
{
  "Markdown Task List": {
    "prefix": "tasks",
    "body": [
      "- [${1| ,x|}] ${2:Task 1}",
      "- [${3| ,x|}] ${4:Task 2}",
      "- [${5| ,x|}] ${6:Task 3}",
      "$0"
    ],
    "description": "Create a task list"
  }
}
      ]]

      -- Create Markdown TOC snippet
      local md_toc = [[
{
  "Markdown TOC": {
    "prefix": "toc",
    "body": [
      "<!-- TOC -->",
      "<!-- /TOC -->",
      "$0"
    ],
    "description": "Insert TOC markers"
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

      write_snippet("header.json", md_header)
      write_snippet("table.json", md_table)
      write_snippet("link.json", md_link)
      write_snippet("image.json", md_image)
      write_snippet("code.json", md_code)
      write_snippet("tasks.json", md_tasks)
      write_snippet("toc.json", md_toc)
    end,
  },

  -- Markdown concealing
  {
    "preservim/vim-markdown",
    ft = { "markdown" },
    dependencies = { "godlygeek/tabular" },
    config = function()
      vim.g.vim_markdown_folding_disabled = 1
      vim.g.vim_markdown_conceal = 1
      vim.g.vim_markdown_conceal_code_blocks = 0
      vim.g.vim_markdown_math = 1
      vim.g.vim_markdown_toml_frontmatter = 1
      vim.g.vim_markdown_frontmatter = 1
      vim.g.vim_markdown_strikethrough = 1
      vim.g.vim_markdown_autowrite = 1
      vim.g.vim_markdown_edit_url_in = "tab"
      vim.g.vim_markdown_follow_anchor = 1
      vim.g.vim_markdown_no_extensions_in_markdown = 1
      vim.g.vim_markdown_auto_insert_bullets = 1
      vim.g.vim_markdown_new_list_item_indent = 2
    end,
  },

  -- Télécharger les dictionnaires de vérification orthographique
  {
    "lewis6991/spellsitter.nvim",
    config = function()
      -- Créer le répertoire pour les dictionnaires
      vim.fn.mkdir(vim.fn.stdpath("config") .. "/spell", "p")

      -- Fonction pour télécharger un dictionnaire s'il n'existe pas déjà
      local function download_spell_file(lang, encoding)
        local spell_dir = vim.fn.stdpath("config") .. "/spell"
        local spell_file = spell_dir .. "/" .. lang .. "." .. encoding .. ".spl"

        if vim.fn.filereadable(spell_file) == 0 then
          vim.notify("Téléchargement du dictionnaire " .. lang .. "." .. encoding .. ".spl", vim.log.levels.INFO)
          vim.fn.system({
            "curl",
            "-fLo",
            spell_file,
            "https://ftp.nluug.nl/pub/vim/runtime/spell/" .. lang .. "." .. encoding .. ".spl"
          })

          -- Vérifier si le téléchargement a réussi
          if vim.fn.filereadable(spell_file) == 1 then
            vim.notify("Dictionnaire " .. lang .. "." .. encoding .. ".spl téléchargé avec succès", vim.log.levels.INFO)
          else
            vim.notify("Échec du téléchargement du dictionnaire " .. lang .. "." .. encoding .. ".spl", vim.log.levels.ERROR)
          end
        end
      end

      -- Télécharger les dictionnaires anglais et français
      download_spell_file("en", "utf-8")
      download_spell_file("fr", "utf-8")

      -- Configuration de spellsitter
      require("spellsitter").setup({
        enable = true,
        spellchecker = {
          enable = true,
          filetypes = { "markdown", "text" },
        },
      })
    end,
  },
}
