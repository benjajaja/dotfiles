local ok, _ = pcall(require, 'lspconfig')
if not ok then
  return
end
local nvim_lsp = require('lspconfig')

--require('vim.lsp.log').set_level('debug')

-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require("cmp_nvim_lsp").default_capabilities()
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

local on_attach = function(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

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


  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
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

  if vim.lsp.buf.inlay_hint then vim.lsp.buf.inlay_hint(bufnr, true) end
end

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

function goimports(timeoutms)
  local context = { source = { organizeImports = true } }
  vim.validate { context = { context, "t", true } }

  local params = vim.lsp.util.make_range_params()
  params.context = context

  -- See the implementation of the textDocument/codeAction callback
  -- (lua/vim/lsp/handler.lua) for how to do this properly.
  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, timeout_ms)
  if not result or next(result) == nil then return end
  local actions = result[1].result
  if not actions then return end
  local action = actions[1]

  -- textDocument/codeAction can return either Command[] or CodeAction[]. If it
  -- is a CodeAction, it can have either an edit, a command or both. Edits
  -- should be executed first.
  if action.edit or type(action.command) == "table" then
    if action.edit then
      vim.lsp.util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      vim.lsp.buf.execute_command(action.command)
    end
  else
    vim.lsp.buf.execute_command(action)
  end
end

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

local typescript = require("typescript")
typescript.setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
    },
    server = { -- pass options to lspconfig's setup method
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)

        local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
        local opts = { noremap=false, silent=true }
        buf_set_keymap('n', 'gd', '<cmd>lua go_to_source_definition_typescript()<CR>', opts)
        buf_set_keymap('n', '<Leader>ii', '<cmd>lua org_imports_typescript()<CR>', opts)

        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", '<Cmd>:TypescriptGoToSourceDefinition<CR>', opts)
        client.resolved_capabilities.document_formatting = false
        -- print("on_attach typescript done1")
        client.resolved_capabilities.document_range_formatting = false
        -- print("on_attach typescript done2")
        client.server_capabilities.document_formatting = false
        -- print("on_attach typescript done3")
        client.server_capabilities.document_range_formatting = false
        -- print("on_attach typescript done4")

      end,
    },
})

function org_imports_typescript()
  typescript.actions.addMissingImports()
  typescript.actions.organizeImports()
  vim.lsp.buf.format()
end

function go_to_source_definition_typescript()
  typescript.goToSourceDefinition(vim.api.nvim_get_current_win(), {})
end

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
        -- checkOnSave = {
					-- command = "clippy",
					-- extraArgs = { "--all", "--", "-W", "clippy::all" },
				-- },
				-- rustfmt = {
					-- extraArgs = { "+nightly" },
				-- },
				-- cargo = {
					-- loadOutDirsFromCheck = true,
				-- },
				-- procMacro = {
					-- enable = true,
				-- },
      }
    },
    -- settings = {
        -- to enable rust-analyzer settings visit:
        -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
        -- ["rust-analyzer"] = {
            -- enable clippy on save
            -- checkOnSave = {
                -- command = "clippy"
            -- }
        -- }
    -- }
  },
})

nvim_lsp.elmls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

local null_ls = require("null-ls")
null_ls.setup({
    debug = false,
    capabilities = capabilities,
    on_attach = on_attach,
    sources = {
        -- null_ls.builtins.diagnostics.eslint, -- eslint or eslint_d
        -- null_ls.builtins.code_actions.eslint, -- eslint or eslint_d
        -- null_ls.builtins.formatting.eslint, -- prettier, eslint, eslint_d, or prettierd
        null_ls.builtins.formatting.prettier, -- prettier, eslint, eslint_d, or prettierd
        -- require("typescript.extensions.null-ls.code-actions"),
    },
})

-- require'lspconfig'.nil_ls.setup{}

require('illuminate').configure({
    -- providers: provider used to get references in the buffer, ordered by priority
    providers = {
        'lsp',
        'treesitter',
        -- 'regex',
    },
})


-- local bufnr = vim.api.nvim_buf_get_number(0)
--
-- vim.lsp.handlers['textDocument/codeAction'] = function(_, _, actions)
    -- require('lsputil.codeAction').code_action_handler(nil, actions, nil, nil, nil)
-- end
--
-- vim.lsp.handlers['textDocument/references'] = function(_, _, result)
    -- require('lsputil.locations').references_handler(nil, result, { bufnr = bufnr }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/definition'] = function(_, method, result)
    -- require('lsputil.locations').definition_handler(nil, result, { bufnr = bufnr, method = method }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/declaration'] = function(_, method, result)
    -- require('lsputil.locations').declaration_handler(nil, result, { bufnr = bufnr, method = method }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/typeDefinition'] = function(_, method, result)
    -- require('lsputil.locations').typeDefinition_handler(nil, result, { bufnr = bufnr, method = method }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/implementation'] = function(_, method, result)
    -- require('lsputil.locations').implementation_handler(nil, result, { bufnr = bufnr, method = method }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/documentSymbol'] = function(_, _, result, _, bufn)
    -- require('lsputil.symbols').document_handler(nil, result, { bufnr = bufn }, nil)
-- end
--
-- vim.lsp.handlers['textDocument/symbol'] = function(_, _, result, _, bufn)
    -- require('lsputil.symbols').workspace_handler(nil, result, { bufnr = bufn }, nil)
-- end
--
-- vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

nvim_lsp.pyright.setup({
    on_attach = function(client, bufnr)
        -- Add custom settings or keybindings here if needed
        -- For example, this could be your common `on_attach` for all LSPs
    end,
    capabilities = capabilities, -- If you have capabilities configured for autocompletion, etc.
})

--vim.lsp.handlers['textDocument/completion'] = function(err, result, ctx, config)
    --print(vim.inspect(result))
    --return vim.lsp.handlers['textDocument/completion'](err, result, ctx, config)
--end
