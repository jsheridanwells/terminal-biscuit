# terminal-biscuit

My personal Neovim and tmux configuration, tuned for **.NET, Python, and TypeScript** development on **Arch Linux (Wayland)** and **macOS**.

Feel free to fork it and adapt it for your own setup.

---

## What's inside

| Tool | Config path |
|------|-------------|
| Neovim | `nvim/init.lua` |
| tmux | `tmux/tmux.conf` |

### Neovim highlights

- **lazy.nvim** — plugin manager with locked versions (`lazy-lock.json`)
- **Mason** — automatic LSP server installation (`basedpyright`, `ruff`, `ts_ls`; Roslyn for C# installed separately — see below)
- **blink.cmp** — completion engine
- **Telescope** — fuzzy file finder (`Ctrl+P`)
- **neo-tree** — file explorer sidebar (`Ctrl+Shift+E`)
- **bufferline** — VS Code-style buffer tabs (`Alt+1–9` to jump)
- **Treesitter** — syntax highlighting for C#, Python, TypeScript/TSX, Lua, Markdown, and more
- **render-markdown.nvim** — toggle in-buffer Markdown rendering (`<leader>m`)
- **toggleterm** — floating terminal (`Ctrl+\``)
- **vim-tmux-navigator** / **better-vim-tmux-resizer** — seamless pane navigation and resizing across Neovim splits and tmux panes

### tmux highlights

- Prefix remapped to `Ctrl+A`
- Tokyo Night-inspired status bar
- Vim-style pane navigation (`prefix + hjkl`)
- Split with `prefix + \` (vertical) and `prefix + -` (horizontal), both opening in the current working directory
- `Shift+Left/Right` to cycle windows without the prefix
- Wayland (`wl-copy`) and macOS (`pbcopy`) clipboard support

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| Neovim ≥ 0.11 | Required for the `vim.lsp.config()` API used in `init.lua` |
| tmux ≥ 3.3 | For extended-key passthrough (`extended-keys always`) |
| Git | Used by lazy.nvim and Telescope |
| A [Nerd Font](https://www.nerdfonts.com/) | Icons in neo-tree, bufferline, and the status bar |
| `wl-copy` | Wayland clipboard — Arch Linux only |
| `pbcopy` | macOS clipboard — built in |

---

## Installation

```bash
git clone https://github.com/jsheridanwells/terminal-biscuit.git
cd terminal-biscuit
bash setup.sh
```

`setup.sh` copies configs into `~/.config/nvim` and `~/.config/tmux`. If anything already exists at those paths it is **backed up in place** with a timestamp suffix (e.g. `init.lua.bak.20240528-143022`) before being replaced. Re-running the script is safe — identical files are skipped.

---

## Post-install steps

### 1. Bootstrap Neovim plugins

Launch `nvim`. lazy.nvim will clone every plugin, Mason will pull the LSP servers, and Treesitter will compile its parsers. Let it finish, then quit and relaunch once.

### 2. C# / Roslyn LSP (large download, manual)

Roslyn is not auto-installed because the download is several hundred megabytes. Run this once inside Neovim:

```
:MasonInstall roslyn
```

After it completes, open any `.cs` file or `.sln`-rooted project and the server will attach automatically.

### 3. Reload tmux

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

Or press `prefix + r` if tmux is already running. If `Ctrl+Shift+<key>` passthrough to Neovim seems off, a full server restart clears it:

```bash
tmux kill-server
```

---

## Keybinding cheat sheet

Only the custom / non-default bindings are listed. The leader key in Neovim is `Space`; the tmux prefix is `Ctrl+A` (remapped from the default `Ctrl+B`).

### Neovim

**Files & navigation**

| Key | Action |
|-----|--------|
| `Ctrl+P` | Find files (fuzzy, scoped to git root) |
| `Ctrl+Shift+E` | Toggle file tree (neo-tree) |
| `Ctrl+B` | Close file tree |
| `Alt+1` … `Alt+9` | Jump to buffer 1–9 (by tab position) |
| `Ctrl+\`` | Toggle floating terminal |

**Window splits**

| Key | Action |
|-----|--------|
| `Ctrl+Alt+Right` | Split right and move current file into the new pane |
| `Ctrl+Alt+Left` | Close current window |

**Pane navigation & resize** (shared with tmux — see below)

| Key | Action |
|-----|--------|
| `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Move to split left / down / up / right |
| `Alt+H` / `Alt+J` / `Alt+K` / `Alt+L` | Resize split left / down / up / right |

**LSP** (active only when a language server is attached)

| Key | Action |
|-----|--------|
| `gd` or `F12` | Go to definition |
| `Shift+F12` | Find references |
| `F2` | Rename symbol |
| `Ctrl+.` | Code action (quick fix / add using) — works in normal & visual mode |
| `Space d` | Show diagnostic message under cursor |

**Completion** (blink.cmp, default preset)

| Key | Action |
|-----|--------|
| `Enter` | Accept completion |
| `Ctrl+N` / `Ctrl+P` | Next / previous candidate |

**Markdown**

| Key | Action |
|-----|--------|
| `Space m` | Toggle in-buffer Markdown rendering |

### tmux

Prefix is `Ctrl+A`. Below, `prefix +` means press `Ctrl+A`, release, then the key.

**Session / config**

| Key | Action |
|-----|--------|
| `prefix + r` | Reload `tmux.conf` |
| `prefix + a` | Send a literal `Ctrl+A` to the program inside |

**Windows & panes**

| Key | Action |
|-----|--------|
| `prefix + c` | New window (in current working directory) |
| `prefix + -` | Split pane vertically (stacked), in current working directory |
| `prefix + \` or `prefix + \|` | Split pane horizontally (side by side), in current working directory |
| `prefix + x` | Kill pane (no confirmation) |
| `prefix + X` | Kill window (no confirmation) |
| `prefix + h` / `j` / `k` / `l` | Select pane left / down / up / right |
| `prefix + Up` / `Down` / `Left` / `Right` | Resize pane 10 cells in that direction |
| `Shift+Left` / `Shift+Right` | Previous / next window (no prefix) |

**Vim-aware navigation & resize** (no prefix — passes through to Neovim when focused on a Vim pane)

| Key | Action |
|-----|--------|
| `Ctrl+H` / `Ctrl+J` / `Ctrl+K` / `Ctrl+L` | Move between panes / Vim splits |
| `Alt+H` / `Alt+J` / `Alt+K` / `Alt+L` | Resize the pane / Vim split |

**Copy mode** (vi keys)

| Key | Action |
|-----|--------|
| Scroll up | Enter copy mode |
| `v` | Begin selection |
| `Ctrl+V` | Toggle rectangle (block) selection |
| `y` | Copy selection to system clipboard (`wl-copy` / `pbcopy`) and exit |
| `prefix + Ctrl+V` | Paste the tmux buffer |
