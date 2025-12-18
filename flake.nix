{
  description = "Eli's system flake for UTM-based macOS VMs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-nix = {
      url = "github:BatteredBunny/brew-nix";
      inputs.nix-darwin.follows = "nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.brew-api.follows = "brew-api";
    };
    brew-api = {
      url = "github:BatteredBunny/brew-api";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
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
      brew-nix,
      home-manager,
      nix-index-database,
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
                zed-editor = inputs.nixpkgs-master.legacyPackages.${system}.zed-editor;
              })
              inputs.brew-nix.overlays.default
            ];
          };
          modules = [
            commonConfig
            brew-nix.darwinModules.default
            home-manager.darwinModules.default
            nix-index-database.darwinModules.nix-index
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
