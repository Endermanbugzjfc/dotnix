# Kitty terminal and kitten utilities.

{ lib, ... }: {
  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      enable_audio_bell = false;
      background_opacity = "0.9";
      dynamic_backgronud_opacity = true;
    };
  };
}
