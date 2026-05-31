local M = {}

local features = {
  "config.osc52",
  "config.simple_harpoon",
  "config.todos",
  "config.text_helpers",
  "config.unimpaired",
  "config.statusline",
}

function M.setup()
  for _, feature in ipairs(features) do
    require(feature).setup()
  end
end

return M
