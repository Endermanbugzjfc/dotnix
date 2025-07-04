{ pkgs, lib, ... }: let
  monitor = ",preferred,auto,1.2";
in {
  home.packages = with pkgs; [
    kando # Pie menu.

    grim  # Screenshot.
    slurp # Screen region selection.

    (writeShellScriptBin "hyprland-toggle-upside-down" ''
      #!/usr/bin/env bash
      # Turn screen upside down:
      # https://www.reddit.com/r/hyprland/comments/114rlm4/hyprctl_command_for_screen_rotation/
      [[ $DESKTOP_SESSION != "hyprland" ]] && exit 1
      PREP='hyprctl keyword monitor ${monitor}'
      if hyprctl monitors | grep -q 'transform: 0'; then
        PREP+=',transform,2'
      fi
      exec $PREP
    '')
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.settings = lib.mkForce {
  wayland.windowManager.hyprland.settings = {
    # exec-once = [
    #   "waybar"
    # ];

    inherit monitor;
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.

    # Fix apps that do not follow NIXOS_OZONE_WL:
    # https://www.reddit.com/r/hyprland/comments/194rk1o/comment/khi0k17/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    xwayland.force_zero_scaling = "true";

    gestures.workspace_swipe = "true"; # (Three fingers).
    input.accel_profile = "flat";
    input.touchpad = {
      natural_scroll = "true";
      disable_while_typing = "true";
      scroll_factor = "0.6"; # TODO
      clickfinger_behavior = "1"; # Two fingers to right click.
    };
    device = lib.mkForce [{
      "name" = lib.mkDefault "elan0524:01-04f3:3215-touchpad";
      "sensitivity" =  "1.1";
    }];

    # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
    # r -> release, will trigger on release of a key.
    # c -> click, will trigger on release of a key or button as long as the mouse cursor stays inside binds:drag_threshold.
    # g -> drag, will trigger on release of a key or button as long as the mouse cursor moves outside binds:drag_threshold.
    # o -> longPress, will trigger on long press of a key.
    # e -> repeat, will repeat when held.
    # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
    # m -> mouse, see below.
    # t -> transparent, cannot be shadowed by other binds.
    # i -> ignore mods, will ignore modifiers.
    # s -> separate, will arbitrarily combine keys between each mod/key, see [Keysym combos](#keysym-combos) above.
    # d -> has description, will allow you to write a description for your bind.
    # p -> bypasses the app's requests to inhibit keybinds.


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

      "\$mainMod ALT, up, exec, hyprland-toggle-upside-down"
      "\$mainMod, l, exec, hyprlock"
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
