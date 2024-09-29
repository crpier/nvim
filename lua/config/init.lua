local helpers = require "config.helpers"
helpers.setup_lazy()

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
