local border = {
  { "╭", "Normal" },
  { "─", "Normal" },
  { "╮", "Normal" },
  { "│", "Normal" },
  { "╯", "Normal" },
  { "─", "Normal" },
  { "╰", "Normal" },
  { "│", "Normal" },
}

local handlers = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single", style = "minimal" }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

-- TODO: can I lazy load mason?
return {
  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "SmiteshP/nvim-navic",
      "neovim/nvim-lspconfig",
      "j-hui/fidget.nvim",
    },
    lazy = false,
    config = function()
      local mason = require "mason"
      mason.setup()
      require("mason-lspconfig").setup {
        ensure_installed = {
          "pyright",
        },
      }
      local navic = require "nvim-navic"
      navic.setup {}
      -- local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()
      local lsp_attach = function(client, bufnr)
        if client.server_capabilities.documentSymbolProvider then
          navic.attach(client, bufnr)
        end
      end
      local lspconfig = require "lspconfig"
      require("mason-lspconfig").setup_handlers {
        function(server_name)
          lspconfig[server_name].setup {
            on_attach = lsp_attach,
            -- capabilities = lsp_capabilities,
            handlers = handlers,
          }
        end,
      }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition)
      vim.keymap.set("n", "K", vim.lsp.buf.hover)
      vim.keymap.set("n", "gr", vim.lsp.buf.references)
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump { count = 1, float = true }
      end)
      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump { count = -1, float = true }
      end)
      vim.keymap.set("n", "d;", vim.diagnostic.open_float)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
      vim.keymap.set("n", "<leader>li", "<cmd>LspInfo<CR>")
      vim.keymap.set("n", "<leader>lr", "<cmd>LspRestart<CR>")

      vim.diagnostic.config {
        float = {
          source = true,
          border = "rounded",
        },
      }
      require("fidget").setup {}
    end,
  },

  {
    "mfussenegger/nvim-lint",
    lazy = false,
    config = function()
      local lint = require "lint"
      -- Enable linters
      -- TODO: ensure these are installed by Mason, but not on SSH
      lint.linters_by_ft = lint.linters_by_ft or {}
      -- TODO: use hadolint if available
      lint.linters_by_ft["dockerfile"] = nil
      -- TODO: use jsonlint if available
      lint.linters_by_ft["json"] = nil
      lint.linters_by_ft["terraform"] = { "tflint" }
      lint.linters_by_ft["lua"] = { "luacheck" }
      lint.linters_by_ft["python"] = { "mypy", "ruff" }

      -- Disable default linters
      lint.linters_by_ft["markdown"] = nil
      lint.linters_by_ft["text"] = nil
      lint.linters_by_ft["clojure"] = nil
      lint.linters_by_ft["inko"] = nil
      lint.linters_by_ft["janet"] = nil
      lint.linters_by_ft["rst"] = nil
      lint.linters_by_ft["ruby"] = nil
      lint.linters_by_ft["Avante"] = nil

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      -- TODO: experiment with more granular events
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require "conform"
      conform.setup {
        notify_on_error = true,
        formatters_by_ft = {
          lua = { "stylua" },
          python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
          markdown = { "markdownlint" },
          javascript = { "prettierd" },
          rust = { "rustfmt" },
          typescriptreact = { "prettierd" },
          go = { "gofmt" },
        },
      }
    end,
    keys = {
      {
        "gq",
        function()
          require("conform").format()
        end,
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  { -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
}
