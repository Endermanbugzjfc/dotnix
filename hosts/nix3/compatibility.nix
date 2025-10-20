{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wine-wayland
    winetricks
  ];

  virtualisation.docker.enable = true;
}
