return {
	-- LANGUAGES
	{
		"rmagatti/auto-session",
		config = function()
			require("plugins.languages.sessions")
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("plugins.languages.conform-nvim")
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			require("plugins.languages.lsp-config")
		end,
		lazy = false,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		dependencies = { "Bilal2453/luvit-meta" },
	},
	{
		"williamboman/mason-lspconfig.nvim",
		lazy = false,
		config = function()
			require("plugins.languages.mason-lsp").setup()
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = false,
		config = function()
			require("plugins.languages.mason-tools")
		end,
	},
	{
		"williamboman/mason.nvim",
		lazy = false,
		build = ":MasonUpdate",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "VeryLazy",
		config = function()
			require("plugins.languages.completitions")
		end,
		dependencies = {
			"hrsh7th/cmp-omni",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"saadparwaiz1/cmp_luasnip",
			{
				"L3MON4D3/LuaSnip",
				dependencies = { "rafamadriz/friendly-snippets" },
				build = "make install_jsregexp",
			},
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/playground",
		},
		event = "VeryLazy",
		build = { ":TSUpdate" },
		config = function()
			require("plugins.languages.treesitter")
		end,
	},
	-- UI
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("plugins.ui.oil-ui")
		end,
		lazy = false,
	},
	{
		"glepnir/dashboard-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("plugins.ui.dashboard")
		end,
		lazy = false,
		priority = 999,
	},
	{
		"stevearc/quicker.nvim",
		event = { "VeryLazy" },
		config = function()
			require("plugins.ui.quicker-ui")
		end,
	},
	{
		"folke/zen-mode.nvim",
		config = function()
			require("plugins.ui.zenmode")
		end,
	},
	{
		"folke/todo-comments.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("plugins.ui.todo")
		end,
		event = "VeryLazy",
	},
	{
		"nvim-tree/nvim-web-devicons",
		config = function()
			require("plugins.ui.nvim-web-devicons")
		end,
	},
	{
		"NvChad/nvim-colorizer.lua",
		lazy = true,
		config = function()
			require("plugins.ui.colorizer")
		end,
	},
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		event = "VeryLazy",
		config = function()
			require("plugins.ui.noice")
		end,
	},
	{ "nvim-telescope/telescope-ui-select.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-lua/popup.nvim",
		},
		cmd = "Telescope",
		config = function()
			require("plugins.ui.telescope")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"AndreM222/copilot-lualine",
		},
		event = "VeryLazy",
		config = function()
			require("plugins.ui.lualine-nvim")
		end,
	},
	{
		"folke/which-key.nvim",
		event = { "VeryLazy" },
		config = function()
			require("plugins.ui.which-key")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		config = function()
			require("plugins.ui.gitsigns")
		end,
	},
	{
		"f-person/git-blame.nvim",
		cmd = { "GitBlameToggle" },
		config = function()
			require("plugins.ui.git-blame")
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "VeryLazy" },
		config = function()
			require("plugins.ui.indent-blankline")
		end,
	},
	{
		"sindrets/diffview.nvim",
		cmd = { "DiffviewClose", "DiffviewOpen" },
		config = function()
			require("plugins.ui.diffview")
		end,
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	-- THEMES
	{
		"AlexvZyl/nordic.nvim",
		priority = 1000,
		config = function()
			require("plugins.themes.nordic")
		end,
		lazy = false,
	},
	{
		"folke/tokyonight.nvim",
		lazy = true,
		priority = 1000,
		config = function()
			require("plugins.themes.tokyonight")
		end,
	},
	{
		"sainnhe/gruvbox-material",
		lazy = true,
		priority = 1000,
	},
	-- OTHER.
	{
		"Exafunction/windsurf.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"hrsh7th/nvim-cmp",
		},
		config = function()
			require("plugins.languages.windsfurd-nvim")
		end,
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"nvim-neotest/nvim-nio",
			{
				"rcarriga/nvim-dap-ui",
				config = function()
					require("plugins.ui.dapui-nvim")
				end,
			},
		},
		event = "VeryLazy",
		config = function()
			require("plugins.languages.dap.init")
		end,
	},
	{
		"aserowy/tmux.nvim",
		event = "VeryLazy",
		config = function()
			require("tmux").setup()
		end,
	},
	{
		"vyfor/cord.nvim",
		build = "./build || .\\build",
		event = "VeryLazy",
	},
	{
		"ggandor/leap.nvim",
		dependencies = "tpope/vim-repeat",
		keys = { "s", "S" },
		config = function()
			require("plugins.ui.leap-nvim")
		end,
	},
	{
		"kawre/leetcode.nvim",
		build = ":TSUpdate html",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-treesitter/nvim-treesitter",
			"rcarriga/nvim-notify",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("plugins.languages.leetcode-config")
		end,
	},
	{
		"akinsho/toggleterm.nvim",
		lazy = false,
		config = function()
			require("plugins.ui.toggleterm-nvim")
		end,
	},
	{
		"iamcco/markdown-preview.nvim",
		build = "cd app && npm install",
		ft = { "markdown" },
		config = function()
			require("plugins.ui.preview-markdown-nvim")
		end,
	},
	{
		"nvim-neotest/neotest",
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",

			"nvim-neotest/neotest-go",
			"nvim-neotest/neotest-python",
			"nvim-neotest/neotest-jest",
			"rouge8/neotest-rust",
		},
		config = function()
			require("plugins.languages.neotest")
		end,
	},
	{
		"stevearc/overseer.nvim",
		opts = {},
	},
}
