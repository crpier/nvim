local ok, cmp = pcall(require, "cmp")

if ok then
  local function border(hl_name)
    return {
      { "╭", hl_name },
      { "─", hl_name },
      { "╮", hl_name },
      { "│", hl_name },
      { "╯", hl_name },
      { "─", hl_name },
      { "╰", hl_name },
      { "│", hl_name },
    }
  end

  cmp.setup {
    window = {
      completion = cmp.config.window.bordered { border = "single" },
      documentation = cmp.config.window.bordered { border = "single" },
    },
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    mapping = cmp.mapping.preset.insert {
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<Tab>"] = cmp.mapping.confirm { select = true },
    },
    sources = cmp.config.sources({
      { name = "cmp_ai" },
      { name = "nvim_lsp" },
      { name = "luasnip" }, -- For luasnip users.
    }, {
      { name = "buffer" },
      { name = "path" },
      { name = "emoji" },
    }),
  }

  -- Snippets
  local ok_ls, ls = pcall(require, "luasnip")
  if ok_ls then
    local ok_ls_loader, ls_loader = pcall(require, "luasnip.loaders.from_vscode")
    if ok_ls_loader then
      ls_loader.lazy_load()
    end
    -- <c-k> is my expansion key
    -- this will expand the current item or jump to the next item within the snippet.
    vim.keymap.set({ "i", "s" }, "<c-k>", function()
      if ls.expand_or_jumpable() then
        ls.expand_or_jump()
      end
    end, { silent = true })

    -- <c-j> is my jump backwards key.
    -- this always moves to the previous item within the snippet
    vim.keymap.set({ "i", "s" }, "<c-j>", function()
      if ls.jumpable(-1) then
        ls.jump(-1)
      end
    end, { silent = true })

    -- <c-l> is selecting within a list of options.
    -- This is useful for choice nodes (introduced in the forthcoming episode 2)
    vim.keymap.set("i", "<c-l>", function()
      if ls.choice_active() then
        ls.change_choice(1)
      end
    end)
  end
end

local ok_supermaven, supermaven = pcall(require, "supermaven-nvim")
if ok_supermaven then
  supermaven.setup {
    keymaps = {
      accept_suggestion = "<S-Tab>",
      clear_suggestion = "<C-BS>",
      accept_word = "<C-Tab>",
    },
  }
end
