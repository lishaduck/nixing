{
  description = "Eli's system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs?rev=8c91a71d13451abc40eb9dae8910f972f979852f";
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
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixos-wsl,
      ...
    }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      # Small tool to iterate over each systems
      eachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});

      # Eval the treefmt modules from ./treefmt.nix
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      wslConfig =
        system: options:
        nixpkgs.lib.nixosSystem {
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.default
            nix-index-database.nixosModules.nix-index
            { nixpkgs.hostPlatform = system; }
            ./modules/nixos/common.nix
            options
          ];
          specialArgs = {
            inherit inputs;
          };
        };

      darwinConfig =
        system: options:
        nix-darwin.lib.darwinSystem {
          system = system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [
              (final: prev: {
                zed-editor = inputs.nixpkgs-master.legacyPackages.${prev.system}.zed-editor;
              })
              inputs.brew-nix.overlays.default
            ];
          };
          modules = [
            brew-nix.darwinModules.default
            home-manager.darwinModules.default
            nix-index-database.darwinModules.nix-index
            ./modules/nix-darwin/common.nix
            options
          ];
          specialArgs = {
            inherit inputs;
          };
        };
    in
    {
      # Build nixos flake using:
      # $ nh os build ~/nixing
      nixosConfigurations = {
        nixos = wslConfig "x86_64-linux" ./modules/nixos/system.nix;
      };

      # Build darwin flake using:
      # $ nh darwin build ~/Developer/dotfiles
      darwinConfigurations = {
        "macOSs-Virtual-Machine" = darwinConfig "aarch64-darwin" ./modules/nix-darwin/system.nix;
      };

      # Expose nix-darwin
      packages = nix-darwin.packages;

      # for `nix fmt`
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.wrapper);
      # for `nix flake check`
      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.stdenv.hostPlatform.system}.config.build.check self;
      });
    };
}
