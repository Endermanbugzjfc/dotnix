# Nix-maid profiles that can be activated without rebuilding NixOS.

{ lib, inputs, self, ... }: let

  profilesDir = "/nix/var/nix/profiles/per-user/$USER";
  prefixes = [
    "script-apps-"
    "maid-"
  ];
  packageNames = [
    "profile-cmds"
  ];
  hostnames = [
    "rig"
  ];
  seeBelow = lib.mkOption {
    description = "The value is defined right below the option, type omitted";
    type = with lib.types; anything;
  };

in {
  flake.options.lib.mkMaidProfile = seeBelow;
  flake.config.lib.mkMaidProfile = inputs.nix-maid;
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
  flake.options.lib.maidProfilesRelativePaths = lib.mkOption {
    description = ''
      Each Nix-maid profile will place a folder path in this list, the path will be relative to the
      repository root, this action shall be done in their default.nix

      This option exists for `entr` to auto activate a profile on edit
    '';
    example = ''
      [ "modules/script-apps" ]
    '';
    type = with lib.types; listOf str;
  };
  flake.config.lib.maidProfilesRelativePaths = [];

  flake.options.lib.getHostname = seeBelow;
  flake.config.lib.getHostname = name: assert (builtins.elem name hostnames); name;
}
