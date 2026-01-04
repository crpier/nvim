return {
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "default",
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<Tab>"] = { "accept", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        -- nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "buffer"},
        providers = {
        },
      },
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = {
            border = "single",
          },
        },
        menu = {
          border = "single",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      signature = {
        enabled = true,
        window = {
          border = "single",
        },
      },
    },
  },
}
