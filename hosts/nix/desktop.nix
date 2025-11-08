# Desktop experience.

{ pkgs, inputs, ... }: {

  imports = [
    ../common/features/enable-hyprland.nix
    "${inputs.nixsys}/modules/emptty.nix"
  ];

  environment.systemPackages = with pkgs; [
    activate-linux
    nwg-look
  ];
  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.noto
    source-han-sans
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
    enable = false;
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
  };
  # services.xserver.displayManager.emptty = {
  #   # supports wayland.
  #   enable = true;
  #   package = pkgs.callPackage "${inputs.nixsys}/packages/emptty/wrapper.nix" {
  #     emptty-unwrapped = pkgs.emptty;
  #   };
  #   configuration = {
  #     AUTOLOGIN_SESSION = "hyprland";
  #     AUTOLOGIN = false;
  #     AUTOLOGIN_MAX_RETRY = 2;
  #     DEFAULT_USER = "rickastley";
  #   };
  # };
  # services.displayManager.sessionData.desktops = "/run/current-system/sw";
  services.getty = {
    autologinUser = "rickastley";
  };
  users.groups.nopasswdlogin.members = [ "rickastley" ];
  # systemd.user.services.hyprland = {
  #   unitConfig = {
  #     BindsTo = "graphical-session.target";
  #     # Upholds = "swaybg@333333.service";
  #   };
  #   serviceConfig = {
  #     ExecStart="${config.programs.hyprland.package}/bin/Hyprland";
  #     # RemainAfterExit="no";
  #     # Type = "notify";
  #   };
  #   wantedBy = [ "default.target" ];
  # };

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
