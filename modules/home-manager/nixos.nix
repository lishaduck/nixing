{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
    ./common.nix
  ];

  programs = {
    niri = {
      enable = true;
      package = with pkgs; niri;

      settings = {

        spawn-at-startup = [
          { command = [ "noctalia" ]; }
        ];

        window-rules = [

          {
            matches = [ ];

            # Rounded corners for a modern look.
            geometry-corner-radius = {
              top-left = 20.0;
              top-right = 20.0;
              bottom-right = 20.0;
              bottom-left = 20.0;
            };

            # Clips window contents to the rounded corner boundaries.
            clip-to-geometry = true;
          }

          # Floating Noctalia settings window.
          {
            matches = [
              {
                app-id = "dev.noctalia.Noctalia.Settings";
              }
            ];

            open-floating = true;
            default-column-width = {
              fixed = 1080;
            };
            default-window-height = {
              fixed = 920;
            };
          }
        ];

        debug = {
          # Allows notification actions and window activation from Noctalia.
          honor-xdg-activation-with-invalid-serial = true;
        };

        cursor = {
          theme = "xcursor-transparent-cursor";
        };

        binds = {
          # Core Noctalia binds
          "Mod+Space".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "launcher"
          ];

          "Mod+S".action.spawn = [
            "noctalia"
            "msg"
            "panel-toggle"
            "control-center"
          ];

          "Mod+Comma".action.spawn = [
            "noctalia"
            "msg"
            "settings-toggle"
          ];

          # Audio & Brightness
          "XF86AudioRaiseVolume".action.spawn = [
            "noctalia"
            "msg"
            "volume-up"
          ];
          "XF86AudioLowerVolume".action.spawn = [
            "noctalia"
            "msg"
            "volume-down"
          ];
          "XF86AudioMute".action.spawn = [
            "noctalia"
            "msg"
            "volume-mute"
          ];
          "XF86MonBrightnessUp".action.spawn = [
            "noctalia"
            "msg"
            "brightness-up"
          ];
          "XF86MonBrightnessDown".action.spawn = [
            "noctalia"
            "msg"
            "brightness-down"
          ];
        };
      };
    };

    noctalia = {
      enable = true;
      settings = {
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };

        wallpaper = {
          enabled = true;
          directory = "~/Pictures/Wallpapers";
          fillMode = "crop";
        };
      };
    };

    zsh.shellAliases = {
      niri = "WLR_RENDERER=pixman GALLIUM_DRIVER=llvmpipe ${lib.getExe pkgs.niri}";
    };
  };
}
