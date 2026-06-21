{ pkgs, config, ... }:
{
  users = {
    primary = "nixos";

    users = {
      nixos = {
        shell = with pkgs; zsh;
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      nh
      flow-control
      git
    ];
    variables = {
      PATH = [
        "${config.wsl.wslConf.automount.root}/c/Program Files/Microsoft VS Code/bin/code"
      ];
    };
  };

  programs = {
    zsh.enable = true;

    nix-ld.enable = true;
    nix-ld.libraries = [ ];
  };

  wsl = {
    enable = true;
    defaultUser = "nixos";

    wslConf = {
      interop.appendWindowsPath = false;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
