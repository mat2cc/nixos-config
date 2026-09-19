# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a multi-host NixOS configuration repository using flakes, home-manager, and nix-darwin. It manages configurations for:
- **nixos**: Primary x86_64-linux workstation with Sway WM
- **rpi4**: Raspberry Pi 4 server
- **darwin**: macOS system (nix-darwin)

## Common Commands

### Building and Switching Configurations

```bash
# Rebuild NixOS system configuration
sudo nixos-rebuild switch --flake .#nixos

# Rebuild for rpi4 host
sudo nixos-rebuild switch --flake .#rpi4

# Rebuild Darwin (macOS)
darwin-rebuild switch --flake .#"Matt's Macbook"

# Build without switching (test first)
nixos-rebuild build --flake .#nixos

# Check flake for errors
nix flake check

# Update flake inputs
nix flake update

# Update specific input only
nix flake lock --update-input nixpkgs
```

### Home Manager

Home Manager is integrated via NixOS/Darwin modules, not standalone. Changes to home configuration rebuild with system config.

### Secrets Management

This repo uses sops-nix for secrets management:

```bash
# Edit secrets (requires age key at ~/.config/sops/age/keys.txt)
sops secrets/secrets.yaml

# The public age key is defined in .sops.yaml
```

Secrets are configured in `hosts/nixos/home.nix`:
- `sops.secrets.github-ssh-key`: GitHub SSH authentication
- `sops.secrets.rpi4-ssh-key`: RPI4 SSH authentication

## Architecture

### Flake Structure

The flake defines three system configurations:
- `nixosConfigurations.nixos`: Primary Linux workstation
- `nixosConfigurations.rpi4`: Raspberry Pi server
- `darwinConfigurations."Matt's Macbook"`: macOS system

Key flake inputs:
- `nixpkgs`: nixos-unstable channel
- `home-manager`: User environment management (follows nixpkgs)
- `nix-darwin`: macOS system configuration
- `sops-nix`: Secret management with age/sops

### Directory Layout

```
hosts/
├── common.nix           # Shared home-manager config for all Linux hosts
├── common-linux.nix     # Linux-specific shared config (currently minimal)
├── nixos/
│   ├── configuration.nix  # System-level config
│   ├── home.nix          # User config (imports common.nix)
│   └── hardware-configuration.nix
├── rpi4/
│   ├── configuration.nix
│   ├── home.nix          # Imports common.nix
│   └── hardware-configuration.nix
└── darwin/
    ├── configuration.nix
    └── hardware-configuration.nix

modules/
├── fish.nix    # Fish shell with tide prompt, eza aliases
├── tmux.nix    # Tmux with custom options (work/play keybindings)
└── sway.nix    # Sway WM configuration

config/         # Dotfiles symlinked to ~/.config
bin/            # Scripts symlinked to ~/.local/bin
secrets/        # Encrypted secrets (sops-nix)
```

### Host-Specific Patterns

**nixos host:**
- Uses `username` variable passed through `specialArgs`
- Enables Sway WM with tuigreet display manager
- SSH server enabled (user: mattc only, no root login)
- Bash auto-launches fish shell
- Home config includes sops-nix secrets and SSH config

**rpi4 host:**
- Note: There's a bug in flake.nix line 68 - it references `./hosts/nixos/home.nix` instead of `./hosts/rpi4/home.nix`
- Intended as a server (no GUI packages)

**darwin host:**
- Currently basic setup, no home-manager integration (commented out)

### Module System

**modules/tmux.nix** defines a custom option `myprograms.tmux.tmuxType`:
- `"work"`: Keybindings for work projects (api, dev-panel, auto, auth, proxy)
- `"play"`: Keybindings for personal projects (nixos-config, chip8)

Usage: Set `myprograms.tmux.tmuxType = "play";` in home configuration.

**modules/fish.nix**:
- Enables fish shell with tide prompt plugin
- Aliases: `ls` → `eza`, `l` → `eza -lah --icons`, `vi`/`vim` → `nvim`, `gs`/`gl` for git

### Common Configuration Pattern

The `hosts/common.nix` file provides shared home-manager configuration:
- Symlinks `config/` to `~/.config`
- Symlinks `bin/` to `~/.local/bin`
- Git configuration (user: mat2cc)
- Starship prompt configuration
- Common CLI tools (neovim, ripgrep, fzf, tmux, gh, sops, etc.)

Individual host `home.nix` files import `../common.nix` and add host-specific packages/config.

### Key Conventions

1. The `username` variable is passed via `specialArgs` and used for user creation
2. User home directories use `"/home/${username}"` pattern
3. Experimental features `nix-command` and `flakes` are enabled system-wide
4. All systems use `system.stateVersion = "25.11"` or `home.stateVersion = "25.05"`
5. Bash is configured to automatically launch fish shell on interactive sessions
6. SSH keys are managed through home-manager (public keys in home.nix, private via sops)

## Development Workflow

When modifying this configuration:

1. Edit the relevant `.nix` files
2. Test with `nixos-rebuild build --flake .#<hostname>`
3. If build succeeds, apply with `nixos-rebuild switch --flake .#<hostname>`
4. For secrets, edit with `sops secrets/secrets.yaml`
5. Commit changes to git

Note: `hardware-configuration.nix` files are auto-generated by NixOS and should not be manually edited unless necessary.
