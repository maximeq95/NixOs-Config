# NixOS WSL Development Environment Configuration

A reproducible, declarative NixOS configuration for WSL (Windows Subsystem for Linux) powered by **Nix Flakes** and **Home Manager**.

This project bootstraps and manages a fully-configured developer environment on Windows WSL, complete with modern CLI utilities, shell optimizations, cloud/DevOps tooling, and declarative IDE configurations.

---

## 🌟 What This Project Does

- **Declarative NixOS on WSL**: Leverages [`NixOS-WSL`](https://github.com/nix-community/NixOS-WSL) for lightweight, high-performance Linux on Windows without the overhead of standard virtualization.
- **Home Manager Integration**: Declaratively manages user profiles, dotfiles, and user packages.
- **Modern Shell & Terminal**:
  - **Zsh** with Oh-My-Zsh plugins (`git`, `ssh`, `kubectl`, `azure`, `terraform`, `kubectx`, `helm`, `ansible`).
  - **Starship Prompt**: Custom Catppuccin powerline theme (palette from [catppuccin/nix](https://github.com/catppuccin/nix), like the rest of the home) with JetBrains Mono Nerd Font glyphs. Inside a `nix-shell` / `nix develop` / `nix run`, the loaded packages are shown (via `any-nix-shell`) right before the prompt character, next to a `direnv` indicator reporting whether the directory's `.envrc` is allowed and loaded.
  - **Zellij**: Modern terminal multiplexer pre-configured with Zsh integration.
  - **direnv + nix-direnv**: Per-directory environments loaded on `cd`, with the built shell cached and kept alive as a GC root so re-entering a project is instant.
  - **Modern CLI Replacements**: `eza` (for `ls`), `bat` (for `cat`), `ripgrep` (`rg`), `fd`, `fzf`, `jq`, `up`, `lazyssh`.
- **Development & IDE**:
  - **LazyVim**: Neovim configured through the [`pfassina/lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) Home Manager module, with the `lang.{nix,python,java,json,yaml,terraform,markdown}` extras enabled. `nvim` is the default `$EDITOR`, aliased to `vi`/`vim`.
  - **revim**: the default editor (Neovim via nixvim, also `vi` / `vim`) and a yazi + zellij IDE around it, packaged in this flake (see [Working with revim](#-working-with-revim)). `home/revim.nix` turns LazyVim off, since both ship an `nvim`.
  - **IntelliJ IDEA**: Declaratively provisioned with custom plugins via `nix-jetbrains-plugins` (File Watcher, Junie, MCP Server, ML LLM, ACP).
  - **GitHub Copilot CLI** & development toolchains.
  - **Nix Tooling**: `nixfmt` code formatter and `nh` helper.
- **Cloud & DevOps Ready**: Preloaded with `azure-cli`, `kubectl`, `helm`, `fluxcd`, `terraform`, and `ansible`.
- **Modular User Configuration**: Keeps user identities and corporate root certificates separated in `/etc/nixos-config/`.

---

## 📁 Repository Structure

| File | Purpose |
| :--- | :--- |
| `flake.nix` | Flake entry point: inputs, `overlays.default`, `homeModules.revim`, per-system `packages` / `formatter` / `checks` (via `flake-utils`), and `nixosConfigurations.nixos`, which wires the inputs and `/etc/nixos-config` into the modules below. |
| `hosts/nixos/default.nix` | The `nixos` host: platform, state version, the main user's shell, Home Manager settings. |
| `hosts/nixos/customisation.nix` | System customizations: time zone, unfree package whitelisting, Nerd Fonts, Nix settings (experimental features, trusted users, GC), and zsh. |
| `hosts/nixos/wsl.nix` | Base WSL configurations (WSL enablement, Windows driver interop, path isolation). |
| `home/default.nix` | Reusable Home Manager module configuring user packages, shell (Zsh + Starship), direnv, Git, Zellij, LazyVim, the theme, and IDE setup. |
| `home/revim.nix` | revim as the editor, in place of LazyVim. |
| `pkgs/revim/` | The `revim` package (`package.nix`, a `callPackage` function), its nixvim configuration (`nvim.nix`), the `revim` command (`revim.sh`) and its zellij layout. |
| `modules/home-manager/revim/` | The `programs.revim` Home Manager module (`homeModules.revim`). |
| `exemple_profile.nix` | Example profile template for defining user identity (`username`, `gitUserName`, `gitUserEmail`). |

### Flake outputs

| Output | What |
| :--- | :--- |
| `overlays.default` | Adds `revim` and `buildIdeWithPlugins` (from `nix-jetbrains-plugins`) to nixpkgs. The host uses it too. |
| `packages.<system>.revim` (and `default`) | revim, built with the overlay. |
| `homeModules.revim` | The `programs.revim` module. |
| `formatter.<system>` | `nixfmt-tree`, for `nix fmt`. |
| `checks.<system>.revim` | The revim module, built for a throwaway user. |
| `nixosConfigurations.nixos` | This machine. |

---

## 🚀 Getting Started

### Prerequisites

1. **Windows 10/11** with WSL2 enabled.
2. A **NixOS WSL** distribution installed (e.g. from [NixOS-WSL releases](https://github.com/nix-community/NixOS-WSL/releases)).
3. A patched **Nerd Font** installed on Windows (e.g. *JetBrains Mono Nerd Font*) for terminal icons and powerline glyphs.

---

### Step 1: Configure User Profile

The flake expects your user profile configuration to be located at `/etc/nixos-config/mainUser.nix`.

1. Create the configuration directory:
   ```bash
   sudo mkdir -p /etc/nixos-config
   ```

2. Create `/etc/nixos-config/mainUser.nix` based on `exemple_profile.nix`:
   ```nix
   {
     username = "<your-username>";
     gitUserName = "Your Name";
     gitUserEmail = "your.email@example.com";
   }
   ```

3. *(Optional)* If your environment requires custom corporate root certificates, place them at:
   ```
   /etc/nixos-config/additional-trusts.crt
   ```

---

### Step 2: Clone / Copy this Configuration

Clone or copy this repository to `/etc/nixos/`:

```bash
sudo git clone <repo-url> /etc/nixos
# or copy your existing files to /etc/nixos/
cd /etc/nixos
```

---

### Step 3: Bootstrap the System

Build and activate the flake configuration for the first time:

```bash
sudo nixos-rebuild boot --extra-experimental-features "nix-command flakes" --flake .#nixos
```

---

### Step 4: Restart the WSL Instance

To ensure all systemd services, users, and default shells are cleanly loaded, restart the WSL container from **PowerShell / Command Prompt** in Windows:

```powershell
wsl -t NixOS
wsl -d NixOS --user root exit
wsl -t NixOs
wsl --shutdown
```

Then start NixOS again:

```powershell
wsl -d NixOS
```

You should now log in directly into your user account with Zsh, Starship prompt, and all tools available.

---

## 🔄 Managing and Updating the System

### Rebuilding After Changes

When you make changes to files in `/etc/nixos/` or your user profile:

```bash
sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

Or using the installed `nh` helper:

```bash
nh os switch /etc/nixos
```

### Updating Flake Inputs

To update all flake inputs (such as `nixpkgs`, `home-manager`, `nixos-wsl`) to their latest versions:

```bash
cd /etc/nixos
sudo nix flake update
sudo nixos-rebuild switch --flake .#nixos
```

---

## 🛠️ Key Aliases & Utilities

| Command | Alias / Tool | Description |
| :--- | :--- | :--- |
| `ls` | `eza` | Modern replacement for `ls` |
| `ll` | `eza -l --git` | Long listing with Git status |
| `la` | `eza -la --git` | List all including hidden files |
| `lt` | `eza --tree --level=2` | Tree directory listing |
| `cat` | `bat --paging=never` | Syntax-highlighted file viewer |
| `zellij` | `zellij` | Terminal workspace / multiplexer |
| `fzf` | `fzf` | Interactive fuzzy finder |
| `nh` | `nh` | Nix CLI companion / helper |
| `nvim` | LazyVim | Neovim with LazyVim, also reachable as `vi` / `vim` |
| `direnv allow` | `direnv` | Trust the current directory's `.envrc` so it loads on `cd` |
| `revim` | revim | Neovim IDE: `revim [dir]`, `revim git`, `revim grep` |
| `idea` | JetBrains IDEA | Pre-configured with custom JetBrains plugins |

---

## 🧭 Working with direnv

`direnv` is enabled with the `nix-direnv` integration. In any project directory:

```bash
echo "use flake" > .envrc   # or: echo "use nix" > .envrc
direnv allow
```

Entering the directory then loads the project's dev shell automatically, and the Starship prompt shows a leaf glyph with the current state (loaded / not loaded, plus a lock when the `.envrc` is not allowed yet). `nix-direnv` caches the evaluated shell and registers it as a GC root, so subsequent entries are instant and the closure survives `nix-collect-garbage`.

---

## ✏️ Working with LazyVim

Neovim is provided by the [`pfassina/lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) Home Manager module (`programs.lazyvim` in `home/default.nix`; off while `home/revim.nix` is imported). Everything LazyVim would normally fetch at runtime is resolved by Nix instead:

- Plugins are injected into `lazy.nvim` as pinned local (`dev`) specs pointing at `/nix/store` paths, so `lazy-lock.json` is never written.
- Treesitter parsers are prebuilt and linked into Neovim's data directory.
- `mason.nvim` is disabled, because the prebuilt binaries it downloads cannot run outside an FHS environment. LSP servers, formatters and linters come from `programs.lazyvim.extraPackages` and the enabled extras instead.

Consequences:

- `~/.config/nvim` is read-only. Customise Neovim through `programs.lazyvim.config.{options,keymaps,autocmds}` and `programs.lazyvim.plugins` in `home/default.nix`, then rebuild.
- `:Lazy update` does nothing. Plugins move forward when the `lazyvim` flake input is updated:

  ```bash
  cd /etc/nixos
  sudo nix flake update lazyvim
  sudo nixos-rebuild switch --flake .#nixos
  ```

To add a language, enable the matching LazyVim extra, e.g.:

```nix
programs.lazyvim.extras.lang.go = {
  enable = true;
  installDependencies = true;   # pull the extra's tools from nixpkgs
};
```

---

## 🧩 Working with revim

revim is Neovim configured with nixvim (every plugin, language server and formatter from nixpkgs: no plugin manager, no Mason), and an IDE around it: **yazi** as the file pane and Neovim side by side in a **zellij** tab, plus **lazygit** and Claude Code.

```
┌ files ┐┌──────── editor (nvim) ────────┐
│ yazi  ││ [file1] │ [file2] │ [file3] … │  ← barbar tabs
│       ││                               │
├───────┴┴────────── terminal ───────────┤
└────────────────────────────────────────┘
```

Each IDE tab runs its own Neovim server: picking a file in yazi or in a picker opens it as a tab of the Neovim next to it.

| Command | What it does |
| :--- | :--- |
| `revim [dir]` | The IDE on a directory: a new tab inside zellij, else a `revim-<dir>` session. |
| `revim file…` | Edit, as `nvim file…`. |
| `revim git [dir]` | lazygit in a tab of its own. |
| `revim grep [query]` | Live ripgrep search; Enter opens the match in the tab's Neovim. |
| `revim find` | Fuzzy file picker; Enter opens the file in the tab's Neovim. |

In the IDE: Enter or a click in yazi opens a file, `s` / `S` find a file / search contents, `Alt-t` adds a shell to the terminal stack, `Alt-q` closes the tab. `Ctrl` + arrows move to the pane in that direction, from any pane (`Ctrl-h/j/k/l` also do in Neovim, crossing its own windows first). In Neovim, `Tab` / `Shift-Tab` go to the next / previous file, and `:q` (`:wq`, `:x`) closes the file rather than the editor, asking first whether to save unsaved changes; `:qa` quits. Neovim has VSCode-style keys (`Ctrl-s`, `Ctrl-p`, `F12`, `Ctrl-/`…) and a which-key menu on `<space>`.

### The package

`pkgs/revim/package.nix` is a regular `callPackage` function, added to nixpkgs by `overlays.default` with nixvim's `lib.evalNixvim`. It is built against the host's nixpkgs, which must allow the unfree `barbar.nvim` and `claude-code`, and tuned with `.override`:

```nix
pkgs.revim.override {
  flavor = "latte"; # Catppuccin flavor
  clipboard = "wl-copy"; # "osc52" (default), "pbcopy", "wl-copy" or null
  extraConfig.opts.relativenumber = true; # any nixvim module
}
```

It provides `nvim` (also as `vi` and `vim`) and `revim`.

### The Home Manager module

`homeModules.revim` installs `pkgs.revim`, overridden from its options, and configures what the IDE runs in: yazi (opening files in the tab's Neovim), zellij (mouse, clipboard, keys) and lazygit. `home/revim.nix` sets it up for this machine.

The theme is the host's. When it sets a Catppuccin one with catppuccin/nix (`catppuccin.enable`), Neovim takes its `catppuccin.flavor`, and yazi and lazygit its ports (flavor and accent); without one, Neovim stays Catppuccin Mocha. The module does not depend on catppuccin/nix.

| Option | Default | |
| :--- | :--- | :--- |
| `programs.revim.enable` | `false` | |
| `programs.revim.package` | `pkgs.revim` | From the overlay. |
| `programs.revim.defaultEditor` | `false` | `EDITOR` and `VISUAL` set to `nvim`. |
| `programs.revim.clipboard` | `"osc52"` | Neovim's `g:clipboard` and zellij's `copy_command`. |
| `programs.revim.extraConfig` | `{ }` | Extra nixvim configuration. |

### Hacking on it

```bash
nix run .#revim -- file.txt   # try the editor without rebuilding the system
nix fmt                       # nixfmt over the tree
nix flake check               # evaluates the host, builds the revim module for a throwaway user
```

---

## 📄 License

This configuration is distributed under the terms defined in the [LICENSE](LICENSE) file.
