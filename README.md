# Nix

Place this under `~/.config` (as in, `~/.config/nix-darwin/`).
To build the system, run `darwin-rebuild switch --flake ~/.config/nix-darwin && sudo ./result/sw/bin/nix-collect-garbage -d`.
