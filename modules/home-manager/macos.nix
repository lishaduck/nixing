{ pkgs, ... }:
{
  home = {
    packages = [
      # Nix stuff
      pkgs.nil
      pkgs.nixd
      pkgs.nixfmt-rfc-style
      pkgs.home-manager
      pkgs.flake-checker

      # Oils!
      pkgs.oils-for-unix

      # Zed
      pkgs.zed-editor

      # Browser
      pkgs.google-chrome

      # Stuff that I probably don't use enough to justify their being here.
      pkgs.fd
      pkgs.bat-extras.batman
      pkgs.fastfetch
    ];
    # This value determines the Home Manager release that your configuration is compatible with.
    # This helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
    #
    # You can update Home Manager without changing this value.
    # See the Home Manager release notes for a list of state version changes in each release.
    stateVersion = "24.11";
  };

  programs = {
    # ZSH is the default shell on Catalina onward.
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
    };
    bash.enable = true; # Lots of things shell out to Bash.
    # fish.enable = true;
    command-not-found.enable = true;

    git = {
      enable = true;
      lfs.enable = true;
    };

    vscode.enable = true;

    eza = {
      enable = true;
      extraOptions = [
        "--classify"
        "--hyperlink"
        "--header"
        "--group-directories-first"
        "-I"
        ".git"
        "--icons"
        "--git"
        "--git-ignore"
        "--no-permissions"
      ];
    };
    bat.enable = true;
    ripgrep.enable = true;
    atuin.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    starship.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
