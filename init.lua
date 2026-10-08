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
        'folke/tokyonight.nvim',
        priority = 1000, -- Load before other plugins
        config = function()
            require('tokyonight').setup({
                style = 'night', -- 'storm', 'night', 'moon', 'day'
                transparent = false,
                terminal_colors = true,
            })
            vim.cmd('colorscheme tokyonight-night')
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
        'nvim-tree/nvim-web-devicons',
        priority = 100,
    },
    {
        'nvim-tree/nvim-tree.lua',
        version = '*',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('nvim-web-devicons').setup()

            require('nvim-tree').setup({
                renderer = {
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                        glyphs = {
                            folder = {
                                arrow_closed = "▶",
                                arrow_open = "▼",
                            },
                        },
                    },
                    indent_markers = {
                        enable = true,
                    },
                },
                view = {
                    side = 'left',
                    width = 30,
                },
                git = {
                    enable = true,
                },
            })

            -- Toggle nvim-tree
            vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = 'Toggle file explorer' })
            vim.keymap.set('n', '<leader>E', ':NvimTreeFindFile<CR>', { desc = 'Find current file in tree' })

            -- Navigate between sidebar and editor with Ctrl+h and Ctrl+l
            vim.keymap.set('n', '<C-h>', function()
                require('nvim-tree.api').tree.focus()
            end, { desc = 'Focus on file explorer' })

            vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Focus on editor' })
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
        branch = "v4.x",
        dependencies = {
            "https://github.com/williamboman/mason.nvim",
            "https://github.com/williamboman/mason-lspconfig.nvim",
            "https://github.com/neovim/nvim-lspconfig",
            "https://github.com/hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local lsp_zero = require('lsp-zero')

            lsp_zero.extend_lspconfig({
                capabilities = require('cmp_nvim_lsp').default_capabilities(),
                lsp_attach = function(client, bufnr)
                    lsp_zero.default_keymaps({ buffer = bufnr })
                end,
            })

            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
                    "pyright", -- Python
                    "rust_analyzer", -- Rust
                    "ts_ls",
                    "volar",
                    "clangd", -- C/C++
                    "terraformls", -- Terraform
                },
            })

            -- Format Terraform on save via terraform-ls
            vim.api.nvim_create_autocmd("BufWritePre", {
                pattern = { "*.tf", "*.tfvars" },
                callback = function() vim.lsp.buf.format() end,
            })
        end,
    },
    {
        "https://github.com/mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("lint").linters_by_ft = {
                terraform = { "tflint" },
            }
            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
                callback = function() require("lint").try_lint() end,
            })
        end,
    },
    {
        "https://github.com/hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "https://github.com/hrsh7th/cmp-nvim-lsp",
            "https://github.com/hrsh7th/cmp-buffer",
            "https://github.com/hrsh7th/cmp-path",
            "https://github.com/L3MON4D3/LuaSnip",
            "https://github.com/saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.abort(),
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                    { name = "path" },
                }),
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
    {
        "https://github.com/folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("which-key").setup({
                preset = "modern",
                delay = 200, -- delay in ms for showing the which-key popup
            })
        end,
    },
    {
        'romgrk/barbar.nvim',
        dependencies = {
            'nvim-tree/nvim-web-devicons',
            'lewis6991/gitsigns.nvim',
        },
        init = function()
            vim.g.barbar_auto_setup = false
        end,
        config = function()
            require('barbar').setup({
                animation = true,
                auto_hide = false,
                tabpages = true,
                clickable = true,
            })

            -- Quick buffer navigation
            vim.keymap.set('n', '<Tab>', ':BufferNext<CR>', { noremap = true, silent = true, desc = 'Next buffer' })
            vim.keymap.set('n', '<S-Tab>', ':BufferPrevious<CR>', { noremap = true, silent = true, desc = 'Previous buffer' })
            vim.keymap.set('n', '<leader>bc', ':BufferClose<CR>', { noremap = true, silent = true, desc = 'Close buffer' })
            vim.keymap.set('n', '<leader>ba', ':BufferCloseAllButCurrent<CR>', { noremap = true, silent = true, desc = 'Close all but current' })
        end,
    },
    {
        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup()
        end,
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown' },
        dependencies = {
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            require('render-markdown').setup({})

            vim.keymap.set('n', '<leader>mp', ':RenderMarkdown toggle<CR>', { silent = true, desc = 'Toggle markdown rendering' })
        end,
    },


})
