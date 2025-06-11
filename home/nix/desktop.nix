{ pkgs, ... }: {
  wayland.windowManager.hyprland.enable = true;

  home.packages = with pkgs; [
    kando # Pie menu.

    grim  # Screenshot.
    slurp # Screen region selection.
  ];
  programs.eww = {
    enable = true;
  };
  programs.wofi = {
    enable = true;
  };
  programs.waybar = {
    enable = true;
  };
}
