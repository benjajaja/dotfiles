require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

vim.api.nvim_set_var("lsp_utils_location_opts", {
  height = 30,
});

-- TELESCOPE
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>rr', builtin.lsp_references, {})
vim.keymap.set('n', 'gd', function() builtin.lsp_definitions({ jump_type = "never" }) end, {})
vim.keymap.set('n', '<leader>tq', builtin.quickfix, {})
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

require("bufferline").setup{
  options = {
    separator_style = "slant",
    show_close_icon = false,
  }
}

