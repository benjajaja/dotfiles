vim.o.number = true
vim.o.cursorline = true
vim.o.hidden = true
vim.o.termguicolors = true
vim.o.guifont = "ProFontWindows Nerd Font Mono:h16"
-- vim.o.nostartofline = true -- something about cursor jumping around when changing buffers
vim.o.colorcolumn = 100 -- line length marker
vim.o.mouse = "r"
vim.o.signcolumn = "number"
vim.o.updatetime = 300

-- tabs vs. spaces:
-- vim.o.softtabstop = 2
-- vim.o.tabstop = 2
-- vim.o.shiftwidth = 2
-- vim.o.expandtab = true
-- vim.o.ruler = true
-- Enable filetype detection
-- vim.cmd('filetype plugin indent on')
-- Set options for Go files
-- vim.api.nvim_exec([[
  -- augroup GoSettings
    -- autocmd!
    -- autocmd FileType go setlocal noexpandtab shiftwidth=4 softtabstop=4 tabstop=4 omnifunc=lsp#complete
  -- augroup END
-- ]], false)

vim.g.mapleader = ';'
vim.g.EasyClipShareYanks  = 1

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

vim.api.nvim_set_var("lsp_utils_location_opts", {
  height = 30,
});

-- TODO: change from <cmd> to calling lua?
-- vim.keymap.set('n', '<C-PageUp>', '<cmd>:BufferLineCyclePrev<CR>')
-- vim.keymap.set('n', '<C-PageDown>', '<cmd>:BufferLineCycleNext<CR>')
-- vim.keymap.set('n', '<C-K>', '<cmd>:BufferLineCyclePrev<CR>')
-- vim.keymap.set('n', '<C-J>', '<cmd>:BufferLineCycleNext<CR>')
-- vim.keymap.set('n', '<C-H>', '<cmd>:BufferLineMovePrev<CR>')
-- vim.keymap.set('n', '<C-L>', '<cmd>:BufferLineMoveNext<CR>')

vim.keymap.set('n', '<C-K>', '<cmd>:bprev<CR>')
vim.keymap.set('n', '<C-J>', '<cmd>:bnext<CR>')
vim.keymap.set('n', '<C-PageUp>', '<cmd>:bprev<CR>')
vim.keymap.set('n', '<C-PageDown>', '<cmd>:bnext<CR>')

vim.keymap.set('n', '<C-C>', '<cmd>:Bwipeout<CR>')
vim.keymap.set('n', '<C-Q>', '<cmd>:Neotree focus buffers<CR>')
vim.keymap.set('n', 'M', '<Plug>MoveMotionEndOfLinePlug', {})
vim.api.nvim_set_keymap('v', '//', [[y/\V<C-r>=escape(@",'/\')<CR><CR>]], { noremap = true, silent = true })


-- TELESCOPE
local builtin = require('telescope.builtin')
-- vim.keymap.set('n', '<C-p>', builtin.find_files, {}) -- legacy
function normalmode(method)
  return function()
    builtin[method]({ initial_mode = "normal" })
  end
end
vim.keymap.set('n', '<C-p>', '<cmd>:echo "use the force, Luke"', {})
vim.keymap.set('n', '<leader>j', normalmode("jumplist"), {})
vim.keymap.set('n', '-', function()
	builtin.buffers({
	  initial_mode = "normal",
	  ignore_current_buffer = true,
	  sort_mru = true,
	})
end, {})
vim.keymap.set('n', '<leader>b', builtin.builtin, {})
vim.keymap.set('n', '<leader>fs', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>ff', builtin.resume, {})
-- vim.keymap.set('n', '<leader>rr', builtin.lsp_references, {}) -- legacy
vim.keymap.set('n', '<leader>fr', normalmode("lsp_references"), {})
vim.keymap.set('n', 'gd', function() builtin.lsp_definitions({ jump_type = "never" }) end, {})
vim.keymap.set('n', 'gi', function() builtin.lsp_implementations({ jump_type = "never" }) end, {})
vim.keymap.set('n', '<leader>tq', builtin.quickfix, {})
vim.keymap.set('n', '<leader>td', normalmode("diagnostics"), {})
require("telescope").load_extension("zf-native")

local telescope = require("telescope")
local telescopeConfig = require("telescope.config")

-- Clone the default Telescope configuration
local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

-- I want to search in hidden/dot files.
table.insert(vimgrep_arguments, "--hidden")
-- I don't want to search in the `.git` directory.
table.insert(vimgrep_arguments, "--glob")
table.insert(vimgrep_arguments, "!**/.git/*")

telescope.setup({
	defaults = {
		-- `hidden = true` is not supported in text grep commands.
		vimgrep_arguments = vimgrep_arguments,
	},
	pickers = {
		find_files = {
			-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
			find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
		},
	},
})

local persistence = require("persistence")
persistence.setup()
vim.keymap.set('n', '<leader>rs', persistence.load, {})


-- require("dracula").setup({
  -- transparent_bg = false,
  -- italic_comment = true,
-- })
require("tokyonight").setup({
  style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
  transparent = false, -- Enable this to disable setting the background color
  keywords = { italic = false, bold = true }
})
-- require("nebulous").setup {
  -- variant = "twilight",
  -- disable = {
    -- background = true,
    -- endOfBuffer = false,
    -- terminal_colors = false,
  -- },
  -- italic = {
    -- comments   = true,
    -- keywords   = false,
    -- functions  = false,
    -- variables  = false,
  -- },
  -- custom_colors = {
    -- BufferInactiveMod = { fg = "#8c7912" },
    -- BufferCurrentMod = { fg = "#c9b153" },
    -- LspReferenceRead = { bg = '#36383F' },
    -- LspReferenceText = { bg = '#36383F' },
    -- LspReferenceWrite = { bg = '#36383F' },
  -- },
-- }
vim.cmd[[colorscheme tokyonight]]

-- require("bufferline").setup{
  -- options = {
    -- separator_style = "slant",
    -- show_close_icon = false,
    -- sort_by = 'insert_after_current' |'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | function(buffer_a, buffer_b)
                -- return buffer_a.modified > buffer_b.modified
            -- end
    -- sort_by = 'insert_after_current',
  -- }
-- }

-- require("neo-tree").setup({
  -- close_if_last_window = true,
  -- window = {
    -- position = "right",
    -- width = "60",
  -- },
  -- buffers = {
    -- show_unloaded = false,
  -- },
-- })

-- vim.cmd[[:Neotree show buffers right]]
require("sidebar-nvim").setup({
    open = false,
    side = "right",
    initial_width = 40,
    -- hide_statusline = false,
    update_interval = 100,
    sections = { "buffers", "diagnostics" },
    -- section_separator = {"", "-----", ""},
    -- section_title_separator = {""},
    -- containers = {
        -- attach_shell = "/bin/sh", show_all = true, interval = 5000,
    -- },
    -- datetime = { format = "%a %b %d, %H:%M", clocks = { { name = "local" } } },
    -- todos = { ignored_paths = { "~" } },
    buffers = {
      ignore_not_loaded = true, -- whether to ignore not loaded buffers
      ignore_terminal = false, -- whether to show terminal buffers in the list
    },
})

require('dap-go').setup()
local dap, dapui = require("dap"), require("dapui")
require('dap.ext.vscode').load_launchjs(nil, {})
dapui.setup()
dap.listeners.after.event_initialized["dapui_config"]=function()
  dapui.open()
end
vim.keymap.set('n', '<leader>dui', dapui.toggle, {})
vim.keymap.set('n', '<leader>dt', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<leader>dc', dap.continue, {})
vim.keymap.set('n', '<leader>dso', dap.step_over, {})
vim.keymap.set('n', '<leader>dsi', dap.step_into, {})
vim.keymap.set('n', '<leader>de', dapui.eval, {})
_G.dap = dap -- to run e.g. :lua dap.continue()


