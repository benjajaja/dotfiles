local capabilities = require('blink.cmp').get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

vim.g.format_on_save = true
function toggle_format_on_save()
  vim.g.format_on_save = not vim.g.format_on_save
  if vim.g.format_on_save then
    print("Autoformatting on save enabled")
  else
    print("Autoformatting on save disabled")
  end
end
vim.cmd("command! ToggleFormatOnSave lua toggle_format_on_save()")

local set_lsp_keymaps = function(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', '<Leader>fi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<Leader>ii', '<cmd>lua org_imports()<CR>', opts)
  buf_set_keymap('n', '<C-i>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  -- buf_set_keymap('n', '<Leader>rr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', 'gn', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  if vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(bufnr, true) end
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

local on_attach = function(client, bufnr)
  set_lsp_keymaps(client, bufnr)
  if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
          group = augroup,
          buffer = bufnr,
          callback = function()
              if vim.g.format_on_save then
                print("Autoformatting...")
                vim.lsp.buf.format({
                    timeout_ms = 2000,
                    filter = function(client)
                        return client.name ~= "tsserver"
                    end,
                    bufnr = bufnr,
                })
              else
                print("Autoformat is disbled.")
              end
          end,
      })
  end
end

require("conform").setup({
  formatters_by_ft = {
    typescript = { "eslint_d", "biome" },
    typescriptreact = { "eslint_d", "biome" },
    go = { "goimports" },
  },
  formatters = {
    eslint_d = {
      args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
    },
  },
  format_after_save = function(bufnr)
    if vim.g.format_on_save == false then
      return
    end
    return {
      lsp_format = "fallback",
    }
  end,
})

vim.lsp.config('gopls', {
  cmd = {'gopls'},
  -- for postfix snippets and analyzers
  capabilities = capabilities,
  settings = {
    gopls = {
      analyses = {
        unusedparams = false,
        shadow = false,
     },
     staticcheck = true,
    },
  },
  on_attach = on_attach,
})
vim.lsp.enable('gopls')

function org_imports(wait_ms)
  local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
  params.context = {only = {"source.organizeImports"}}

  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
  for _, res in pairs(result or {}) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
      else
        vim.lsp.buf.execute_command(r.command)
      end
    end
  end
end

require("typescript-tools").setup {
  on_attach = function(client, bufnr)
    set_lsp_keymaps(client, bufnr)
    -- disable formatting, will use something else
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        require("conform").format({ bufnr = bufnr })
      end,
    })
  end,
  settings = {
  }
}

vim.g.rustaceanvim = {
  server = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = true,
        },
        procMacro = {
          enable = true,
        },
      }
    },
  },
}

require('illuminate').configure({
    -- providers: provider used to get references in the buffer, ordered by priority
    providers = {
        'lsp',
        'treesitter',
        -- 'regex',
    },
})


vim.lsp.config('pyright', {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Add custom settings or keybindings here if needed
  end,
})

vim.lsp.enable('pyright')

-- fix rust -32802: server cancelled the request
-- https://github.com/neovim/neovim/issues/30985
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end
