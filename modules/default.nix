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
  flake.lib.maidProfilesRelativePath = lib.mkOption {
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

  flake.options.lib.hostnames = lib.mkOption {
    description = ''
      Each host in the hosts folder will place a hostname in this list, this action shall be done in their default.nix

      This option exists for some script-apps to perform different logic based on the machine
    '';
    type = with lib.types; attrsOf str;
  };
  flake.lib.hostnames = {};
}
