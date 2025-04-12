return {

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-emoji",
    },
    -- TODO: lazy load based on some other event I guess?
    event = "VeryLazy",
    config = function()
      local cmp = require "cmp"
      cmp.setup {
        window = {
          completion = cmp.config.window.bordered { border = "single" },
          documentation = cmp.config.window.bordered { border = "single" },
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<Tab>"] = cmp.mapping.confirm { select = true },
        },
        sources = cmp.config.sources({
          { name = "cmp_ai" },
          { name = "nvim_lsp" },
        }, {
          { name = "buffer" },
          { name = "path" },
          { name = "emoji" },
        }),
      }
    end,
  },
}
