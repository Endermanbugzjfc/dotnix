# Desktop experience.

{ pkgs, ... }: {

  imports = [
    ../common/features/enable-hyprland.nix
  ];

  environment.systemPackages = with pkgs; [
    activate-linux
    nwg-look

    font-awesome
    nerd-fonts.noto
    source-han-sans
  ];
  systemd.sleep.extraConfig = ''
      AllowHybridSleep=no
      AllowSuspendThenHibernate=yes
      HibernateDelaySec=${builtins.toString (60*60*1)}
    ''; # TODO: variable hibnerate delay based on power supply mode.
  services.logind.extraConfig = ''
    HandleLidSwitchExternalPower=ignoe
    HandleLidSwitchDocked=ignore
  ''; # TODO: make service to turn off screen or do  fa  NCy ASITUFF

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true; # TODO
  services.desktopManager.plasma6.enable = true;

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
