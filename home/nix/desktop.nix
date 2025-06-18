{ pkgs, ... }: {
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
  services.hypridle = {
    enable = true;
  };
  # services.hyprpaper = {
  #   enable = true;
  # };
  programs.hyprlock = {
    enable = true;
  };
}
