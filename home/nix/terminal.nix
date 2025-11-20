# Kitty terminal and kitten utilities.

{ lib, pkgs, ... }: {
  programs.kitty = lib.mkForce {
    enable = true;
    package = let
      kitty = pkgs.kitty;
    in kitty.overrideAttrs (final: prev: {
      nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeWrapper ];
      postInstall = ''
        wrapProgram $out/bin/kitty
      '';
    });
    settings = {
      include = "./Adapta Nokto Maia.conf";
      enable_audio_bell = false;
      background_opacity = 0.9;
      dynamic_backgronud_opacity = true;
    };
  };
  stylix.targets.kitty.enable = true;
}
