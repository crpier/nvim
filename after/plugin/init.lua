------ LSP ------
require('neodev').setup()
local lsp = require("lsp-zero")
lsp.preset("recommended")
lsp.ensure_installed({
    'sumneko_lua',
    'pyright',
    'gopls'
})
lsp.set_preferences({
    sign_icons = {}
})
lsp.setup()

------ TreeSitter ------
require 'nvim-treesitter.configs'.setup {
    ensure_installed = { "python", "go", "lua", "help", "bash" },
    highlight = { enable = true },
    indent = {
        enable = true,
        --disable = { 'python' },
    },
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<c-backspace>',
        },
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
            keymaps = {
                -- You can use the capture groups defined in textobjects.scm
                ['aa'] = '@parameter.outer',
                ['ia'] = '@parameter.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            },
        },
        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer',
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer',
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer',
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer',
            },
        },
        swap = {
            enable = true,
            swap_next = {
                ['<leader>a'] = '@parameter.inner',
            },
            swap_previous = {
                ['<leader>A'] = '@parameter.inner',
            },
        },
    },
}

-- Telescope
require('telescope').setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
require('project_nvim').setup {}
require('telescope').load_extension('fzf')
require('telescope').load_extension('projects')

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>sF', builtin.find_files)
vim.keymap.set('n', '<leader>sf', builtin.git_files)
vim.keymap.set('n', '<leader>s/', function()
    ---@diagnostic disable-next-line: param-type-mismatch
    require('telescope.builtin').grep_string { search = vim.fn.input 'Grep > ' }
end)
vim.keymap.set('n', '<leader>sk', builtin.keymaps)
vim.keymap.set('n', '<leader><space>', builtin.buffers)
vim.keymap.set('n', '<leader>sp', require('telescope').extensions.projects.projects)


-- Looks
vim.cmd.colorscheme("kanagawa")
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "WinSeparator", { bg = "none" })

-- Lualine
require('lualine').setup {
  options = {
    icons_enabled = false,
    component_separators = '|',
    section_separators = '',
  },
  -- TODO If SSH_CLIENT show 'hostname'  
  sections = {
    lualine_a = {},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {},
    lualine_x = {},
    -- TODO: put lsp clients here
    lualine_y = {'filetype'},
    lualine_z = {"location"},
  }
}

------ Operators and motions ------
require('nvim-surround').setup()
require('Comment').setup()

------ Navigation ------
-- harpoon
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")
local term = require("harpoon.term")

vim.keymap.set('n', 'mm', mark.add_file)
vim.keymap.set('n', 'mq', ui.toggle_quick_menu)
vim.keymap.set('n', 'ma', function() ui.nav_file(1) end)
vim.keymap.set('n', 'ms', function() ui.nav_file(2) end)
vim.keymap.set('n', 'md', function() ui.nav_file(3) end)
vim.keymap.set('n', 'mf', function() ui.nav_file(4) end)
vim.keymap.set('n', 'mg', function() term.gotoTerminal(1) end)

------ Git ------
-- fugitive
vim.keymap.set('n', 'gs', '<cmd>silent! tab G<CR>')
vim.keymap.set('n', '<leader>gs', '<cmd>Git push<CR>')
vim.keymap.set('n', '<leader>gl', '<cmd>Git pull<CR>')
-- gitsigns
require('gitsigns').setup {
  numhl = true,
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end
    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        return ']c'
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })
    map('n', '[c', function()
      if vim.wo.diff then
        return '[c'
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return '<Ignore>'
    end, { expr = true })
    -- Actions
    map({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map('n', '<leader>hS', gs.stage_buffer)
    map({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hR', gs.reset_buffer)
    map('n', '<leader>hu', gs.undo_stage_hunk)
    map('n', '<leader>hp', gs.preview_hunk)
    map('n', '<leader>hb', function()
      gs.blame_line { full = true }
    end)
    map('n', '<leader>hd', gs.diffthis)
    map('n', '<leader>hD', function()
      gs.diffthis '~'
    end)
    map('n', 'yogb', gs.toggle_current_line_blame)
    map('n', 'yogd', gs.toggle_deleted)
    -- Text object
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end,
}

------ Misc ------
-- vim-unimpaired
-- tweak the way new lines are added a bit
vim.keymap.set("n", "]<Space>", "o<esc>")
vim.keymap.set("n", "[<Space>", "O<esc>")


--[[
- operator-nonmotion
  - =c
  - =d
  - =P
  - =p
  - c!
  - c,
  - c.
  - c=
  - cd
  - co
  - cp
  - cx 
  - cy
  - d=
  - dc
  - dx 
  - dy
  - y,
  - y.
  - y=
  - yc
  - yd
  - yp
  - yr
  - yx 

- g commands:
  - gH
  - gi
  - gM
  - gm
  - gq
  - gV
  - gy
  - g;

- z commands:
  - zq
  - zy
  - z;
  - zn
  - z,
  - z.

- C-keys
  - C-n
  - C-p
  - C-k
  - C-j
  - C-[
  - C-]

- Unused keys
  - <Del>
  - Most function keys 

- Marks I'll not use:
  - m!
  - m#
  - m$
  - m&
  - m(
  - m)
  - m+
  - m,
  - m-
  - m-
  - m.
  - m;
  - m<CR>
  - m=
  - m?
  - m@
  - m[
  - m]
  - m^
  - m_
  - m{
  - m|
  - m}

]]

