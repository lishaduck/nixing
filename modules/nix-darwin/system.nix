{ pkgs, ... }:
{
  users.primary = "macos";

  homebrew = {
    enable = true;
    casks = [
      "google-chrome"
      "zed"
    ];
    caskArgs.no_quarantine = true;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  environment.systemPackages = [
    pkgs.jq
    pkgs.yq
  ];
}
