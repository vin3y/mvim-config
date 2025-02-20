return {
  'nvimtools/none-ls.nvim',
  dependencies = {
    'nvimtools/none-ls-extras.nvim',
    'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    local null_ls = require 'null-ls'
    local formatting = null_ls.builtins.formatting
    local diagnostics = null_ls.builtins.diagnostics

    require('mason-null-ls').setup {
      ensure_installed = {
        'checkmake',
        'prettier', -- ts/js formatter
        'stylua',   -- lua formatter
        'eslint_d', -- ts/js linter
        'shfmt',
        'ruff',
      },
      automatic_installation = true,
    }

    local sources = {
      diagnostics.checkmake,
      -- Configure prettier for JS/TS/JSX
      formatting.prettier.with {
        filetypes = {
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
          'html',
          'json',
          'yaml',
          'markdown',
        },
        extra_args = {
          '--single-quote',
          '--jsx-single-quote',
          '--trailing-comma', 'es5',
          '--arrow-parens', 'avoid',
        },
      },
      -- Add ESLint diagnostics using none-ls-extras
      require('none-ls.diagnostics.eslint_d').with {
        filetypes = {
          'javascript',
          'typescript',
          'javascriptreact',
          'typescriptreact',
        },
      },
      formatting.stylua,
      formatting.shfmt.with { args = { '-i', '4' } },
      formatting.terraform_fmt,
      require('none-ls.formatting.ruff').with { extra_args = { '--extend-select', 'I' } },
      require 'none-ls.formatting.ruff_format',
    }

    local augroup = vim.api.nvim_create_augroup('LspFormatting', {})
    null_ls.setup {
      -- debug = true,
      sources = sources,
      on_attach = function(client, bufnr)
        if client.supports_method 'textDocument/formatting' then
          vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
          vim.api.nvim_create_autocmd('BufWritePre', {
            group = augroup,
            buffer = bufnr,
            callback = function()
              -- Format on save
              vim.lsp.buf.format {
                async = false,
                timeout_ms = 5000, -- Increase timeout for larger files
                filter = function(formatting_client)
                  -- Use prettier for JS/TS/JSX files
                  return formatting_client.name == "null-ls"
                end,
              }
            end,
          })
        end
      end,
    }
  end,
}
