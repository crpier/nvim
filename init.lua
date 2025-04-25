vim.loader.enable()
local utils = require "config.utils"
utils.setup_lazy()

require "config.options"
require "config.basic_remaps"

-- Setup lazy.nvim
require("lazy").setup {
  spec = {
    -- import your plugins
    { import = "plugins" },
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  checker = { enabled = false },
  defaults = {
    lazy = true,
  },
  performance = {
    rtp = {
      -- Stuff I don't use.
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

utils.enable_set_root_autocmd(false)
-- TODO: would be cool to have a command like `no` that opens nvim on the last opened file
-- TODO: for this to work, I really should fix the fact when opening a file directly
--       many things (like lsp and cmp) don't work
-- TODO: investigate: is `yod` helpful?
-- TODO: telescope command to view keymaps, filtered by mode
-- TODO: make the statuscolumn wider and put different stuff in differnt columns (e.g. gitsigns, diagnostic)
