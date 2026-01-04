---@module 'obsidian'
---@param note obsidian.Note
local function id_from_h1(note)
  local out = { id = note.id, aliases = note.aliases, tags = note.tags }

  -- Extract first H1 header from content
  if note.contents then
    for _, line in ipairs(note.contents) do
      -- Match lines starting with "# " (single hash + space = H1)
      local h1_text = line:match "^#%s+(.+)$"
      if h1_text then
        out.id = h1_text
        break -- Stop after first H1
      end
    end
  end

  -- Preserve any custom metadata
  if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
    for k, v in pairs(note.metadata) do
      out[k] = v
    end
  end

  return out
end

return {
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = {
      keymaps = {
        useDefaults = true,
      },
    },
    keys = {
      {
        "dsi",
        function()
          -- select outer indentation
          require("various-textobjs").indentation("outer", "outer")

          -- plugin only switches to visual mode when a textobj has been found
          local indentationFound = vim.fn.mode():find "V"
          if not indentationFound then
            return
          end

          -- dedent indentation
          vim.cmd.normal { "<", bang = true }

          -- delete surrounding lines
          local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
          local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
          vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
          vim.cmd(tostring(startBorderLn) .. " delete")
        end,
        mode = "n",
        desc = "Delete Surrounding Indentation",
      },
      {
        ">p",
        function()
          require("various-textobjs").lastChange()
          local changeFound = vim.fn.mode():find "v"
          if changeFound then
            vim.cmd.normal { ">", bang = true }
          end
        end,
        desc = "Indent last paste",
      },
      {
        "<p",
        function()
          require("various-textobjs").lastChange()
          local changeFound = vim.fn.mode():find "v"
          if changeFound then
            vim.cmd.normal { "<", bang = true }
          end
        end,
        desc = "Unindent last paste",
      },
    },
  },
  {
    "folke/snacks.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = {
      {
        "<leader>bd",
        function()
          require("snacks").bufdelete()
        end,
        desc = "Close buffer (like `:bd` but smart)",
      },
      {
        "yot",
        function()
          if require("snacks.dim").enabled then
            require("snacks.dim").disable()
          else
            require("snacks.dim").enable()
          end
        end,
        desc = "Toggle dimming",
      },
      {
        "<leader>lg",
        function()
          require("snacks.lazygit").open()
        end,
        desc = "Open lazygit",
      },
      -- TODO: add keymap for `snacks.debug.run()` inside the scratch buffer
      {
        "<leader>.",
        function()
          require("snacks").scratch()
        end,
        desc = "Toggle Scratch Buffer",
      },
      {
        "<leader>S",
        function()
          require("snacks").scratch.select()
        end,
        desc = "Select Scratch Buffer",
      },
      {
        "<C-/>",
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "Toggle bottom terminal",
      },
      {
        "sf",
        function()
          require("snacks").picker.git_files()
        end,
        desc = "Search git files",
      },
      {
        "sF",
        function()
          require("snacks").picker.files { hidden = true }
        end,
        desc = "Find all files (including hidden)",
      },
      {
        "stp",
        function()
          require("snacks").picker.git_files { search = "!tests .py" }
        end,
        desc = "Search Python files (excluding tests)",
      },
      {
        "stP",
        function()
          require("snacks").picker.git_files { search = "'tests .py" }
        end,
        desc = "Search Python test files only",
      },
      {
        "stl",
        function()
          require("snacks").picker.git_files { search = "'.lua" }
        end,
        desc = "Search Lua files",
      },
      {
        "sl",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Search live grep",
      },
      {
        "su",
        function()
          require("snacks").picker.lines()
        end,
        desc = "Fuzzy find in current buffer",
      },
      {
        "so",
        function()
          require("snacks").picker.recent()
        end,
        desc = "Search old files",
      },
      {
        "s/",
        function()
          local search = vim.fn.input "Grep > "
          if search ~= "" then
            -- Execute grep and show results in a picker for filtering
            local cmd = { "rg", "--vimgrep", "--smart-case", search }
            local results = vim.fn.systemlist(cmd)

            if #results == 0 then
              vim.notify("No matches found for: " .. search, vim.log.levels.WARN)
              return
            end

            local items = {}
            for _, line in ipairs(results) do
              -- Parse rg output: filename:line:col:text
              local file, lnum, col, text = line:match "^([^:]+):(%d+):(%d+):(.*)$"
              if file then
                table.insert(items, {
                  file = file,
                  pos = { tonumber(lnum), tonumber(col) - 1 }, -- 0-indexed column
                  text = string.format("%s:%s: %s", file, lnum, text),
                })
              end
            end

            require("snacks").picker.pick {
              title = "Grep Results: " .. search,
              items = items,
              format = "file",
            }
          end
        end,
        desc = "Search word from user input",
      },
      {
        "sd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "Open all diagnostics",
      },
      {
        "sk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "Search all keymaps",
      },
      {
        "s<space>",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "Search buffers",
      },
      {
        "sw",
        function()
          require("snacks").picker.grep_word()
        end,
        desc = "Search word under cursor",
      },
      {
        "sm",
        function()
          require("snacks").picker.marks()
        end,
        desc = "Search marks",
      },
      {
        "sgc",
        function()
          require("snacks").picker.git_status()
        end,
        desc = "Search files with git changes",
      },
      {
        "sgb",
        function()
          require("snacks").picker.git_branches()
        end,
        desc = "Search git branches",
      },
      {
        "sp",
        function()
          -- Get project base dirs from config
          local project_base_dirs = {
            { path = "~/Projects", max_depth = 2 },
            "~/.config/nvim",
            "~/.dotfiles",
            "~/vault",
          }
          for _, v in ipairs(require("config.utils").load_local_options().project_base_dirs) do
            table.insert(project_base_dirs, v)
          end

          -- Find all git projects
          local search_paths = {}
          for _, dir in ipairs(project_base_dirs) do
            local path = type(dir) == "table" and dir.path or dir
            local depth = type(dir) == "table" and dir.max_depth or 1
            -- Expand ~ to home directory
            path = vim.fn.expand(path)
            if vim.fn.isdirectory(path) == 1 then
              -- Run fd for each base dir with its max_depth
              local cmd = { "fd", "-H", "-t", "d", "-d", tostring(depth), "^\\.git$", path }
              local git_dirs = vim.fn.systemlist(cmd)
              for _, git_dir in ipairs(git_dirs) do
                -- Remove trailing slash if present
                git_dir = git_dir:gsub("/$", "")
                -- Get parent directory (the actual project dir)
                local project_dir = vim.fn.fnamemodify(git_dir, ":h")
                table.insert(search_paths, project_dir)
              end
            end
          end

          if #search_paths == 0 then
            vim.notify("No projects found", vim.log.levels.WARN)
            return
          end

          -- Create items for picker
          local items = {}
          for _, project_path in ipairs(search_paths) do
            local name = vim.fn.fnamemodify(project_path, ":t")
            table.insert(items, {
              text = string.format("%-30s  %s", name, project_path),
              file = project_path, -- For preview - will show directory contents
              path = project_path,
              name = name,
            })
          end

          local Snacks = require "snacks"
          Snacks.picker.pick {
            title = "Projects",
            items = items,
            format = "text",
            confirm = function(picker, item)
              local path = item.path
              if not path then
                vim.notify("Error: Could not determine project path", vim.log.levels.ERROR)
                return
              end
              picker:close()
              vim.cmd("cd " .. vim.fn.fnameescape(path))
              vim.notify("Changed to: " .. path)
              -- Open file picker in the new directory
              vim.schedule(function()
                -- Explicitly pass the current working directory
                Snacks.picker.files { cwd = vim.fn.getcwd() }
              end)
            end,
          }
        end,
        desc = "Search projects",
      },
      {
        "sra",
        function()
          require("snacks").picker.registers()
        end,
        desc = "Search registers",
      },
      {
        "srd",
        function()
          -- Custom picker for registers 0-9 only
          local Snacks = require "snacks"
          local registers = {}
          for i = 0, 9 do
            local reg = tostring(i)
            local value = vim.fn.getreg(reg)
            if value ~= "" then
              table.insert(registers, {
                text = string.format("[%s] %s", reg, value:gsub("\n", "\\n")),
                register = reg,
              })
            end
          end

          Snacks.picker.pick {
            title = "Registers 0-9 (Yank/Delete)",
            items = registers,
            format = "text",
            confirm = function(item)
              vim.fn.setreg('"', vim.fn.getreg(item.register))
              vim.cmd 'normal! ""p'
            end,
          }
        end,
        desc = "Search registers 0-9 (yank/delete only)",
      },
    },
    ---@type snacks.Config
    opts = {
      statuscolumn = {
        enabled = true,
        left = { "mark", "sign" }, -- priority of signs on the left (high to low)
        right = { "fold", "git" }, -- priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          patterns = { "GitSign" }, -- patterns to match for git signs
        },
        refresh = 50, -- refresh at most every 50ms
      },
      bigfile = {},
      dim = {},
      terminal = {},
      quickfile = {},
      lazygit = {},
      input = {},
      scope = {},
      -- TODO: allow executing python scratch (with uv!)
      scratch = {},
      picker = {
        ui = {
          icons = {
            enabled = true,
          },
        },
        formatters = {
          file = {
            filename_first = true,
          },
        },
        sources = {
          explorer = {},
        },
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    cmd = { "Obsidian" },
    keys = {
      { "<leader>of", "<cmd>Obsidian quick_switch<cr>", desc = "Open notes" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Create new note" },
      { "<leader>odd", "<cmd>Obsidian dailies<cr>", desc = "Open daily notes picker" },
      { "<leader>ody", "<cmd>Obsidian yesterday<cr>", desc = "Open yesterday's daily note" },
      { "<leader>odo", "<cmd>Obsidian tomorrow<cr>", desc = "Open tomorrow's daily note" },
      { "<leader>ot", "<cmd>Obsidian today<cr>", desc = "Open today's daily note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Live grep through notes" },
      { "<leader>oa", "<cmd>Obsidian tags<cr>", desc = "Open note tags picker" },
      { "<leader>orn", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      workspaces = {
        {
          name = "vault",
          path = "~/vault",
        },
      },
      templates = {
        folder = "templates",
      },
      daily_notes = {
        folder = "daybook",
        date_format = "%Y-%m/%Y-%m-%d",
        template = "daybook.md",
      },
      note_id_func = function(title)
        return title
      end,
      frontmatter = { enabled = true, func = id_from_h1 },
      ui = {
        enable = false,
      },
      legacy_commands = false,

      notes_subdir = "limbo",
      new_notes_location = "notes_subdir",

      completion = {
        blink = true,
        min_chars = 2,
      },
    },
  },
}
-- TODO: mb add keymap for snacks "lazy" picker
-- TODO: don't show an error when previewing an empty file
