# vim:fileencoding=utf-8:foldmethod=marker

{ config, pkgs, lib, lib', ... }: lib'.easyMerge "m" {
# {{{ Terminal
  m.term.programs = lib'.enableMulti ''
    kitty
  '';
  programs.kitty.settings = {
    enable_audio_bell = false;
    background_opacity = "0.9";
    dynamic_backgronud_opacity = true;
  };
  # stylix.targets.kitty.enable = true;
# }}}

  m.surf.system.environmentPackages = with pkgs; [
    google-chrome discord discordo
  ];
  m.surf.programs = lib'.enableMulti ''
    firefox
  '';

  m.info.programs = lib'.enableMulti ''
    btop fastfetch
  '';
  # https://www.reddit.com/r/NixOS/comments/fsummx/how_to_list_all_installed_packages_on_nixos/
  environment.etc."current-system-packages".text = let
    packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
    sortedUnique = builtins.sort builtins.lessThan (lib.lists.unique packages);
    formatted = builtins.concatStringsSep "\n" sortedUnique;
  in formatted;
  programs.nushell.shellAliases.pkgs = "bat /etc/current-system-packages";

  m.hyprland-features = [ ./features/hyprland-upside-down.nix ];

  m.graphcis-pkgs.environment.systemPackages = with pkgs; [
    imagemagick ffmpeg vlc
  ];
  m.graphics-programs.programs = lib'.enableMulti ''
    obs-studio
  '';

  m.wine-pkgs.environment.systemPackages = with pkgs; [
    wine-wayland winetricks
  ];

  m.rdesk-pkgs.environment.systemPackages = with pkgs; [
    wlvncc
  ];

# {{{ Remote Connections and IoT
  m.wifi-features.imports = [ ./features/eduroam-wifi.nix ];
  features.nm-eduroam-wifi = let
    inherit (config.age) secrets;
  in {
    zid.source = secrets.zid.path;
    zpass.source = secrets.zpass.path;
  };
  networking.networkmanager.enable = true;
  users.groups.networkmanager.members = lib'.mkList "rickastley";

  m.conn-hardware.hardware = lib'.enableMulti "bluetooth";
  hardware.bluetooth.powerOnBoot = false; # TODO: alias to start with user pwd
  # Enable CUPS to print documents:
  m.conn-services.services = lib'.enableMulti "printing";
# }}}

# {{{ File Services
  m.fsrv-pkgs.system.environmentPackages = with pkgs; [
    keybase keybase-cli
  ];
  m.fsrv-lazy.lazy-services = lib'.mkList ''
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

# {{{ Gaming
  m.gaming-pkgs.environment.systemPackages = with pkgs; [
    prismlauncher
    mindustry-wayland
    (callPackage ../../pkgs/animdustry/package.nix {})
  ];
  m.gaming-programs.programs = lib'.enableMulti ''
    steam
  '';
  hardware.steam-hardware.enable = true;

  m.gaming-rdesk-pkgs.environment.systemPackages = with pkgs; [
    parsec-bin moonlight-qt
  ];
# }}}
}
