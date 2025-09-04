{
  description = "Eli's system flake for UTM-based macOS VMs";

  inputs = {
    systems.url = "github:nix-systems/default";
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      systems,
      nixpkgs,
      nix-darwin,
      home-manager,
      treefmt-nix,
      ...
    }:
    let
      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      commonConfig = import ./modules/nix-darwin/common.nix;
      mainConfig = import ./modules/nix-darwin/system.nix;

      darwinConfig =
        system: conf:
        nix-darwin.lib.darwinSystem {
          system = system;
          pkgs = import nixpkgs {
            system = system;
            config.allowUnfree = true;
          };
          modules = [
            home-manager.darwinModules.default
            conf
            commonConfig
          ];
          specialArgs = {
            inherit system inputs;
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#macOSs-Virtual-Machine
      darwinConfigurations."macOSs-Virtual-Machine" = darwinConfig "aarch64-darwin" mainConfig;

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."macOSs-Virtual-Machine".pkgs;

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
