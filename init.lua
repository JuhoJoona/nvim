vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.undofile = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.g.mapleader = " "
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        'rebelot/kanagawa.nvim',
        priority = 1000, -- Load before other plugins
        config = function()
            require('kanagawa').setup({
                -- Optional: customize theme
                -- theme = "wave",    -- "wave", "dragon", "lotus"
                -- background = {
                --     dark = "wave",
                --     light = "lotus"
                -- },
            })
            vim.cmd('colorscheme kanagawa')
        end
    },
    {
        "https://github.com/nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            require("lualine").setup()
        end,
    },
    {
        'nvim-telescope/telescope.nvim', 
        version = '*',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            -- Load fzf extension for better performance
            require('telescope').load_extension('fzf')
            
            -- Keymaps
            local builtin = require('telescope.builtin')
            
            -- File navigation
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'Git files' })
            vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'Recent files' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Buffers' })
            
            -- Search
            vim.keymap.set('n', '<leader>fw', builtin.live_grep, { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fc', builtin.grep_string, { desc = 'Find word under cursor' })
            vim.keymap.set('n', '<leader>/', builtin.current_buffer_fuzzy_find, { desc = 'Search in buffer' })
            
            -- Utility
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Help tags' })
            vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = 'Keymaps' })
        end
    },
    {
        'echasnovski/mini.files',
        version = '*',
        config = function()
            require('mini.files').setup()
            
            -- Toggle mini.files
            vim.keymap.set('n', '<leader>e', function()
                require('mini.files').open(vim.api.nvim_buf_get_name(0))
            end, { desc = 'File explorer (current file)' })
            
            vim.keymap.set('n', '<leader>E', function()
                require('mini.files').open()
            end, { desc = 'File explorer (cwd)' })
        end
    },
     {
        "https://github.com/windwp/nvim-autopairs",
        event = "InsertEnter", -- Only load when you enter Insert mode
        config = function()
            require("nvim-autopairs").setup()
        end,
    },
    {
        "https://github.com/numToStr/Comment.nvim",
        event = "VeryLazy", -- Special lazy.nvim event for things that can load later and are not important for the initial UI
        config = function()
            require("Comment").setup()
        end,
    },
    {
        "https://github.com/tpope/vim-sleuth",
        event = { "BufReadPost", "BufNewFile" }, -- Load after your file content
    },
        {
        "https://github.com/VonHeikemen/lsp-zero.nvim",
        dependencies = {
            "https://github.com/williamboman/mason.nvim",
            "https://github.com/williamboman/mason-lspconfig.nvim",
            "https://github.com/neovim/nvim-lspconfig",
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            "https://github.com/hrsh7th/nvim-cmp",
            "https://github.com/L3MON4D3/LuaSnip",
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.on_attach(function(client, bufnr)
                lsp_zero.default_keymaps({buffer = bufnr})
            end)

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
                    "pyright", -- Python
                    "rust_analyzer", -- Rust
                    "ts_ls",
                    "volar",
                },
                handlers = {
                    lsp_zero.default_setup,
                },
            })
        end,
    },
    {
        "https://github.com/folke/flash.nvim",
        event = "VeryLazy",
        config = function()
            require("flash").setup({
                modes = {
                    search = {
                        enabled = true,
                    },
                    char = {
                        enabled = false,
                    },
                },
            })
        end,
    },
     {
        "https://github.com/lukas-reineke/indent-blankline.nvim",
        event = { "VeryLazy" },
        config = function()
            require("ibl").setup()
        end,
    },


})
