{
  description = "Bloodborne on shadPS4 — BB Launcher + emulator wrapper for Nix/NixOS";

  nixConfig = {
    extra-substituters = [ "https://amadejkastelic.cachix.org" ];
    extra-trusted-public-keys = [
      "amadejkastelic.cachix.org-1:EiQfTbiT0UKsynF4q3nbNYjNH6/l7zuhrNkQTuXmyOs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      pre-commit-hooks,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false;
        };

        shadps4 = pkgs.callPackage ./pkgs/shadps4 { };
        bb-launcher = pkgs.callPackage ./pkgs/bb-launcher { };
      in
      {
        packages = {
          inherit shadps4 bb-launcher;
          default = bb-launcher;
        };

        apps.default = {
          type = "app";
          program = "${bb-launcher}/bin/BB_Launcher";
        };

        checks.pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
          };
        };

        devShells.default = pkgs.mkShell {
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      overlays.default = final: prev: {
        shadps4 = prev.callPackage ./pkgs/shadps4 { };
        bb-launcher = prev.callPackage ./pkgs/bb-launcher { };
      };

      homeManagerModules.default = import ./modules/home-manager.nix;
    };
}
