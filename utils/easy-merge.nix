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
  easyMerge = label: { imports ? [], options ? [], ... } @ module: let
    sections = [ "imports" "options" "config" ];
    sectionsToMerge = lib.zipAttrsWithNames sections (_: value: {
      # imports = value.imports or [];
      # options = value.options or [];
      config = (value.config or []) ++ (builtins.removeAttrs value sections);
    }) module.${label};
  in {
    # imports = lib.mkMerge (imports ++ sectionsToMerge.imports);
    # options = lib.mkMerge (options ++ sectionsToMerge.options);
    config = lib.mkMerge ((module.config or []) ++ [
      (builtins.removeAttrs module (sections ++ [ label ]))
    ]);
  };

}

