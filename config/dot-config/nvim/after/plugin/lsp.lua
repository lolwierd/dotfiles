local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local lsp = require('lsp-zero')

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })
  local opts = { buffer = bufnr, remap = false }
  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format() end, opts)
  vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
  lsp.buffer_autoformat()
end)


lsp.set_server_config({
  capabilities = {
    textDocument = {
      foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true
      }
    }
  }
})

lspconfig.lua_ls.setup(lsp.nvim_lua_ls())
lspconfig.gopls.setup {}
-- lspconfig.rust_analyzer.setup {
--   settings = {
--     ['rust-analyzer'] = {
--       check = {
--         command = "clippy",
--       },
--       diagnostics = {
--         enable = true,
--       }
--     }
--   }
-- }
-- lspconfig.biome.setup {
--   root_dir = function(fname)
--     return util.root_pattern("biome.json", "biome.jsonc")(fname)
--         or util.find_package_json_ancestor(fname)
--         or util.find_node_modules_ancestor(fname)
--         or util.find_git_ancestor(fname)
--   end
-- }
lspconfig.ts_ls.setup {}

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
cmp.setup({
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
  }
})



vim.diagnostic.config({
  virtual_text = true
})


lsp.setup()


-- require("mason").setup({})
-- require('mason-lspconfig').setup({
--   -- ensure_installed = { 'gopls' },
--   handlers = {
--     -- The first entry (without a key) will be the default handler
--     -- and will be called for each installed server that doesn't have
--     -- a dedicated handler.
--     function(server_name) -- default handler (optional)
--       require("lspconfig")[server_name].setup {}
--     end,
--     -- Next, you can provide targeted overrides for specific servers.
--     ["lua_ls"] = function()
--       local lspconfig = require("lspconfig")
--       lspconfig.lua_ls.setup {
--         settings = {
--           Lua = {
--             diagnostics = {
--               globals = { "vim" }
--             }
--           }
--         }
--       }
--     end,
--   }
-- })

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end
})
