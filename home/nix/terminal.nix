# Kitty terminal and kitten utilities.
{ lib, pkgs, ... }: {
  wayland.windowManager.hyprland.settings."\$terminal" = "kitty --single-instance";
  programs.kitty = lib.mkForce {
    enable = true;
    # package = let
    #   kitty = pkgs.kitty;
    # in kitty.overrideAttrs (final: prev: {
    #   nativeBuildInputs = prev.nativeBuildInputs ++ [ pkgs.makeWrapper ];
    #   postInstall = ''
    #     wrapProgram $out/bin/kitty
    #   '';
    # });
    settings = {
      include = "./Adapta Nokto Maia.conf";
      enable_audio_bell = false;
      background_opacity = 0.9;
      dynamic_backgronud_opacity = true;
      touch_scroll_multiplier = 10.0;
    };
    keybindings = let
      binds = lib.mergeAttrsList ([{
        "ctrl+alt+n" = "new_os_window_with_cwd";
        "ctrl+alt+t" = "new_tab_with_cwd";
        "kitty_mod+m" = "detach_window ask";
        "kitty_mod_w" = "no_op";
      }] ++ copyBinds);
      copyBinds = [
        (mkCopyBind "p" "path")
        (mkCopyBind "w" "word")
        (mkCopyBind "l" "line")
        (mkCopyBind "h" "hash")
        (mkCopyBind "n" "linenum")
        (mkCopyBind "y" "hyperlink")
      ];
      mkCopyBind = key: type: {
        "kitty_mod+y>${key}" = "kitten hints --type ${type} --program wl-copy";
      };
    in binds;
  };
}
