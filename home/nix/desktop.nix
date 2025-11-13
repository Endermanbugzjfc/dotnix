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
    inputs.hyprqt6engine.packages.${pkgs.stdenv.hostPlatform.system}.default

    vlc
    wlvncc
  ];

  wayland.windowManager.hyprland.enable = true;
  # wayland.windowManager.hyprland.package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  nixpkgs.overlays = [
# https://github.com/KZDKM/Hyprspace/pull/200#issuecomment-3503786991
  (
self: super:
{
  hyprlandPlugins = super.hyprlandPlugins // {
    hyprspace = super.hyprlandPlugins.hyprspace.overrideAttrs (oldAttrs: {
      # Fix compatibility with Hyprland 0.51.x
      # Based on PR #200: https://github.com/KZDKM/Hyprspace/pull/200
      # Updates dispatcher API from V1 to V2 and fixes type casting issues
      postPatch = (oldAttrs.postPatch or "") + ''
        # Update dispatcher API to V2
        substituteInPlace src/main.cpp \
          --replace-fail 'HyprlandAPI::addDispatcher(pHandle, "overview:toggle"' \
                         'HyprlandAPI::addDispatcherV2(pHandle, "overview:toggle"' \
          --replace-fail 'HyprlandAPI::addDispatcher(pHandle, "overview:open"' \
                         'HyprlandAPI::addDispatcherV2(pHandle, "overview:open"' \
          --replace-fail 'HyprlandAPI::addDispatcher(pHandle, "overview:close"' \
                         'HyprlandAPI::addDispatcherV2(pHandle, "overview:close"'

        # Fix type casting issue in Render.cpp for panelBorderWidth
        substituteInPlace src/Render.cpp \
          --replace-fail 'owner->m_transformedSize.x, Config::panelBorderWidth};' \
                         'owner->m_transformedSize.x, static_cast<double>(Config::panelBorderWidth)};'

        # Fix Input.cpp to handle createNewWorkspace return value (nodiscard in 0.51)
        # This captures the return value to avoid compiler warnings/errors
        # Replace both occurrences on lines 92 and 97
        sed -i 's/if (g_pCompositor->getWorkspaceByID(wsIDName.id) == nullptr) g_pCompositor->createNewWorkspace(wsIDName.id, ownerID);/if (g_pCompositor->getWorkspaceByID(wsIDName.id) == nullptr) { auto ws = g_pCompositor->createNewWorkspace(wsIDName.id, ownerID); (void)ws; }/g' src/Input.cpp

        # Fix gesture handling for Hyprland 0.51 - the old gesture config options were removed
        # Use default values (4 fingers, 300 distance) when the old config doesn't exist
        substituteInPlace src/Input.cpp \
          --replace-fail 'int fingers = std::any_cast<Hyprlang::INT>(HyprlandAPI::getConfigValue(pHandle, "gestures:workspace_swipe_fingers")->getValue());' \
                         'auto fingersConfig = HyprlandAPI::getConfigValue(pHandle, "gestures:workspace_swipe_fingers"); int fingers = fingersConfig ? std::any_cast<Hyprlang::INT>(fingersConfig->getValue()) : 4;' \
          --replace-fail 'int distance = std::any_cast<Hyprlang::INT>(HyprlandAPI::getConfigValue(pHandle, "gestures:workspace_swipe_distance")->getValue());' \
                         'auto distanceConfig = HyprlandAPI::getConfigValue(pHandle, "gestures:workspace_swipe_distance"); int distance = distanceConfig ? std::any_cast<Hyprlang::INT>(distanceConfig->getValue()) : 300;'
      '';
    });
  };
}
  )
  ];
  wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
    hypr-dynamic-cursors
    hyprspace
    # hyprexpo
  ];
  wayland.windowManager.hyprland.settings = {
    inherit monitor;
    misc.disable_hyprland_logo = "true"; # Brought my own anime girl.
    exec-once = "waypaper --random &";
    general.gaps_out = "0";

    "plugin:dynamic-cursors" = {
      mode = "stretch";
      # shake.effects = "true";
      hyprcursor.resolution = "512";
    };

    # Fix apps that do not follow NIXOS_OZONE_WL:
    # https://www.reddit.com/r/hyprland/comments/194rk1o/comment/khi0k17/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
    xwayland.force_zero_scaling = "true";
    # xwayland.force_zero_scaling = "false";

    gesture = [
      "3, swipe, resize"
      # "4, down, overview:toggle"
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
      "maximize, class: sublime_merge title:.+"
      "maximize, class: discord title:.+"
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

      "\$mainMod, w, overview:toggle"
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
