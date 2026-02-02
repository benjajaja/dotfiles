vim.o.number = true
vim.o.cursorline = true
vim.o.hidden = true
vim.o.termguicolors = true
vim.o.guifont = "ProFontWindows Nerd Font Mono:h16"
-- vim.o.nostartofline = true -- something about cursor jumping around when changing buffers
vim.o.colorcolumn = "100" -- line length marker
vim.o.mouse = "r"
vim.o.signcolumn = "number"
vim.o.updatetime = 300

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set general options
vim.o.termguicolors = true
vim.o.guifont = "ProFontWindows Nerd Font Mono:h16"
vim.o.title = true
vim.o.hidden = true
vim.o.number = true
vim.o.cursorline = true

-- Tabs and spaces
vim.o.softtabstop = 2
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.ruler = true

-- Enable filetype-specific settings and indentation
vim.cmd('filetype plugin indent on')

-- FileType-specific settings for Go
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.tabstop = 4
  end,
})

-- NERDCommenter settings
vim.g.NERDSpaceDelims = 1
vim.g.NERDCommentEmptyLines = 1
vim.g.NERDTrimTrailingWhitespace = 1

-- Don't jump to the start of the line when changing buffers
vim.o.startofline = false

-- Set the color column
vim.o.colorcolumn = "100"

-- Mapping to change color scheme
vim.api.nvim_set_keymap('n', '<F4>', ':call NextColorScheme()<CR>', { noremap = true, silent = true })

-- Enable mouse in insert and replace modes
vim.o.mouse = 'r'

-- Set sign column to display line numbers
vim.o.signcolumn = "number"

-- Remap 'mark' to 'gm'
vim.api.nvim_set_keymap('n', 'gm', 'm', { noremap = true })

-- Remap [[ to [m and ]] to ]m
vim.api.nvim_set_keymap('n', '[[', '[m', { noremap = true })
vim.api.nvim_set_keymap('n', ']]', ']m', { noremap = true })

-- Close any floating windows (diagnostic vestiges)
vim.api.nvim_set_keymap('n', '<leader>cc',
  [[<cmd>lua for _, win in ipairs(vim.api.nvim_list_wins()) do
       if vim.api.nvim_win_get_config(win).relative ~= "" then
         vim.api.nvim_win_close(win, true)
       end
     end<CR>]],
  { noremap = true, silent = true }
)

-- Set a shorter update time
vim.o.updatetime = 300

-- Abbreviation for common pattern
vim.cmd('iabbrev iferr if err != nil { return err }')

-- ------------------

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

require("tokyonight").setup({
  style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
  transparent = false, -- Enable this to disable setting the background color
  keywords = { italic = false, bold = true }
})
vim.cmd[[colorscheme tokyonight]]


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

if vim.g.neovide then
  -- This is wrong, it's to match 1.5 scale which neovide doesn't pick up.
  -- It makes it too small when the scale is 1.0, obviously.
  vim.o.guifont = "ProFontWindows Nerd Font Mono:h12"
  --vim.keymap.set('n', '<D-s>', ':w<CR>') -- Save
  vim.keymap.set('n', '<C-v>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<C-v>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<C-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<C-v>', '<ESC>l"+Pli') -- Paste insert mode
end
vim.keymap.set('v', '<C-c>', '"+y') -- Copy

-- Cutlass
vim.api.nvim_set_keymap('n', 'm', 'd', { noremap = true })
vim.api.nvim_set_keymap('x', 'm', 'd', { noremap = true })
vim.api.nvim_set_keymap('n', 'mm', 'dd', { noremap = true })
vim.api.nvim_set_keymap('n', 'M', 'D', { noremap = true })

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap('', '<C-v>', '+p<CR>', { noremap = true, silent = true})
vim.api.nvim_set_keymap('!', '<C-v>', '<C-R>+', { noremap = true, silent = true})
vim.api.nvim_set_keymap('t', '<C-v>', '<C-R>+', { noremap = true, silent = true})
vim.api.nvim_set_keymap('v', '<C-v>', '<C-R>+', { noremap = true, silent = true})

require("no-neck-pain").setup({
  buffers = {
    right = {
      enabled = false,
    },
    scratchPad = {
      enabled = true,
      location = "~/Documents/",
      bo = {
        filetype = "md"
      },
    },
  },
})
