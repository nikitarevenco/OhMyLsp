local function setup_typescript_lsp_keymaps(opts_keys_typescript)
	return {
		{
			opts_keys_typescript.goto_source_definition or "gD",
			function()
				require("vtsls").commands.goto_source_definition(0)
			end,
			desc = "Goto Source Definition",
		},
		{
			opts_keys_typescript.file_references or "gR",
			function()
				require("vtsls").commands.file_references(0)
			end,
			desc = "File References",
		},
		{
			opts_keys_typescript.organize_imports or "<leader>co",
			function()
				require("vtsls").commands.organize_imports(0)
			end,
			desc = "Organize Imports",
		},
		{
			opts_keys_typescript.add_missing_imports or "<leader>cM",
			function()
				require("vtsls").commands.add_missing_imports(0)
			end,
			desc = "Add missing imports",
		},
		{
			opts_keys_typescript.remove_unused_imports or "<leader>cu",
			function()
				require("vtsls").commands.remove_unused_imports(0)
			end,
			desc = "Remove unused imports",
		},
		{
			opts_keys_typescript.fix_all or "<leader>cD",
			function()
				require("vtsls").commands.fix_all(0)
			end,
			desc = "Fix all diagnostics",
		},
		{
			opts_keys_typescript.select_ts_version or "<leader>cV",
			function()
				require("vtsls").commands.select_ts_version(0)
			end,
			desc = "Select TS workspace version",
		},
	}
end

return function(custom_opts)
	local settings = {
		updateImportsOnFileMove = { enabled = "always" },
		suggest = {
			completeFunctionCalls = true,
		},
		inlayHints = {
			parameterNames = { enabled = "literals" },
			parameterTypes = { enabled = true },
			variableTypes = { enabled = true },
			propertyDeclarationTypes = { enabled = true },
			functionLikeReturnTypes = { enabled = true },
			enumMemberValues = { enabled = true },
		},
	}

	return {
		{
			"nvim-treesitter/nvim-treesitter",
			opts = {
				ensure_installed = { "javascript", "typescript", "tsx" },
			},
		},
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = {
				ensure_installed = {
					"prettierd",
					"eslint_d",
				},
			},
		},
		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					javascript = { "prettierd", "eslint_d" },
					typescript = { "prettierd", "eslint_d" },
					javascriptreact = { "prettierd", "eslint_d" },
					typescriptreact = { "prettierd", "eslint_d" },
				},
			},
		},
		{
			"neovim/nvim-lspconfig",
			dependencies = {
				{
					"yioneko/nvim-vtsls",
					lazy = true,
					opts = {},
					config = function(_, opts)
						require("vtsls").config(opts)
					end,
				},
			},
			ft = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
			},
			opts = {
				attach_handlers = {
					eslint = function()
						vim.api.nvim_create_autocmd("BufWritePre", {
							callback = function(event)
								local clients = require("tvl.util").get_clients({ bufnr = event.buf, name = "eslint" })
								local client

								if clients and #clients > 0 then
									client = clients[1]
								end
								if client then
									local diag = vim.diagnostic.get(
										event.buf,
										{ namespace = vim.lsp.diagnostic.get_namespace(client.id) }
									)
									if #diag > 0 then
										vim.cmd("EslintFixAll")
									end
								end
							end,
						})
					end,
				},
				servers = {
					eslint = {
						settings = {
							-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
							workingDirectory = { mode = "auto" },
						},
					},
					vtsls = {
						settings = {
							complete_function_calls = true,
							vtsls = {
								enableMoveToFileCodeAction = true,
								experimental = {
									completion = {
										enableServerSideFuzzyMatch = true,
									},
								},
							},
							typescript = settings,
							javascript = settings,
						},
					},
				},
			},
			keys = setup_typescript_lsp_keymaps(custom_opts.keys.typescript),
		},
	}
end
