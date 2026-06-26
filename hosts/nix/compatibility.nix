{ lib, pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wine-wayland
    winetricks
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  systemd.sockets.docker.wantedBy = lib.mkForce [];
}
