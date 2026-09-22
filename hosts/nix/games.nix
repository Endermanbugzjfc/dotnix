{ pkgs, pkgs-26_05, ... }: {
  environment.systemPackages = with pkgs; [
    (osu-lazer-bin.override { nativeWayland = true; })

    prismlauncher
    pkgs-26_05.mindustry-wayland
  ];

  programs.steam.enable = true;
}
