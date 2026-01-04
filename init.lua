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
-- TODO: investigate: is `yod` (Toggle diff) helpful?
