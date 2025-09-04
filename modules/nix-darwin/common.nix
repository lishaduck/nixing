{
  inputs,
  config,
  system,
  pkgs,
  lib,
  options,
  ...
}:
{
  imports = [ ./conf.nix ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgs;
    };

    users.${config.users.primary}.imports = [ ../home-manager/${config.users.primary}.nix ];
  };
  users.users.${config.users.primary} = {
    name = config.users.primary;
    home = "/Users/${config.users.primary}";
  };

  nix = {
    enable = true;

    # Use the latest Nix from nixpkgs.
    package = pkgs.nix;
    nixPath = options.nix.nixPath.default ++ [ "nixpkgs=${inputs.nixpkgs}" ];

    # Keep the system lightweight
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes";
    };

    extraOptions = lib.mkIf (system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  nixpkgs = {
    # The platform the configuration will be used on.
    hostPlatform = system;
  };

  # nix-darwin metadata
  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;

  };
}
