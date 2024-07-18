{
  inputs,
  config,
  arch,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ./conf.nix ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit pkgs;
    };

    users.${config.users.primary}.imports = [ ../home-manager/${config.users.primary}.nix ];
  };
  users.users.${config.users.primary} = {
    name = config.users.primary;
    home = "/Users/${config.users.primary}";
  };

  services = {
    # Auto upgrade nix package and the daemon service.
    nix-daemon.enable = true;
  };

  nix = {
    # Use latest Nix from nixpkgs.
    package = pkgs.nix;

    # Keep the system lightweight
    gc.automatic = true;
    optimise.automatic = true;
    settings.auto-optimise-store = true;
    settings = {
      # Necessary for using flakes on this system.
      experimental-features = "nix-command flakes repl-flake";
    };

    extraOptions = lib.mkIf (arch == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  nixpkgs = {
    # The platform the configuration will be used on.
    hostPlatform = arch;
  };

  # nix-darwin metadata
  system = {
    # Set Git commit hash for darwin-version.
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;

    # Nix-darwin does not link installed applications to the user environment. This means apps will not show up
    # in spotlight, and when launched through the dock they come with a terminal window. This is a workaround.
    # Upstream issue: https://github.com/LnL7/nix-darwin/issues/214
    # Issue: https://github.com/LnL7/nix-darwin/issues/139
    activationScripts.applications.text =
      let
        uname = config.users.primary;
      in
      ''
        echo "setting up ~/Applications..." >&2
        applications="${config.users.users.${uname}.home}/Applications"
        nix_apps="$applications/Nix Apps"

        # Delete the directory to remove old links
        rm -rf "$nix_apps"

        # Needs to be writable so that nix-darwin can symlink into it
        mkdir -p "$nix_apps"
        chown ${uname}: "$nix_apps"
        chmod u+w "$nix_apps"

        find ${config.system.build.applications}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read src; do
                # Spotlight does not recognize symlinks, it will ignore directory we link to the applications folder.
                # It does understand MacOS aliases though, a unique filesystem feature. Sadly they cannot be created
                # from bash (as far as I know), so we use the oh-so-great Apple Script instead.
                /usr/bin/osascript -e "
                    set fileToAlias to POSIX file \"$src\"
                    set applicationsFolder to POSIX file \"$nix_apps\"
                    tell application \"Finder\"
                        make alias file to fileToAlias at applicationsFolder
                        # This renames the alias; 'mpv.app alias' -> 'mpv.app'
                        set name of result to \"$(rev <<< "$src" | cut -d'/' -f1 | rev)\"
                    end tell
                " 1>/dev/null
            done
      '';
  };
}
