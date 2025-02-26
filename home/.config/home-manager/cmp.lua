local ok, _ = pcall(require, 'cmp')
if not ok then
  return
end
-- Setup nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
       --require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
       --require('snippy').expand_snippet(args.body) -- For `snippy` users.
       --vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
     --completion = cmp.config.window.bordered(),
     documentation = cmp.config.window.bordered(),
  },
  preselect = cmp.PreselectMode.Item, -- Default behavior: preselect the first item
    --sorting = {
	--comparators = {
	    --cmp.config.compare.offset,
	    --cmp.config.compare.exact,
	    --cmp.config.compare.score,
	    --cmp.config.compare.recently_used,
	    --cmp.config.compare.kind,
	    --cmp.config.compare.sort_text,
	    --cmp.config.compare.length,
	    --cmp.config.compare.order,
	--},
    --},
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'treesitter' },
    --{ name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
-- require('lspconfig')['someserver'].setup {
  -- capabilities = capabilities
-- }
-- Moved to lsp.lua
