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
}

utils.enable_set_root_autocmd(false)
