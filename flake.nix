{
  description = "Eli's system flake for UTM macOS VMs.";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-index-database,
      ...
    }:
    let
      device = "macOSs-Virtual-Machine";
      arch = "aarch64-darwin";
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
            nix-index-database.darwinModules.nix-index
            conf
            commonConfig
          ];
          specialArgs = {
            inherit system inputs arch;
          };
        };
    in
    {
      darwinConfigurations.${device} = darwinConfig arch mainConfig;

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations.${device}.pkgs;

      # Expose nix-darwin
      packages = nix-darwin.packages;

      formatter.${arch} = self.darwinPackages.nixfmt-rfc-style;
    };
}
