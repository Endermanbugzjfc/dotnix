{ pkgs, lib, inputs, ... }: let
  monitor = ",preferred,auto,1.2";
  # monitor = ",preferred,auto,2.0";

  # Experiment log 2025-11-08: Citrix Workspace scaling works with static
  # monitor config, but not dynamic. And the interface is so blurry so I should
  # just stay with the current setup.
in {
  home.packages = with pkgs; [
    grim  # Screenshot.
    slurp # Screen region selection.
    satty # Annotation tool

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

    hyprpicker
    waypaper

    hyprland-qt-support
    inputs.hyprqt6engine.packages.${pkgs.system}.default

    vlc
    wlvncc
  ];

  wayland.windowManager.hyprland.enable = true;
  wayland.windowManager.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  wayland.windowManager.hyprland.plugins = [
    inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
  ];
  wayland.windowManager.hyprland.settings = {
    inherit monitor;
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.
    exec-once = "waypaper --random &";
    general.gaps_out = "0";

    # Fix apps that do not follow NIXOS_OZONE_WL:
    # https://www.reddit.com/r/hyprland/comments/194rk1o/comment/khi0k17/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    xwayland.force_zero_scaling = "true";
    # xwayland.force_zero_scaling = "false";

    gesture = [
      "3, swipe, resize"
    ];

    input.accel_profile = "flat";
    input.touchpad = {
      natural_scroll = "true";
      disable_while_typing = "true";
      scroll_factor = "0.1";
      clickfinger_behavior = "1"; # Two fingers to right click.
      drag_3fg = "0"; # Use for resizing windows now (2025-11-09).
    };
    device = lib.mkForce [{
      "name" = lib.mkDefault "elan0524:01-04f3:3215-touchpad";
      "sensitivity" =  "1.67";
    }];

    misc.middle_click_paste = "false";

    # TODO: workflow
    windowrule = [
      "maximize, class: sublime_merge"
    ];

    # TODO: run nix flake update on idle or lock

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

    bind = let
      selectAndShoot = "exec, grim -g \"$(slurp)\" - | wl-copy";
    in [
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

      "\$mainMod SHIFT, c, exec, hyprpicker | grep -oE \"##(.+)\" | tr -d \"[:space:]\" | wl-copy"
      # "\$mainMod SHIFT, t, exec, "
      ", Print, exec, grim - | wl-copy"
      "SHIFT, Print, ${selectAndShoot}"
    ];

    bindm = [
      "\$mainMod ALT, mouse:272, resizewindow"
    ];

    bindel = [
      # Laptop multimedia keys for volume and LCD brightness
      # ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 2 @DEFAULT_AUDIO_SINK@ 5%+"
      ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"

      ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
      ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
      ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
    ];

    # TODO: convert all hardcoded commands to nixpkgs dependency.
    # TODO: lower voice = stay mute, higher = auto unmute, step 10. Hold = step 2.
    # TODO: move to home manager keymap.nix

    env = [
      "QT_QPA_PLATFORMTHEME,hyprqt6engine"
    ];
  };

  programs.eww = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.wofi = {
    enable = true;
  };

  # programs.waybar.enable = false;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
      };
      listener = [{
        timeout = 60 * 5;
        on-timeout = "loginctl lock-session";
      }];
    };
  };
  services.swww = {
    enable = true;
  };
  programs.hyprlock = {
    enable = true;
  };

  stylix = {
    enable = false;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/ic-orange-ppl.yaml";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/blueforest.yaml";
  };
}
