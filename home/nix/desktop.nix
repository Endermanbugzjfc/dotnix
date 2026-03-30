{ config, pkgs, lib, inputs, ... }: let
  monitor = ",preferred,auto,1.2";
  # monitor = ",preferred,auto,2.0";

  # Experiment log 2025-11-08: Citrix Workspace scaling works with static
  # monitor config, but not dynamic. And the interface is so blurry so I should
  # just stay with the current setup.

  golden_reciprocal = "0.618";
  thin_column_width = "0.382";
  column_width = golden_reciprocal;
in {
  home.packages = with pkgs; [
    pyprland

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
    (writeShellScriptBin "nodim" ''
      hyprctl keyword decoration:dim_special 0
    '')
    (let
      plugins = config.wayland.windowManager.hyprland.plugins;
      lines = lib.forEach plugins (plugin: "hyprctl plugin unload ${plugin}/lib/lib${plugin.pname}.so");
    in writeShellScriptBin "hyprland-unload-plugins" (lib.concatStringsSep "\n" lines))

    hyprpicker
    waypaper
    (writeShellScriptBin "hyprdoc" ''
      xdg-open https://wiki.hypr.land/
    '')

    hyprland-qt-support
    inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default

    vlc

    # Reminder: VLC is an unsafe protocol:
    wlvncc

    # I never liked desktop notifications but Plover depends on notify-send:
    libnotify

    qalculate-gtk
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.package = let
  #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  # in package;

  wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
    # hypr-dynamic-cursors
    # hyprspace
    # hyprexpo
  ];
  wayland.windowManager.hyprland.settings = {
    inherit monitor;
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.
    exec-once = "waypaper --random &"; # Animation: set imperatively in Waypaper GUI.

    general.gaps_out = "5";
    decoration.rounding = 5;

    "plugin:dynamic-cursors" = {
      mode = "stretch";
      # shake.effects = "true";
      hyprcursor.resolution = "512";
    };

    # Official scorlling layout added on 0.54:
    general.layout = "scrolling";
    scrolling = {
      inherit column_width;
      fullscreen_on_one_column = false;
      focus_fit_method = let
        centre = "0"; # Option name: center.
        fit = "1";
      in centre;
      # Options in Hyprland latest-git:
      # wrap_focus=false
      # wrap_swapcol=false
    };

    # Fix apps that do not follow NIXOS_OZONE_WL:
    # https://www.reddit.com/r/hyprland/comments/194rk1o/comment/khi0k17/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    xwayland.force_zero_scaling = "true";
    # xwayland.force_zero_scaling = "false";

    gesture = [
      # "3, swipe, resize"
      # "4, down, overview:toggle"
      "3, left, dispatcher, movefocus, r"
      "3, right, dispatcher, movefocus, l"
      # https://www.reddit.com/r/hyprland/comments/1rkhwar/change_focus_windows_with_gesture/
    ];

    # hyprexpo-gesture = [
    #   "4, up, hyprexpo:expo"
    # ];
    # plugin.hyprexpo.gesture_distance = 6000;

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
      "sensitivity" =  "1.67"; # Dear Gen Alpha: this is not intentional.
    }];

    misc.middle_click_paste = "false";

    # TODO: workflow
    windowrule = [
      "fullscreen on, match:class sublime_merge match:title .+"
      "fullscreen on, match:class discord match:title .+"
      "no_initial_focus on, match:class steam title:.+"
      "stay_focused on, match:class org.gnupg.pinentry-qt"

      "float on, match:class qalculate-gtk"
      "move cursor -50% -50%, match:class qalculate-gtk"
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
      binds = [
        "\$mainMod ALT, h, movefocus, l"
        "\$mainMod ALT, l, movefocus, r"
        "\$mainMod ALT, k, movefocus, u"
        "\$mainMod ALT, j, movefocus, d"

        "\$mainMod SHIFT, h, layoutmsg, swapcol l"
        "\$mainMod SHIFT, l, layoutmsg, swapcol r"
        "\$mainMod SHIFT, k, movewindow, u"
        "\$mainMod SHIFT, j, movewindow, d"

        # Make this three-finger tap when Hyprland supports it in the future:
        "\$mainMod, Delete, layoutmsg, colresize 1"
        "\$mainMod, Backspace, layoutmsg, colresize ${column_width}"
        "\$mainMod, Insert, layoutmsg, colresize ${thin_column_width}"

        "\$mainMod, f, fullscreen"
        "\$mainMod, g, fullscreenstate, -1, 3"

        "\$mainMod ALT, up, exec, hyprland-toggle-upside-down"
        "\$mainMod, l, exec, hyprlock"

        "\$mainMod SHIFT, c, exec, hyprpicker | grep -oE \"##(.+)\" | tr -d \"[:space:]\" | wl-copy"
        # "\$mainMod SHIFT, t, exec, "
        ", Print, exec, grim - | wl-copy"
        "SHIFT, Print, ${selectAndShoot}"

        #"\$mainMod, w, overview:toggle"

        "\$mainMod, t, exec, ${focusQalculate}"

        # Note: macos Exposé: control+down / Command+F3 according to ||Gemini||.
        "\$mainMod, k, exec, pypr expose"

        "\$mainMod, h, exec, pypr layout_center toggle # toggle the layout"
## focus change keys
        "\$mainMod, left, exec, pypr layout_center prev"
        "\$mainMod, right, exec, pypr layout_center next"
        "\$mainMod, up, exec, pypr layout_center prev2"
        "\$mainMod, down, exec, pypr layout_center next2"
      ];

      focusQalculate = pkgs.writeShellScript "focus-qalculate" ''
        #!/bin/bash
        [ "$(pidof qalculate-gtk)" == "" ] && qalculate-gtk && exit 0
        hyprctl dispatch movetoworkspace +0, "class:^(qalculate-gtk)$"
        SIZES=$(hyprctl clients -j | jq -r '.[] | select(.class == "qalculate-gtk") | .size | "\(.[0]) \(.[1])"')
        CURSOR=$(hyprctl cursorpos | sed 's/,//')
        EXACT=$(printf "$CURSOR $SIZES" | awk '{print int($1-$3/2),int($2-$4/2)}')
        hyprctl dispatch movewindowpixel "exact $EXACT,class:^(qalculate-gtk)$"
      '';
    in binds;

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

  # I never liked desktop notifications but Plover depends on notify-send:
  services.dunst.enable = true;

  # TODO: notify on OCR script

  # Pyprland:
  systemd.user.services.pyprland = {
    Unit = {
      Description = "Starts pyprland daemon";
      After = [ "graphical-session.target" ];
      Wants = [ "graphical-session.target" ];
      StartLimitIntervalSec = 600;
      StartLimitBurst = 5;
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.pyprland}/bin/pypr";
      Restart = "always";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  wayland.windowManager.hyprland.settings.workspace = [
    # Add some style to the "exposed" workspace
    "special:exposed,gapsout:60,gapsin:30,bordersize:5,border:true,shadow:false"
  ];

  home.file.".config/pypr/config.toml".text = ''
    [pyprland]
    plugins = [
        "expose",
        "layout_center"
    ]

    [layout_center]
    margin = 60
    offset = [0, 30]
    next = "movefocus r"
    prev = "movefocus l"
    next2 = "movefocus d"
    prev2 = "movefocus u"
  '';
}
