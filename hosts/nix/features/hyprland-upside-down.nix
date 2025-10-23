# https://www.reddit.com/r/hyprland/comments/114rlm4/hyprctl_command_for_screen_rotation/

{ config, pkgs, lib, ... }: let
  inherit (lib) mkEnableOption mkDefault mkIf;
in {
  options.features.hyprland-upside-down.enable = mkEnableOption "upside-down command of Hyprland";
  config.features.hyprland-upside-down.enable = mkDefault true;
  # TODO: make executable hyprland only with env(?
  environment.systemPackages = mkIf config.features.hyprland-upside-down.enable (
    with pkgs; writeShellScriptBin "hyprland-toggle-upside-down" ''
      #!/usr/bin/env bash
      [[ $DESKTOP_SESSION != "hyprland" ]] && exit 1
      PREP='hyprctl keyword monitor ${monitor}'
      if hyprctl monitors | grep -q 'transform: 0'; then
        PREP+=',transform,2'
      fi
      exec $PREP
    ''
  );
}

