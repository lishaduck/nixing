{ pkgs, ... }:
{
  users.primary = "macos";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  environment.systemPackages = [
    pkgs.jq
    pkgs.yq
    pkgs.git
  ];
}
