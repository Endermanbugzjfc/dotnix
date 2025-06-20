# Common home contains program configurations that are officially default or
# adaptive to different systems.
#
# Apply the configs by simply importing them with the nixosConfigurations or
# homeConfigurations module system, i.e. "imports list" and not `import`
# keyword!
#
# Override config values by assigning values to the same path.
# Example (for ./hyprland-default.nix):
# ```
# # Appending to list:
# wayland.windowManager.hyprland.settings.env = [ "HI,1" ];
# # Overriding list:
# wayland.windowManager.hyprland.settings.env = lib.mkForce [ "HI,1" ];
# ```

{
  imports = [
    ./hyprland-default.nix
    ./waybar-default.nix
  ];
}
