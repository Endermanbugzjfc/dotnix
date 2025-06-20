{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    kando # Pie menu.

    grim  # Screenshot.
    slurp # Screen region selection.
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.settings = lib.mkForce {
  wayland.windowManager.hyprland.settings = {
    # exec-once = [
    #   "waybar"
    # ];

    monitor = ",preferred,auto,1.2"; # TODO
    input.touchpad.natural_scroll = "true";
    gestures.workspace_swipe = "true"; # (Three fingers).
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.

    bind = [
      # Copied from Arch.
      "\$mainMod ALT, h, movefocus, l"
      "\$mainMod ALT, l, movefocus, r"
      "\$mainMod ALT, k, movefocus, u"
      "\$mainMod ALT, j, movefocus, d"

      "\$mainMod SHIFT, h, movewindow, l"
      "\$mainMod SHIFT, l, movewindow, r"
      "\$mainMod SHIFT, k, movewindow, u"
      "\$mainMod SHIFT, j, movewindow, d"
    ];

    # TODO: lower voice = stay mute, higher = auto unmute, step 10. Hold = step 2.
  };

  programs.eww = {
    enable = true;
  };
  programs.wofi = {
    enable = true;
  };
  programs.waybar = { # TODO: future: mouse spotlight effect
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
