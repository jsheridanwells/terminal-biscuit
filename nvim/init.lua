-- ~/.config/nvim/init.lua

-- Leader key must be set BEFORE lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================================
-- Editor options
-- ============================================================
local opt = vim.opt

-- Line numbers (absolute on current line, relative on others)
opt.number = true
opt.relativenumber = true

-- Indentation: 4 spaces, smart
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 4
opt.smartindent = true
opt.autoindent = true
opt.smarttab = true

-- Line wrapping / breaking
opt.wrap = false                -- don't soft-wrap long lines
opt.linebreak = true            -- if wrap is ever turned on, break at words
opt.showbreak = "+++"           -- prefix for wrap-broken lines
opt.textwidth = 100             -- auto-insert newline past col 100

-- Search
opt.hlsearch = true             -- highlight all matches
opt.incsearch = true            -- show matches as you type
opt.ignorecase = true
opt.smartcase = true            -- case-sensitive if search has a capital

-- UI
opt.termguicolors = true        -- 24-bit color
opt.cursorline = true           -- highlight current line
opt.signcolumn = "yes"          -- always show gutter (no shift on diagnostics)
opt.scrolloff = 8               -- keep 8 lines of context above/below cursor
opt.sidescrolloff = 8
opt.showmatch = true            -- briefly jump to matching brace
opt.ruler = true                -- show row/col in status line
opt.showtabline = 2             -- always show tabline (bufferline will use this)

-- Splits open in the intuitive direction
opt.splitright = true
opt.splitbelow = true

-- System clipboard
opt.clipboard = "unnamedplus"

-- Mouse on
opt.mouse = "a"

-- Bells off — replaces the old noerrorbells / visualbell / t_vb= dance
opt.belloff = "all"

-- Persistent undo across sessions, with a big history
opt.undofile = true
opt.undolevels = 1000

-- Confirm dialog instead of failing on unsaved changes
opt.confirm = true

-- Snappier UI
opt.updatetime = 250
opt.timeoutlen = 300

-- for autoreload
opt.autoread= true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  desc = "Reload file if changed outside Neovim",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- ============================================================
-- Bootstrap lazy.nvim
-- ============================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)


-- ============================================================
-- Keymaps (global)
-- ============================================================

-- Window splits
vim.keymap.set("n", "<C-A-Right>", function()
  vim.cmd("vsplit")     -- duplicates current file into new window on the right
  vim.cmd("wincmd h")   -- jump focus to the left window
  vim.cmd("bprevious")  -- switch that window back to the previous buffer
  vim.cmd("wincmd l")   -- jump focus back to the right window
end, { desc = "Split right (move file to right pane)" })
vim.keymap.set("n", "<C-A-Left>",  "<cmd>close<cr>",  { desc = "Close current window" })

-- LSP keybindings (active only when a language server attaches)
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
  callback = function(event)
    local buf = event.buf
    local function map(mode, keys, fn, desc)
      vim.keymap.set(mode, keys, fn, { buffer = buf, desc = desc })
    end

    map("n", "<F12>",     vim.lsp.buf.definition,      "Go to definition")
    map("n", "gd",        vim.lsp.buf.definition,      "Go to definition")
    map("n", "<S-F12>",   vim.lsp.buf.references,      "Find references")
    map("n", "<F2>",      vim.lsp.buf.rename,          "Rename symbol")
    map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action, "Code action (quick fix / add using)")
    map("n", "<leader>d", vim.diagnostic.open_float,   "Show diagnostic message")
  end,
})

-- :x and :xa do not exist nvim
require("window_close")

-- ============================================================
-- Plugins
-- ============================================================
require("lazy").setup({
  -- Colorscheme: Nordic
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nord").setup({})
      vim.cmd.colorscheme("nord")
    end,
  },
  -- File tree (left sidebar, VS Code-style)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
      { "<C-S-e>", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
      { "<C-b>",   "<cmd>Neotree close<cr>",  desc = "Close file tree" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          follow_current_file = { enabled = true },
          hijack_netrw_behavior = "open_default",
        },
        window = { width = 30 },
      })
    end,
  },
  -- Fuzzy finder (VS Code-style Ctrl+P)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<C-p>",
        function()
          local git_root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
          local cwd = (git_root and git_root ~= "") and git_root or vim.fn.getcwd()
          require("telescope.builtin").find_files({ cwd = cwd })
        end,
        desc = "Find files (from git root)",
      },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          layout_strategy = "horizontal",
          layout_config = { horizontal = { preview_width = 0.5 } },
          file_ignore_patterns = {
            "node_modules/", "%.git/",
            "obj/", "bin/",                       -- .NET build output
            "%.venv/", "venv/", "__pycache__/",   -- Python
            "dist/", "build/", "target/",
          },
        },
      })
    end,
  },
  -- Tab bar (shows buffers VS Code-style)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          numbers = "ordinal",              -- show 1,2,3... so you know which Alt+N to hit
          diagnostics = "nvim_lsp",         -- LSP error counts in tabs
          show_buffer_close_icons = false,  -- cleaner look
          show_close_icon = false,
          offsets = {                       -- play nicely with neo-tree
            {
              filetype = "neo-tree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            },
          },
        },
      })

      -- Alt+1..9 to jump to buffer by visible position
      for i = 1, 9 do
        vim.keymap.set("n", "<A-" .. i .. ">", function()
          require("bufferline").go_to(i, true)
        end, { desc = "Go to buffer " .. i })
      end
    end,
  },
  -- Completion engine
  {
    "saghen/blink.cmp",
    version = "1.*",                                  -- pulls prebuilt fuzzy-matcher binary
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" },                -- Enter accepts, Ctrl+N/P navigate
      appearance = { nerd_font_variant = "mono" },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  -- LSP infrastructure
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Defaults for every server: blink's completion capabilities
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Python: basedpyright (types/completion) + ruff (lint/import fixes)
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",   -- saner than basedpyright's loud default
              diagnosticMode = "openFilesOnly", -- don't scan the whole project constantly
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      vim.api.nvim_create_autocmd("FileType", {
          pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact",
                      "json", "jsonc", "html", "css", "scss", "yaml", "lua" },
          callback = function()
            vim.bo.shiftwidth = 2
            vim.bo.tabstop = 2
            vim.bo.softtabstop = 2
          end,
      })

      -- Tree-sitter
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      vim.lsp.config("ruff", {
        on_attach = function(client, _)
          -- let basedpyright own hover; ruff just lints and fixes
          client.server_capabilities.hoverProvider = false
        end,
      })

      require("mason").setup({
          registries = {
            "github:mason-org/mason-registry",
            "github:Crashdummyy/mason-registry"
          }
      })
      require("mason-lspconfig").setup({
        ensure_installed = { "basedpyright", "ruff", "ts_ls" },
      })

      -- Make diagnostics clearly visible
      vim.diagnostic.config({
        virtual_text = true,       -- inline message at end of line
        signs = true,              -- gutter sign
        underline = true,          -- squiggle under the text
        severity_sort = true,      -- errors sort above warnings
        float = { border = "rounded", source = true },
      })
    end,
  },
  -- C# via Roslyn (same engine as VS Code's C# extension)
  {
    "seblyng/roslyn.nvim",
    ft = "cs",
    opts = {
      broad_search = true,  -- find .sln files in parent dirs (helps with work monorepos)
    },
  },
  -- Integrated toggle terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal", mode = { "n", "t" } },
    },
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-`>]],
        direction = "float",
        size = 15,
        start_in_insert = true,
        persist_mode = false,
      })
    end,
  },
  -- Seamless navigation between nvim splits and tmux panes
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft", "TmuxNavigateDown",
      "TmuxNavigateUp", "TmuxNavigateRight", "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>",  desc = "Navigate left (nvim/tmux)" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>",  desc = "Navigate down (nvim/tmux)" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>",    desc = "Navigate up (nvim/tmux)" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (nvim/tmux)" },
    },
  },
  -- Seamless resize across nvim splits and tmux panes
  {
    "RyanMillerC/better-vim-tmux-resizer",
    event = "VeryLazy",
  },

  -- Auto-close brackets, quotes, etc.
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
   },

}, {})

