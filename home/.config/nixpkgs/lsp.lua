local ok, _ = pcall(require, 'lspconfig')
if not ok then
  return
end
local nvim_lsp = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local on_attach = function(client, bufnr)

  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  -- buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua org_imports()<CR>', opts)
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
              vim.lsp.buf.format({
                  filter = function(client)
                      return client.name ~= "tsserver"
                  end,
                  bufnr = bufnr,
              })
          end,
      })
  end
end

nvim_lsp.gopls.setup{
	cmd = {'gopls'},
	-- for postfix snippets and analyzers
	capabilities = capabilities,
  settings = {
    gopls = {
      experimentalPostfixCompletions = true,
      analyses = {
        unusedparams = true,
        shadow = true,
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

-- nvim_lsp.tsserver.setup({
    -- capabilities = capabilities,
    -- init_options = require("nvim-lsp-ts-utils").init_options,
    -- on_attach = function(client, bufnr)
        -- local ts_utils = require("nvim-lsp-ts-utils")
        -- defaults
        -- ts_utils.setup({
            -- debug = false,
            -- disable_commands = false,
            -- enable_import_on_completion = true,
            -- import all
            -- import_all_timeout = 5000, -- ms
            -- lower numbers = higher priority
            -- import_all_priorities = {
                -- same_file = 1, -- add to existing import statement
                -- local_files = 2, -- git files or files with relative path markers
                -- buffer_content = 3, -- loaded buffer content
                -- buffers = 4, -- loaded buffer names
            -- },
            -- import_all_scan_buffers = 100,
            -- import_all_select_source = false,
            -- if false will avoid organizing imports
            -- always_organize_imports = true,

            -- filter diagnostics
            -- filter_out_diagnostics_by_severity = {},
            -- filter_out_diagnostics_by_code = {},

            -- inlay hints
            -- auto_inlay_hints = false,
            -- inlay_hints_highlight = "Comment",
            -- inlay_hints_priority = 200, -- priority of the hint extmarks
            -- inlay_hints_throttle = 150, -- throttle the inlay hint request
            -- inlay_hints_format = { -- format options for individual hint kind
                -- Type = {},
                -- Parameter = {},
                -- Enum = {},
                -- Example format customization for `Type` kind:
                -- Type = {
                --     highlight = "Comment",
                --     text = function(text)
                --         return "->" .. text:sub(2)
                --     end,
                -- },
            -- },

            -- update imports on file move
            -- update_imports_on_move = true,
            -- require_confirmation_on_move = true,
            -- watch_dir = nil,
        -- })

        -- required to fix code action ranges and filter diagnostics
        -- ts_utils.setup_client(client)

        -- no default maps, so you may want to define some here
        -- local opts = { silent = true }
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportAll<CR>", opts)

        -- default to null-ls for formatting, suppress prompt
        -- client.server_capabilities.document_formatting = false
        -- client.server_capabilities.document_range_formatting = false
        -- on_attach(client, bufnr)
    -- end,
-- })
require("typescript").setup({
    disable_commands = false, -- prevent the plugin from creating Vim commands
    debug = false, -- enable debug logging for commands
    go_to_source_definition = {
        fallback = true, -- fall back to standard LSP definition on failure
    },
    server = { -- pass options to lspconfig's setup method
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        -- no default maps, so you may want to define some here
        local opts = { silent = true }
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", ":TSLspOrganize<CR>", opts)
        -- vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", ":TSLspRenameFile<CR>", opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", '<Cmd>lua org_imports_typescript()<CR>', opts)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", '<Cmd>:TypescriptGoToSourceDefinition<CR>', opts)
      end,
    },
})

function org_imports_typescript(wait_ms)
  require("typescript").actions.addMissingImports()
  require("typescript").actions.organizeImports()
end

require('rust-tools').setup({
    capabilities = capabilities,
    tools = { -- rust-tools options
        -- autoSetHints = true,
        -- hover_with_actions = true,
        inlay_hints = {
            -- auto = true,
            -- show_parameter_hints = true,
            -- parameter_hints_prefix = "< -",
            -- other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
    server = {
        -- on_attach is a callback called when the language server attachs to the buffer
        on_attach = on_attach,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy"
                }
            }
        }
    },
})

nvim_lsp.elmls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

local null_ls = require("null-ls")
null_ls.setup({
    capabilities = capabilities,
    sources = {
        -- null_ls.builtins.diagnostics.eslint, -- eslint or eslint_d
        -- null_ls.builtins.code_actions.eslint, -- eslint or eslint_d
        null_ls.builtins.formatting.prettier, -- prettier, eslint, eslint_d, or prettierd
        require("typescript.extensions.null-ls.code-actions"),
    },
})

