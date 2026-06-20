{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [ ../../options/options.nix ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgs inputs;
    };

    users.${config.users.primary}.imports = [
      ../home-manager/${config.users.primary}.nix
    ];
  };

  nix = {
    enable = true;

    # Use the latest Nix from nixpkgs.
    package = pkgs.nixVersions.stable;

    # Keep the system lightweight
    gc.automatic = true;
    optimise.automatic = true;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
