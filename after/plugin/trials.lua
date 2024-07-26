local ok_twilight, twilight = pcall(require, "twilight")
if ok_twilight then
  twilight.setup {}
end

-- local otter = require "otter"
-- otter.setup {}
--
-- vim.api.nvim_create_autocmd({ "BufEnter" }, {
--   pattern = { "*.py" },
--   callback = function()
--     require("otter").activate(
--       nil,
--       nil,
--       nil,
--       [[
--       (assignment right: 
--   (call function: (identifier) @foo (#eq? @foo "js") 
--     arguments: (argument_list (string (string_content) @injection.content)
--     (#set! injection.language "javascript")
--     )
--   )
-- )
--
--     ]]
--     )
--   end,
-- })
--
-- require('go').setup({})
