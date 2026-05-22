{ packages }:

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.bb-launcher;

  shadps4Pkg =
    if cfg.wrapperCommand != null then
      pkgs.writeShellScriptBin "shadps4" ''
        exec ${cfg.wrapperCommand} ${lib.getExe cfg.shadps4.package} "$@"
      ''
      // {
        meta = cfg.shadps4.package.meta // {
          mainProgram = "shadps4";
        };
      }
    else
      cfg.shadps4.package;

  shadps4Exe = lib.getExe shadps4Pkg;

  bbLauncherPkg = packages.x86_64-linux.bb-launcher;

  tomlFormat = pkgs.formats.toml { };

  launcherConfig = tomlFormat.generate "LauncherSettings.toml" {
    Backups = {
      BackupNumber = cfg.settings.backupNumber;
      BackupInterval = cfg.settings.backupInterval;
      BackupSaveEnabled = cfg.settings.backupSaveEnabled;
    };
    Launcher = {
      AutoUpdateEnabled = false;
      SoundFixEnabled = cfg.settings.soundFixEnabled;
      PortableFolderinLauncherFolder = false;
      Theme = cfg.settings.theme;
      shadPath-New = shadps4Exe;
      ApiKey = "";
      installPath = if cfg.gameInstallPath != null then cfg.gameInstallPath else "";
      SevenZipPath = "";
    };
    shadUpdater = {
      DefaultFolder = "";
      AutoUpdateVersionsEnabled = true;
      AutoUpdateShadEnabled = false;
    };
    Trophy = {
      ShowEarned = true;
      ShowUnearned = true;
      ShowHidden = false;
    };
  };
in

{
  options.programs.bb-launcher = {
    enable = mkEnableOption "Bloodborne via BB Launcher + shadPS4";

    gameInstallPath = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/path/to/CUSA03173";
      description = "Path to Bloodborne game dump.";
    };

    wrapperCommand = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "gamemoderun mangohud";
      description = "Command to prefix shadPS4 with (e.g. gamemoderun, mangohud).";
    };

    shadps4 = {
      package = mkOption {
        type = types.package;
        default = packages.x86_64-linux.shadps4;
        description = "shadPS4 package to use.";
      };
    };

    settings = {
      theme = mkOption {
        type = types.enum [
          "Dark"
          "Light"
        ];
        default = "Dark";
      };

      soundFixEnabled = mkOption {
        type = types.bool;
        default = true;
        description = "Patch save file for 60fps sound fix.";
      };

      backupSaveEnabled = mkOption {
        type = types.bool;
        default = false;
      };

      backupInterval = mkOption {
        type = types.enum [
          5
          10
          15
          20
          25
          30
        ];
        default = 10;
      };

      backupNumber = mkOption {
        type = types.ints.between 1 5;
        default = 2;
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      bbLauncherPkg
    ];

    xdg.dataFile."BBLauncher/LauncherSettings.toml".source = launcherConfig;
  };
}
