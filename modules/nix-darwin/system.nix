{ pkgs, ... }:
{
  users.primary = "macos";

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    jq
    yq
    git
  ];

  fonts = {
    packages = with pkgs; [ cascadia-code ];
  };

  homebrew = {
    enable = true;
    casks = [
      "ghostty@tip"
    ];
  };
}
