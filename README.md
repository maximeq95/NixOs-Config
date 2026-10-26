# NixOS WSL Development Environment Configuration

A reproducible, declarative NixOS configuration for WSL (Windows Subsystem for Linux) powered by **Nix Flakes** and **Home Manager**.

This project bootstraps and manages a fully-configured developer environment on Windows WSL, complete with modern CLI utilities, shell optimizations, cloud/DevOps tooling, and declarative IDE configurations.

All the configuration logic lives in the [`NixOs-opinionated`](https://github.com/pchesneau/NixOs-opinionated) modules (input `opinionated`); this repository only enables them and declares the main user with the `base`, `ops`, `dev` and `llm` roles. See that repository's README for every available option and role.

---

## 🌟 What This Project Does

- **Declarative NixOS on WSL**: Leverages [`NixOS-WSL`](https://github.com/nix-community/NixOS-WSL) for lightweight, high-performance Linux on Windows without the overhead of standard virtualization.
- **Home Manager Integration**: Declaratively manages user profiles, dotfiles, and user packages.
- **Modern Shell & Terminal**:
  - **Zsh** with Oh-My-Zsh plugins (`git`, `ssh`, `kubectl`, `terraform`, `kubectx`, `helm`, `ansible`).
  - **Starship Prompt**: Custom Catppuccin Mocha powerline theme with JetBrains Mono Nerd Font glyphs. Inside a `nix-shell` / `nix develop` / `nix run`, the loaded packages are shown (via `any-nix-shell`) right before the prompt character, next to a `direnv` indicator reporting whether the directory's `.envrc` is allowed and loaded.
  - **Zellij**: Modern terminal multiplexer pre-configured with Zsh integration.
  - **direnv + nix-direnv**: Per-directory environments loaded on `cd`, with the built shell cached and kept alive as a GC root so re-entering a project is instant.
  - **Modern CLI Replacements**: `eza` (for `ls`), `bat` (for `cat`), `ripgrep` (`rg`), `fd`, `fzf`, `jq`, `up`, `lazyssh`.
- **Development & IDE**:
  - **LazyVim**: Neovim configured through the [`pfassina/lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) Home Manager module, with the `lang.{nix,python,java,json,yaml,terraform,markdown}` extras enabled. `nvim` is the default `$EDITOR`, aliased to `vi`/`vim`.
  - **IntelliJ IDEA**: Declaratively provisioned with custom plugins via `nix-jetbrains-plugins` (File Watcher, Junie, MCP Server, ML LLM, ACP).
  - **GitHub Copilot CLI** & development toolchains.
  - **Nix Tooling**: `nixfmt` code formatter and `nh` helper.
- **Cloud & DevOps Ready**: Preloaded with `kubectl`, `helm`, `fluxcd`, `terraform`, and `ansible`. Azure CLI is available through `home-manager.users.<name>.opinionated.roles.ops.azure.enable`.
- **Automatic Store Cleanup**: `nh clean` removes generations older than 14 days and the store is optimised, weekly.
- **Modular User Configuration**: Keeps user identities and corporate root certificates separated in `/etc/nixos-config/`.

---

## 📁 Repository Structure

| File | Purpose |
| :--- | :--- |
| `flake.nix` | Flake entry point: inputs (`nixpkgs`, `opinionated`, `/etc/nixos-config`) and the `nixos` system. |
| `configuration.nix` | Host settings: state version, enabled opinionated modules, main user and its roles, additional certificates. |
| `exemple_profile.nix` | Example profile template for defining user identity (`username`, `gitUserName`, `gitUserEmail`). |

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

The `opinionated` input currently points to a local checkout (`path:/home/pierre/NixOs-opinionated`); adjust its `url` in `flake.nix` to where the modules live on your machine, or to their GitHub URL.

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
nh os switch
```

### Updating Flake Inputs

To update all flake inputs (`nixpkgs`, `opinionated` and its own inputs such as `home-manager`, `nixos-wsl`) to their latest versions:

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

Neovim is provided by the [`pfassina/lazyvim-nix`](https://github.com/pfassina/lazyvim-nix) Home Manager module (`programs.lazyvim` in `home_base.nix`). Everything LazyVim would normally fetch at runtime is resolved by Nix instead:

- Plugins are injected into `lazy.nvim` as pinned local (`dev`) specs pointing at `/nix/store` paths, so `lazy-lock.json` is never written.
- Treesitter parsers are prebuilt and linked into Neovim's data directory.
- `mason.nvim` is disabled, because the prebuilt binaries it downloads cannot run outside an FHS environment. LSP servers, formatters and linters come from `programs.lazyvim.extraPackages` and the enabled extras instead.

Consequences:

- `~/.config/nvim` is read-only. Customise Neovim through `programs.lazyvim.config.{options,keymaps,autocmds}` and `programs.lazyvim.plugins` in `home_base.nix`, then rebuild.
- `:Lazy update` does nothing. Plugins move forward when the `lazyvim` flake input is updated:

  ```bash
  cd /etc/nixos
  sudo nix flake update opinionated/lazyvim
  sudo nixos-rebuild switch --flake .#nixos
  ```

To add a language, enable the matching LazyVim extra in `configuration.nix`, e.g.:

```nix
home-manager.users.<name>.programs.lazyvim.extras.lang.go = {
  enable = true;
  installDependencies = true;   # pull the extra's tools from nixpkgs
};
```

---

## 📄 License

This configuration is distributed under the terms defined in the [LICENSE](LICENSE) file.
