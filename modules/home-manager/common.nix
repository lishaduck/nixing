{ pkgs, inputs, ... }:
{
  imports = [
    inputs.nix-index-database.homeModules.default
  ];

  home = {
    packages = with pkgs; [
      # Nix stuff
      nil
      nixd
      nixfmt
      home-manager

      # Oils!
      oils-for-unix

      # jj
      jujutsu

      # Editors
      flow-control
      helix

      # Stuff that I probably don't use enough to justify their being here.
      fd
      bat-extras.batman
      fastfetch

      # zsh
      zsh-fzf-tab
    ];
    # This value determines the Home Manager release that your configuration is compatible with.
    # This helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
    #
    # You can update Home Manager without changing this value.
    # See the Home Manager release notes for a list of state version changes in each release.
    stateVersion = "25.11";
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;

      autocd = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };

      plugins = [
        {
          name = "fzf-tab";
          src = "${with pkgs; zsh-fzf-tab}/share/fzf-tab";
        }
      ];
    };
    bash.enable = true; # Lots of things shell out to Bash.

    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      lfs.enable = true;

      settings = {
        user = {
          name = "Eli";
          email = "88557639+lishaduck@users.noreply.github.com";
        };
      };
    };

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
    atuin = {
      enable = true;
      enableZshIntegration = true;
      daemon.enable = true;

      settings = {
        inline_height = 0;
        style = "full";
        search_mode_shell_up_key_binding = "prefix";

        sync.records = true;
      };
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    starship.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nh.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
