### easyMerge ###
# Parameters:
# 1. (label)str: (custom label to enter easy-merge namespaces)
# 2. (module)attrs:
#    - attrs.easy-merge.<visual_label>: attrsOf anything (namespaced config)
#    - attrs.<any_option>: anything (top-level config)
#################
#
# Usage:
# ```
# nixpkgs.overlays = [ utilities.overlays.easy-merge ];
# ```
# ```
# { lib, ... }: lib.easyMerge {
#   programs.git.enable = true;
#   easy-merge.some.programs = someAutomations ...;
#   easy-merge.more.programs = moreDifferentAutomations ...;
#
#   easy-merge.let.x = let
#     y = some-local-bindings-that-you-want-to-put-nearby;
#     z = ... y;
#   in z;
# }
# ```

final: prev: let
  lib = prev;
in {
  easyMerge = label: module: let
    # nopWrap ensures lib.zipAttrs give correct outputs:
    nopWrap = {
      imports = [];
      options = {};
      config = {};
    };
    # wrap is for top level and wrap' is for namespaces, but I want to keep the
    # variable names short:
    wrap = extraRemove: parent: let
      parent' = nopWrap // parent; # Reduce "null-coalescings".
    in {
      imports = parent'.imports;
      options = parent'.options;
      config = lib.mergeAttrs parent'.config (builtins.removeAttrs parent' ([
        "imports" "options" "config"
      ] ++ extraRemove));
    };
    wrap' = wrap [];

    topLevel = wrap [ label ] module;
    namespaces = lib.getValues (lib.attrsToList module.${label}) ++ [ nopWrap ];
    # zipped should always be { imports = [...]; options = [...]; config = [...]; }:
    zipped = lib.zipAttrs (builtins.map wrap' namespaces);
  in {
    imports = builtins.concatLists (topLevel.imports ++ zipped.imports);
    # Options do not support lib.mkMerge:
    options = lib.mergeAttrsList ([ topLevel.options ] ++ zipped.options);
    config = lib.mkMerge ([ topLevel.config ] ++ zipped.config);
  };
}
