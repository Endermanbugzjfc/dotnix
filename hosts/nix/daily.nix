# vim:fileencoding=utf-8:foldmethod=marker

{ config, pkgs, lib, lib', inputs, ... }: lib'.easyMerge "m" {
# {{{ Terminal and Terminal Experience
#     Terminal emulators, CLI applications, and a few GUI applications that
#     I usually invoke from the terminal.
  m.term.imports = [
    inputs.nix-index-database.homeModules.nix-index
    ./features/hyprland-upside-down.nix
    ./features/nushell-comma-extended.nix
    ./features/current-system-packages.nix
  ];
  m.term.environment.systemPackages = with pkgs; [
    brightnessctl
    imagemagick ffmpeg vlc
    wine-wayland winetricks
    wlvncc
  ];
  m.term.programs = lib'.enableMulti ''
    btop fastfetch

    kitty
  '';
  programs.kitty.settings = {
    enable_audio_bell = false;
    background_opacity = "0.9";
    dynamic_backgronud_opacity = true;
  };

  # This also adds the `,` shell alias:
  m.term-exp.programs.nix-index-database = lib'.enableMulti "comma";
  programs.nushell.shellAliases.what = "bat /etc/${config.features.current-system-packages.file}";
  # stylix.targets.kitty.enable = true;
# }}}

# {{{ GUI Applications and Gaming
  m.guig.hardware = lib'.enableMulti "steam-hardware";
  m.guig.system.environmentPackages = with pkgs; [
    google-chrome discord discordo
    prismlauncher mindustry-wayland
    (callPackage ../../pkgs/animdustry/package.nix {})
    parsec-bin moonlight-qt # Remote desktops for gaming.
  ];
  m.guig.programs = lib'.enableMulti ''
    firefox
    obs-studio
    steam
  '';
# }}}

# {{{ Remote Connections and IoT
  m.wifi.imports = [ ./features/eduroam-wifi.nix ];
  features.nm-eduroam-wifi = let
    inherit (config.age) secrets;
  in {
    zid.source = secrets.zid.path;
    zpass.source = secrets.zpass.path;
  };
  networking.networkmanager.enable = true;
  users.groups.networkmanager.members = lib'.mkList "rickastley";

  m.conn.hardware = lib'.enableMulti "bluetooth";
  hardware.bluetooth.powerOnBoot = false; # TODO: alias to start with user pwd
  # Enable CUPS to print documents:
  m.conn.services = lib'.enableMulti "printing";

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
# }}}

# {{{ File Services
  m.fsrv.system.environmentPackages = with pkgs; [
    keybase keybase-cli
  ];
  m.fsrv.lazy-services = lib'.mkList ''
    sshd
    keybase kbfs
  ''; # TODO: kbfs-fuse
# }}}

# {{{ Keybinds
  m.keybinds.services = lib'.enableMulti ''
    keyd
  '';
  services.keyd.keyboards.default = {
    ids = [ "*" ];
    settings.main = {
      capslock = "esc";
      rightalt = "'"; # Quotes key broken on my laptop D:
    };
  };

  # https://www.reddit.com/r/NixOS/comments/yprnch/disable_touchpad_while_typing_on_nixos/
  environment.etc."libinput/local-overrides.quirks".text = lib.mkForce ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd*keyboard
    AttrKeyboardIntegration=internal
  '';
# }}}
}
