local M = {}

local features = {
  "config.theme",
  "config.lsp",
  "config.formatting",
  "config.linting",
  "config.osc52",
  "config.simple_harpoon",
  "config.simple_bufferline",
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
