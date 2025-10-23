### enableMultiWith ###
# Parameters:
# 1. (config)attrs: anything
# 2. (names)names: lines (attrs to enable, separated by whitespace)
#######################
#
### enableMulti ###
# 1. (names)names: lines (attrs to enable, separated by whitespace)
###################
#
# Usage:
# ```
# nixpkgs.overlays = [ utilities.overlays.enable-multi ];
# ```
# ```
# security = enableMulti "rtkit";
# programs = enableMulti ''
#   vim neovim
#
#   git
#   lazygit
# '';
# services = enableMultiWith { user = "rickastley"; } ''
#   znc zitadel
# '';
# ```

final: prev: let
  inherit (import ./warn-dupe.nix final prev) warnDupe;
  lib = final;
in {
  enableMultiWith = config: names: let
    config' = lib.warnIf (
      config ? enable
    ) "enable-multi-with will override the attr `enable`: ${builtins.toJSON config.enable}" (
      config // { enable = true; }
    );
    filtered = builtins.filter (name: name != "" && name != []) (builtins.split "[[:space:]]" names);
    enabled = with lib; genAttrs (warnDupe filtered "enable-multi has duplicated names") (_: config');
  in enabled;
  enableMulti = lib.enableMultiWith {};
}

