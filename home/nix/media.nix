# Vocaloid (if life is included).

{ pkgs, ... }: {
  programs.obs-studio.enable = true;
  home.packages = with pkgs; [
    imagemagick
    ffmpeg
  ];
}
