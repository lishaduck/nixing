{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # Nix stuff
      nil
      nixd
      nixfmt
      home-manager

      # Oils!
      oils-for-unix

      # Zed
      zed-editor

      # Browser
      google-chrome

      # Stuff that I probably don't use enough to justify their being here.
      fd
      bat-extras.batman
      fastfetch
    ];
    # This value determines the Home Manager release that your configuration is compatible with.
    # This helps avoid breakage when a new Home Manager release introduces backwards incompatible changes.
    #
    # You can update Home Manager without changing this value.
    # See the Home Manager release notes for a list of state version changes in each release.
    stateVersion = "25.11";
  };

  programs = {
    # Zsh is the default shell on Catalina onward.
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
    };
    bash.enable = true; # Lots of things shell out to Bash.

    command-not-found.enable = true;

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

    vscode = {
      enable = true;
      package = with pkgs; vscode;

      profiles.default = {
        userSettings = {
          "update.mode" = "none";
          "update.showReleaseNotes" = false;

          "editor.fontFamily" =
            "'Cascadia Code NF', 'Fira Mono for Powerline', Menlo, Monaco, Consolas, 'Courier New', monospace";
          "editor.fontLigatures" = "'liga', 'calt', 'ss01'";

          "workbench.iconTheme" = "material-icon-theme";

          "chat.disableAIFeatures" = true;

          "editor.formatOnSave" = true;

          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            "nixd" = {
              "options" = {
                "nixos" = {
                  "expr" =
                    "(builtins.getFlake (builtins.toString ./.)).darwinConfigurations.\"macOSs-Virtual-Machine\".options";
                };
                "home-manager" = {
                  "expr" =
                    "(builtins.getFlake (builtins.toString ./.)).darwinConfigurations.\"macOSs-Virtual-Machine\".options.home-manager.users.type.getSubOptions []";
                };
              };
            };
          };

          "git.blame.editorDecoration.enabled" = true;
          "terminal.integrated.stickyScroll.enabled" = false;
        };

        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = [
          pkgs.vscode-extensions.pkief.material-icon-theme
          pkgs.vscode-extensions.jnoortheen.nix-ide
        ];
      };
    };

    ghostty = {
      enable = true;
      package = null;

      settings = {
        font-family = "Cascadia Code";
        theme = "Dark Modern";

        window-padding-x = "8";
        window-padding-y = "6";
        window-padding-balance = "true";

        macos-titlebar-style = "tabs";
        window-save-state = "never";

        background-blur-radius = "20";
        background-opacity = "0.92";

        shell-integration-features = "true";

        notify-on-command-finish = "unfocused";
        notify-on-command-finish-action = "notify";
        notify-on-command-finish-after = "5s";
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
    atuin.enable = true;
    zoxide.enable = true;
    fzf.enable = true;
    starship.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    zen-browser.enable = true;

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
