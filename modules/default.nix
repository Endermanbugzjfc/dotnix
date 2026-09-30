# Nix-maid profiles that can be activated without rebuilding NixOS.

{ flake-parts-lib, lib, inputs, self, ... }: let
# {{{ Constants:

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

# }}}
in {
# {{{ Nix-maid setup:
  options.options.lib.mkMaidProfile = seeBelow;
  config.flake.lib.mkMaidProfile = inputs.nix-maid;
  config.perSystem = { lib, pkgs, self', ... }: let
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
  };
  options.flake.lib.maidProfilesRelativePaths = lib.mkOption {
    description = ''
      Each Nix-maid profile will place a folder path in this list, the path will be relative to the
      repository root

      This option exists for `entr` to auto activate a profile on edit
    '';
    example = ''
      [ "modules/script-apps" ]
    '';
    type = with lib.types; listOf str;
  };
  config.flake.lib.maidProfilesRelativePaths = [
    "modules/script-apps"
  ];
# }}}
# {{{ Misc definitions:

  # Sanity check on pools that automatically add packages by their prefix:
  options.perSystem = flake-parts-lib.mkPerSystemOption {
    options.packages = lib.mkOption {
      apply = packages: let
        isLeftout = name: builtins.all (prefix: !lib.hasPrefix prefix name) prefixes
          && !builtins.elem name packageNames;
        leftoutPackagesName = lib.concatStringsSep ", " (
          lib.filter isLeftout (builtins.attrNames packages)
        );
      in lib.throwIf (leftoutPackagesName != "")
        "[dotnix] unmatched packages: ${leftoutPackagesName}"
        packages;
    };
  };

  options.flake.lib.getHostname = seeBelow;
  config.flake.lib.getHostname = name: assert (builtins.elem name hostnames); name;
}
