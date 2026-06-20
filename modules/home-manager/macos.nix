{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  home = {
    packages = with pkgs; [
      # Zed
      zed-editor

      # Browser
      google-chrome

      # CTF
      wireshark
    ];
  };

  programs = {
    # Zsh is the default shell on Catalina onward.
    zsh = {
      cdpath = [ "~/Developer" ];
    };

    vscode = {
      enable = true;
      package = with pkgs; vscode;

      mutableExtensionsDir = false;

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
                "nix-darwin" = {
                  "expr" =
                    "(builtins.getFlake (builtins.toString ./.)).darwinConfigurations.\"macOSs-Virtual-Machine\".options";
                };
                "home-manager" = {
                  "expr" =
                    "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.\"nixos\".options.home-manager.users.type.getSubOptions []";
                };
                "nixos" = {
                  "expr" = "(builtins.getFlake (builtins.toString ./.)).nixosConfigurations.\"nixos\".options";
                };
              };
            };
          };

          "git.blame.editorDecoration.enabled" = true;
          "diffEditor.ignoreTrimWhitespace" = true;
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
      enableZshIntegration = true;
      enableBashIntegration = true;

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

    zen-browser.enable = true;
  };
}
