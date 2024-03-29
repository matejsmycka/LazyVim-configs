-- .config/nvim/lua/plugins/null-ls.lua

local M = {
  "jay-babu/mason-null-ls.nvim",
  dependencies = {
    {
      "jose-elias-alvarez/null-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        -- Deliberately do nothing to set up null-ls later.
      end,
    },
  },
  ft = {
    "python",
    "sh",
    "golang",
  },
  config = function()
    -- It's recommended to configure mason and mason-null-ls
    -- before we configure null-ls, to use mason-null-ls
    -- as a source of truth. So we handle the setup order here.
    require("mason-null-ls").setup({
      ensure_installed = {
        "black",
        -- flake8 required_plugins can be installed via:
        -- - `~/.local/share/nvim/mason/packages/flake8/venv/bin/pip3 install flake8-bugbear`
        "flake8",
        -- Typeshed packages can be installed for mypy via:
        -- `~/.local/share/nvim/mason/packages/mypy/venv/bin/pip3 install -r requirements.txt`
        "mypy@0.971",
        "shellcheck",
      },
      automatic_installation = true,
      automatic_setup = true,
    })

    local ls = require("null-ls")
    ls.setup({
      -- debug = true, -- Turn on debug for :NullLsLog
      diagnostics_format = "#{m} #{s}[#{c}]",
      sources = {
        ls.builtins.formatting.black.with({
          extra_args = { "--line-length=120", "--skip-string-normalization" },
        }),
        ls.builtins.diagnostics.flake8,
        ls.builtins.diagnostics.mypy.with({
          -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/1208#issuecomment-1343562820
          cwd = function(_)
            return vim.fn.getcwd()
          end,
        }),
        ls.builtins.diagnostics.shellcheck,
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
                -- on later neovim version, you should use vim.lsp.buf.format({ async = false }) instead
                vim.lsp.buf.formatting_sync()
              end,
            })
          end
        end,
      },
    })
  end,
}

return M
