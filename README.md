# dotfiles-cesalberca

Personal [dotfiles](https://github.com/dotplug/dotfiles) plugin.

## Install

Install the [dotfiles](https://github.com/dotplug/dotfiles) framework first, then:

```shell
dotfiles install-plugin git@github.com:cesalberca/dotfiles-cesalberca.git
dotfiles install
```

## Layout

```shell
├─ 1password # 1Password SSH agent config: Personal vault block merged into the shared agent.toml
├─ bin       # Custom executables added to $PATH
├─ claude    # Claude Code config + hooks (linked into ~/.claude)
├─ git       # Git config (symlinked to $HOME)
├─ os        # macOS defaults + Brewfile + install.sh
└─ zsh       # Shell aliases, env, plugins
```

Each top-level folder is a **topic**:

- `topic/bin/` — PATH additions
- `topic/install.sh` — runs on `dotfiles install`
- `topic/*.zsh` — sourced by shell startup
- `topic/<name>.symlink` — symlinked to `$HOME/<name>`

---

## Tooling overview

### Custom binaries (`bin/`)

| Tool | Purpose |
|---|---|
| `optimize-img` | Strip metadata + recompress images (jpg/png/gif/webp), optional resize. |
| `resize-img` | Batch resize images in cwd to a max height. |
| `3d-screenshot` | Apply 3D perspective skew to a screenshot. |

```shell
optimize-img photo.jpg                       # 75-80% smaller, writes to ./optimized/
optimize-img ./screenshots -w 1600 -q 80     # resize + quality
optimize-img *.png --in-place                # overwrite originals
optimize-img ./assets -r                     # recurse

resize-img 800                               # resize all images in cwd to 800px max height
3d-screenshot shot.png                       # writes shot_3d.png
```

### Shell replacements (modern CLI)

| Tool | Replaces | Usage |
|---|---|---|
| `eza` | `ls` | `eza -lah --git --icons` — colored, git-aware listing |
| `bat` | `cat` | `bat file.ts` — syntax-highlighted paged view |
| `rg` (ripgrep) | `grep -r` | `rg "pattern" src/` — fast recursive search |
| `zoxide` (`z`) | `cd` | `z foo` — jump to frecent dirs matching `foo`; `zi` interactive picker |
| `fzf` | — | `Ctrl+R` history fuzzy search; `Ctrl+T` file picker; `**<TAB>` completion |
| `delta` | `diff` | Auto-wraps `git diff`/`git log` output (configured in `.gitconfig`) |
| `micro` | `nano`/`vim` | Modern terminal editor; `EDITOR=micro` |

### Version manager

| Tool | Purpose |
|---|---|
| `mise` | Replaces `volta` + `sdkman` + `nvm` + `pyenv`. Unified runtime manager. |

```shell
mise use -g node@22 python@3.12 java@21      # set global versions
mise use node@20                              # per-project (writes .mise.toml)
mise ls                                       # installed runtimes
mise upgrade                                  # update all
```

### Shell plugins

| Plugin | Effect |
|---|---|
| `zsh-autosuggestions` | Gray inline suggestion from history; `→` to accept |
| `zsh-syntax-highlighting` | Live command coloring (red = invalid, green = found) |

### Git tooling

```shell
g                  # alias → git
gs                 # git status
gl                 # git log graph
g c "msg"          # commit -m
g ch <branch>      # checkout
```

Diffs use `delta` with line numbers + navigation (`n`/`N` between hunks).

### AI / runtimes

| Tool | Purpose |
|---|---|
| `claude-code` | Anthropic CLI agent |
| `claude` (cask) | Claude desktop app |
| `deno` | Secure JS/TS runtime |
| `bun` | Fast JS runtime + bundler |

`claude-code` config lives in the `claude/` topic and is linked into `~/.claude` on `dotfiles install`: `settings.json`, the style hooks (stop the model emitting em/en dashes and arrow glyphs), and a set of reusable, project-agnostic Agent Skills under `claude/skills/` that are flat-linked into `~/.claude/skills/`. See [`claude/README.md`](claude/README.md).

### Media

| Tool | Purpose |
|---|---|
| `imagemagick` (`magick`) | Image manipulation (used by `optimize-img`, `resize-img`, `3d-screenshot`) |
| `jpegoptim` | Lossless JPEG optimizer (used by `optimize-img`) |
| `pngquant` | Lossy PNG quantizer (used by `optimize-img`) |
| `oxipng` | Lossless PNG optimizer (used by `optimize-img`) |
| `gifsicle` | GIF optimizer (used by `optimize-img`) |
| `webp` | `cwebp`/`dwebp` for WebP conversion |
| `gifski` | High-quality video → GIF |
| `ffmpeg` | Video/audio swiss knife |
| `yt-dlp` | YouTube/media downloader |
| `asciinema` | Record terminal sessions |

### Aliases quick reference

```
g     → git
gs    → git status
gl    → git log --all --decorate --oneline --graph
ll    → ls -FGlAhp
c     → clear
~     → cd ~
work  → cd ~/workspace
tmp   → cd ~/tmp
ip    → local IP
publicIp → public IP via ipinfo.io
lr    → recursive dir tree (less)
trash → move file to ~/.Trash
cd    → overridden to ls after cd
```

### Other CLIs

| Tool | Purpose |
|---|---|
| `mas` | Mac App Store CLI (used in `os/install.sh` for Lungo) |

---

## Update

```shell
dotfiles update-plugin dotfiles-cesalberca
```

## Uninstall

```shell
dotfiles uninstall-plugin dotfiles-cesalberca
```
