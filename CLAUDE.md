# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Nix flake-based Neovim configuration using lazy.nvim for plugin management. The unique architecture uses Nix to declaratively manage plugins while lazy.nvim handles runtime loading, bridging Nix's reproducibility with Neovim's plugin ecosystem.

## Development Commands

```bash
# Format code (nixfmt for .nix, stylua for .lua)
nix fmt

# Format check (CI mode)
nix fmt -- --ci

# Flake check
nix flake check

# Build package
nix build

# Run Neovim with this config
nix run

# Development shell (generates .mcp.json)
nix develop
```

## Architecture

### Plugin Management Flow

1. **Plugin Declaration** (`nix/pkgs/vim-plugins/default.nix`)
   - Custom plugins built with `pkgs.vimUtils.buildVimPlugin`
   - Standard plugins from `pkgs.vimPlugins`
   - All plugin sources are pinned with specific revisions and hashes

2. **Plugin Normalization** (`nix/plugins.nix`)
   - Converts plugin pnames to placeholder format (e.g., `nvim-treesitter` → `nvim_treesitter`)
   - Returns attribute set of all plugins keyed by normalized names
   - Includes custom `lazy_nvim` build from `nix/pkgs/vim-plugins/lazy-nvim.nix`

3. **Config Placeholder Substitution** (`nix/lib/make-neovim-wrapper.nix`)
   - Builds Neovim config derivation from `nvim/` directory
   - Substitutes `@plugin_name@` placeholders in all files with Nix store paths
   - Example: `@lazy_nvim@` in `nvim/init.lua:4` → `/nix/store/.../lazy.nvim`
   - Creates wrapper script that sets `MY_CONFIG_PATH` and adds tools to `PATH`

4. **Runtime Loading** (`nvim/lua/plugins/*.lua`)
   - Each plugin has a Lua config file returning lazy.nvim spec
   - Plugins use `dir = "@plugin_name@"` instead of GitHub URLs
   - lazy.nvim loads plugins from substituted Nix store paths
   - Plugin management features disabled (install/update/check)

### Tool Management

External tools (LSPs, formatters, linters) are declared in `nix/tools.nix` and added to PATH via the wrapper script. This provides:
- Telescope search tools (ripgrep, fd)
- LSP servers (rust-analyzer, gopls, clang-tools, etc.)
- Formatters for conform.nvim (nixfmt, rustfmt, biome, etc.)

### Lua Configuration Structure

- `nvim/init.lua` - Entry point, sets up lazy.nvim and core settings
- `nvim/lua/plugins/` - One file per plugin with lazy.nvim spec
- `nvim/lua/config/` - Shared configuration modules

## Adding New Plugins

1. Add to `nix/pkgs/vim-plugins/default.nix`:
   - If from nixpkgs: add `pkgs.vimPlugins.plugin-name` to list
   - If custom: build with `vimUtils.buildVimPlugin` (see existing examples)

2. Create config in `nvim/lua/plugins/plugin_name.lua`:
   ```lua
   return {
     dir = "@plugin_name@", -- placeholder will be substituted
     lazy = false, -- or specify load conditions
     config = function()
       -- plugin setup
     end,
   }
   ```

3. Plugin normalization is automatic (hyphens/dots → underscores)

## Adding External Tools

Add packages to the list in `nix/tools.nix`. They'll be available in PATH when running Neovim via the wrapper.

## MCP Integration (mcp-nixos)

This project integrates `mcp-nixos` (https://github.com/utensils/mcp-nixos) for Claude Code. The development shell automatically generates `.mcp.json` with the NixOS MCP server configuration.

### Available MCP Tools

When working in this repository with Claude Code, you have access to:

**NixOS Package/Option Search:**
- `mcp__nixos__nixos_search` - Search packages, options, programs (supports channels: unstable, stable, 25.05)
- `mcp__nixos__nixos_info` - Get detailed package/option information
- `mcp__nixos__nixos_stats` - View package and option counts per channel
- `mcp__nixos__nixos_channels` - List available channels

**Flakes:**
- `mcp__nixos__nixos_flakes_search` - Find community flakes and packages
- `mcp__nixos__nixos_flakes_stats` - Ecosystem statistics

**Version History (NixHub):**
- `mcp__nixos__nixhub_package_versions` - Get package version history with commit hashes for reproducible builds
- `mcp__nixos__nixhub_find_version` - Find specific package versions

**Home Manager:**
- `mcp__nixos__home_manager_search` - Query user configuration options
- `mcp__nixos__home_manager_info` - Get option details (with typo suggestions)
- `mcp__nixos__home_manager_stats` - View 131 available categories
- `mcp__nixos__home_manager_list_options` - Browse all categories
- `mcp__nixos__home_manager_options_by_prefix` - Explore by prefix (e.g., `programs.git`)

**Darwin (macOS):**
- `mcp__nixos__darwin_search` - Query macOS-specific options
- `mcp__nixos__darwin_info` - Get option details
- `mcp__nixos__darwin_stats` - View 21 available categories
- `mcp__nixos__darwin_list_options` - Browse categories
- `mcp__nixos__darwin_options_by_prefix` - Explore by prefix (e.g., `system.defaults`)

### Using MCP Tools

Use these tools when working with Nix code to get accurate, real-time package information instead of relying on potentially outdated training data. For example:
- Finding package versions and commit hashes for pinning
- Exploring Home Manager configuration options
- Searching for Darwin system defaults
- Looking up flake packages

## CI/CD

GitHub Actions workflow (`.github/workflows/ci.yml`) runs on PRs and main branch:
- Format checking with treefmt
- Flake validation
- Build verification on Ubuntu and macOS
