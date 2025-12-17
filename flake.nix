{
  description = "Eli's system flake for UTM-based macOS VMs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-zed.url = "github:NixOS/nixpkgs/673584bb0bc5621ebc622698ec24f480ae1fe031";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      home-manager,
      treefmt-nix,
      ...
    }:
    let
      supportedSystems = [ "aarch64-darwin" ];

      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      commonConfig = import ./modules/nix-darwin/common.nix;
      mainConfig = import ./modules/nix-darwin/system.nix;

      darwinConfig =
        system: conf:
        nix-darwin.lib.darwinSystem {
          system = system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                zed-editor = inputs.nixpkgs-zed.legacyPackages.${system}.zed-editor;
              })
            ];
          };
          modules = [
            commonConfig
            nix-homebrew.darwinModules.nix-homebrew
            (
              { config, ... }:
              {
                nix-homebrew = {
                  enable = true;

                  # User owning the Homebrew prefix
                  user = config.users.primary;

                  taps = {
                    "homebrew/homebrew-core" = homebrew-core;
                    "homebrew/homebrew-cask" = homebrew-cask;
                  };

                  mutableTaps = false;
                };
                homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
              }
            )
            home-manager.darwinModules.default
            conf
          ];
          specialArgs = {
            inherit inputs;
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#macOSs-Virtual-Machine
      darwinConfigurations."macOSs-Virtual-Machine" = darwinConfig "aarch64-darwin" mainConfig;

      # Expose nix-darwin
      packages = nix-darwin.packages;

      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });
    };
}
