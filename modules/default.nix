# Nix-maid profiles that can be activated without rebuilding NixOS.

{ inputs, self, ... }: let
  profilesDir = "/nix/var/nix/profiles/per-user/$USER";
  prefixes = [
    "script-apps-"
    "maid-"
  ];
  packageNames = [
    "profile-cmds"
  ];
in {
  flake.lib.mkMaidProfile = inputs.nix-maid;

  perSystem = { lib, pkgs, self', ... }: let
    getPackagesByPrefix = prefix: assert builtins.elem prefix prefixes;
      builtins.attrValues (lib.filterAttrs (name: _: lib.hasPrefix prefix name) self'.packages);
  in {
    # Pools all script applications in one place:
    packages.maid-script-apps = self.lib.mkMaidProfile pkgs {
      packages = getPackagesByPrefix "script-apps-";
    };

    packages.profile-cmds = pkgs.buildEnv {
      name = "profile-cmds";
      paths = getPackagesByPrefix "maid-";
    };

    # Sanity check on pools that automatically add packages by their prefix:
    checks.package-names = pkgs.runCommand "package-names" {
      leftoutPackagesName = lib.concatStringsSep ", " (
        lib.filter (
          name: !builtins.any (
            prefix: lib.hasPrefix prefix name || builtins.elem name packageNames
          ) prefixes
        ) (builtins.attrNames self'.packages)
      );
    } ''
      echo "[dotnix] Checking package-names"
      [ "$leftoutPackagesName" != "" ] && echo "Unmatched packages: $leftoutPackagesName" && exit 1

      touch $out
    '';
  };
}
