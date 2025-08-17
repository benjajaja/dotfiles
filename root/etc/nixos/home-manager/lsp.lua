local ok, _ = pcall(require, 'lspconfig')
if not ok then
  return
end
local nvim_lsp = require('lspconfig')

--require('vim.lsp.log').set_level('debug')

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- local capabilities = require("cmp_nvim_lsp").default_capabilities()
local capabilities = require('blink.cmp').get_lsp_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

format_on_save = true
function toggle_format_on_save()
  format_on_save = not format_on_save
  if format_on_save then
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
              if format_on_save then
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
    typescript = { "eslint_d", "prettier" },
    typescriptreact = { "eslint_d", "prettier" },
  },
  formatters = {
    eslint_d = {
      args = { "--fix-to-stdout", "--stdin", "--stdin-filename", "$FILENAME" },
    },
  },
  format_on_save = {
    -- I recommend these options. See :help conform.format for details.
    lsp_format = "fallback",
    timeout_ms = 3000,
  },
})

nvim_lsp.gopls.setup{
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
}

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

require('rust-tools').setup({
  server = {
    on_attach = on_attach,
    standalone = true,
    capabilities = capabilities,
    tools = {
      autoSetHints = true,
      hover_with_actions = true,
      runnables = {
          use_telescope = true
      },
      inlay_hints = {
          show_parameter_hints = true,
      },
    },
    settings = {
      ['rust-analyzer'] = {
        diagnostics = {
          enable = true;
        },
        procMacro = {
          enable = true,
        },
      }
    },
  },
})

-- nvim_lsp.elmls.setup({
    -- capabilities = capabilities,
    -- on_attach = on_attach,
-- })

require('illuminate').configure({
    -- providers: provider used to get references in the buffer, ordered by priority
    providers = {
        'lsp',
        'treesitter',
        -- 'regex',
    },
})


nvim_lsp.pyright.setup({
    on_attach = function(client, bufnr)
        -- Add custom settings or keybindings here if needed
        -- For example, this could be your common `on_attach` for all LSPs
    end,
    capabilities = capabilities, -- If you have capabilities configured for autocompletion, etc.
})

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
