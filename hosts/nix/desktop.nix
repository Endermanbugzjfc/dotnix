# Desktop experience.

{ pkgs, inputs, ... }: {

  imports = [
    ../common/features/enable-hyprland.nix
  ];

  environment.systemPackages = with pkgs; [
    activate-linux
    nwg-look
  ];
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.noto
    source-han-sans
    inputs.mindustrice.packages.x86_64-linux.mindustry-fonts # TODO: test
  ];
  systemd.sleep.extraConfig = ''
      AllowHybridSleep=no
      AllowSuspendThenHibernate=yes
      HibernateDelaySec=${builtins.toString (60*60*1)}
    ''; # TODO: variable hibnerate delay based on power supply mode.
  services.logind.settings.Login = {
    RuntimeDirectorySize = "14G"; # TODO: move to fs module

    HandleLidSwitch = "sleep";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  }; # TODO: make service to turn off screen or do  fa  NCy ASITUFF

  # Enable the KDE Plasma Desktop Environment.
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    settings = {
      General = {
        DefaultSession = "hyprland.desktop";
        DisplayServer = "wayland";
        GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
        HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
        Numlock = "none";
        RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
      };
      Theme = {
        Current = "breeze";
        CursorSize = "24";
        CursorTheme = "breeze_cursors";
        FacesDir = "/run/current-system/sw/share/sddm/faces";
        ThemeDir = "/run/current-system/sw/share/sddm/themes";
      };
    };

# General = {
#   DefaultSession = "hyprland.desktop";
#   DisplayServer = "wayland";
#   GreeterEnvironment = "QT_WAYLAND_SHELL_INTEGRATION=layer-shell";
#   HaltCommand = "/run/current-system/systemd/bin/systemctl poweroff";
#   InputMethod =
#   Numlock = "none";
#   RebootCommand = "/run/current-system/systemd/bin/systemctl reboot";
# }
#
# Theme = {
#   Current = "breeze";
#   CursorSize = "24";
#   CursorTheme = "breeze_cursors";
#   FacesDir = "/run/current-system/sw/share/sddm/faces";
#   ThemeDir = "/run/current-system/sw/share/sddm/themes";
# }
#
# Users = {
#   HideShells = "/run/current-system/sw/bin/nologin";
#   HideUsers = "nixbld1,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld2,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld3,nixbld30,nixbld31,nixbld32,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9";
#   MaximumUid = "30000";
# }
#
# Wayland = {
#   CompositorCommand = "/nix/store/vlb3bwbzlr5rg5944yyc8k91l0f9yv0f-kwin-6.4.3/bin/kwin_wayland --no-global-shortcuts --no-kactivities --no-lockscreen --locale1";
#   EnableHiDPI = "true";
#   SessionDir = "/nix/store/91q2jg3hvq16y5rvh73zi6z2z9w40spw-desktops/share/wayland-sessions";
# }
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
