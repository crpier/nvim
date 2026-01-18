return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis.
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "williamboman/mason.nvim", opts = { ensure_installed = {} } },
      { "williamboman/mason-lspconfig.nvim", opts = {} },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },
      "SmiteshP/nvim-navic",
    },
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          vim.keymap.set("n", "grn", vim.lsp.buf.rename, { buffer = event.buf, desc = "LSP: [R]e[n]ame" })
          vim.keymap.set(
            { "n", "x" },
            "gra",
            vim.lsp.buf.code_action,
            { buffer = event.buf, desc = "LSP: [G]oto Code [A]ction" }
          )
          vim.keymap.set("n", "grr", function()
            require("snacks").picker.lsp_references()
          end, { buffer = event.buf, desc = "LSP: [G]oto [R]eferences" })
          vim.keymap.set("n", "gri", function()
            require("snacks").picker.lsp_implementations()
          end, { buffer = event.buf, desc = "LSP: [G]oto [I]mplementation" })
          vim.keymap.set("n", "gd", function()
            require("snacks").picker.lsp_definitions()
          end, { buffer = event.buf, desc = "LSP: [G]oto [D]efinition" })
          vim.keymap.set(
            "n",
            "grD",
            vim.lsp.buf.declaration,
            { buffer = event.buf, desc = "LSP: [G]oto [D]eclaration" }
          )
          vim.keymap.set("n", "grs", function()
            require("snacks").picker.lsp_symbols()
          end, { buffer = event.buf, desc = "LSP: Open Document Symbols" })
          vim.keymap.set("n", "grt", function()
            require("snacks").picker.lsp_type_definitions()
          end, { buffer = event.buf, desc = "LSP: [G]oto [T]ype Definition" })
          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover { border = "rounded" }
          end, { buffer = event.buf, desc = "LSP: Hover" })
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has "nvim-0.11" == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = "kickstart-lsp-highlight", buffer = event2.buf }
              end,
            })
          end

          -- The following code creates a keymap to toggle inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            vim.keymap.set("n", "<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, { buffer = event.buf, desc = "LSP: [T]oggle Inlay [H]ints" })
          end

          -- Load `navic` for showing the current LSP symbol.
          -- Note that this doesn't automatically display the context, but only
          -- allows `navic` to retrieve it from the Language Server.
          -- Displaying the context is done in the statusline.
          if
            client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentSymbol, event.buf)
          then
            local navic = require "nvim-navic"
            navic.setup {}
            navic.attach(client, event.buf)
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config {
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }
      vim.keymap.set("n", "]d", function()
        vim.diagnostic.jump { count = 1, float = true }
      end, { desc = "Jump to next diagnostic" })

      vim.keymap.set("n", "[d", function()
        vim.diagnostic.jump { count = -1, float = true }
      end, { desc = "Jump to previous diagnostic" })

      vim.keymap.set("n", "]D", function()
        vim.diagnostic.jump { count = math.huge, wrap = false, float = true }
      end, { desc = "Jump to the last diagnostic in the current buffer" })

      vim.keymap.set("n", "[D", function()
        vim.diagnostic.jump { count = -math.huge, wrap = false, float = true }
      end, { desc = "Jump to the first diagnostic in the current buffer" })

      vim.keymap.set("n", "d;", vim.diagnostic.open_float)


      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      local servers = {
        -- Lua for Neovim configuration
        lua_ls = {},
        -- TypeScript/JavaScript
        ts_ls = {},
        -- Go
        gopls = {},
        -- Rust
        rust_analyzer = {},
        -- Terraform
        terraformls = {},
        -- Markdown
        marksman = {},
      }

      -- Ensure the servers and tools above are installed
      --
      -- To check the current status of installed tools and/or manually install
      -- other tools, you can run
      --    :Mason
      --
      -- Lbh pna cerff `t?` sbe uryc va guvf zrah.
      --
      -- `mason` had to be setup earlier: to configure its options see the
      -- `dependencies` table for `nvim-lspconfig` above.
      --
      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup { ensure_installed = ensure_installed }

      require("mason-lspconfig").setup {
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
