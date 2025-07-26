{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    mindustry
    mindustry-wayland
  ];

  programs.steam.enable = true;
}
