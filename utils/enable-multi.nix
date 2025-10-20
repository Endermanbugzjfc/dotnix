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

final: prev: {
  enableMultiWith = config: names: let
    filtered = builtins.filter (name: name != "" && name != []) (builtins.split "[[:space:]]" names);
    enabled = builtins.listToAttrs (builtins.map (name: {
      # name should always be string.
      inherit name;
      value = config // { enable = true; };
    }) filtered);
  in enabled;
  enableMulti = final.enableMultiWith {};
}
