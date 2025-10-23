final: prev: let
  lib = final;
in {
  /**
    This function displays a warning with a sorted list of duplicated names
    when there are any.

    # Example

    ```nix
    warnDupe "this example has duplicated names" [ "a" "a" ]
    =>
    evaluation warning: this example has duplicated names: a
    [
      "a"
      "a"
    ]
    ```

    # Type

    ```
    warnDupe :: [ String ] -> String -> [ String ]
    ```

    # Arguments

    names
    : List of names that might contain duplicated elements

    warn:
    : Prefix of the final warning message, recommended to have the form
      "<scope> has duplicated <object>"
  */
  warnDupe = names: warn: let
    # https://discourse.nixos.org/t/list-compare-diff-or-substraction/62367/4
    dupes = with lib; attrNames (filterAttrs (_: v: v > 1) (groupBy' (x: _: x+1) 0 builtins.toString names));
    warn' = "${warn}: ${lib.concatStringsSep ", " dupes}";
  in lib.warnIf (dupes != []) warn' names;
}
