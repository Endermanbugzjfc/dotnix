{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    mindustry
    mindustry-wayland
  ];
}
