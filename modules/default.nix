# Nix-maid profiles that can be activated without rebuilding NixOS.

let
  profilesDir = "/nix/var/nix/profiles/per-user/$USER";
in {
  perSystem = { lib, pkgs, self', ... }: {
    # Pools all script applications in one place:
    packages.maid-script-apps = inputs.nix-maid pkgs {
      packages = lib.filterAttrs (name: val: lib.hasPrefix "script-apps-") self'.packages;
    };

    packages.profile-cmds = pkgs.buildEnv {
      name = "profile-cmds";
      paths = lib.filterAttrs (name: val: name.hasPrefix "maid-") self'.packages;
    };
  };
}
