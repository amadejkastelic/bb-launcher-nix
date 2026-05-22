# bb-launcher-nix

Bloodborne on Linux via [shadPS4](https://github.com/shadps4-emu/shadPS4) + [BB Launcher](https://github.com/rainmakerv3/BB_Launcher), packaged for Nix/NixOS.

## Quick start

```bash
nix run github:amadejkastelic/bb-launcher-nix
```

Skip the GUI and launch directly:

```bash
nix run github:amadejkastelic/bb-launcher-nix -- -n
```

## What's included

| Package | Description |
|---------|-------------|
| `bb-launcher` | BB Launcher — Bloodborne launcher/mod manager for shadPS4 |
| `shadps4` | shadPS4 PS4 emulator with audio and Wayland fixes |
| `default` | `bb-launcher` |

## NixOS / home-manager

Add as a flake input:

```nix
inputs.bb-launcher.url = "github:amadejkastelic/bb-launcher-nix";
```

### As a home-manager module (recommended)

If you use home-manager, import the module to get both packages plus managed config:

```nix
imports = [ inputs.bb-launcher.homeManagerModules.default ];

programs.bb-launcher = {
  enable = true;
  gameInstallPath = "/path/to/CUSA03173";
};
```

### As packages only

```nix
environment.systemPackages = [
  inputs.bb-launcher.packages.x86_64-linux.bb-launcher
];
```

## Cachix

Set up cachix so you don't have to build the packages locally:

```nix
nix.settings = {
  substituters = [ "https://amadejkastelic.cachix.org" ];
  trusted-public-keys = [ "amadejkastelic.cachix.org-1:EiQfTbiT0UKsynF4q3nbNYjNH6/l7zuhrNkQTuXmyOs=" ];
};
```

## Notes

- Requires an x86-64-v3 capable CPU (Haswell/Excavator or newer, ~2014+)
- You need a Bloodborne PS4 game dump (CUSA03173) — this flake only provides the emulator and launcher
- BB Launcher data directory: `~/.local/share/BBLauncher/` (config, mods, saves)

## License

- shadPS4: GPL-2.0-or-later
- BB Launcher: GPL-3.0-or-later
