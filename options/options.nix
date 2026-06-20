{ lib, ... }:
{
  options.users.primary = lib.mkOption {
    type = lib.types.str;
    description = "The username of the primary user on the system (an admin user not created by Nix)";
  };
}
