# Focus-qalculate is a Hyprland script that spawns Qalculate at cursor or move the window to cursor
# before transferring focus onto it.
# This requires setting the floating window rule for Qalculate.

{
  perSystem = { pkgs, ... }: {
    packages.script-apps-check-rebar = pkgs.writeShellScriptBin "focus-qalculate" (
      builtins.readFile ./focus-qalculate.sh
    );
  }
}
