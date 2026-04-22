# Kitty terminal and kitten utilities.
{ lib, pkgs, ... }: {
  wayland.windowManager.hyprland.settings."\$terminal" = "kitty --single-instance";
  programs.nushell.configFile.text = ''
    def --wrapped "kitten theme" [...$rest] {
      ^kitten theme --config-file-name current-theme.conf ...$rest
    }
  '';
  programs.kitty = {
    enable = true;
    font.name = "NotoMono Nerd Font Mono";
    font.size = 12;
    settings = {
      include = "./Adapta Nokto Maia.conf";
      enable_audio_bell = false;
      background_opacity = 0.9;
      dynamic_backgronud_opacity = true;
      touch_scroll_multiplier = 15.0;
    };
    keybindings = let
      binds = lib.mergeAttrsList ([{
        "ctrl+alt+n" = "new_os_window_with_cwd";
        "ctrl+alt+t" = "new_tab_with_cwd";
        "kitty_mod+m" = "detach_window ask";

        "kitty_mod+w" = "no_op";
        "kitty_mod+w>kitty_mod+w" = "close_window";
        "kitty_mod+q" = "no_op";
        "kitty_mod+q>kitty_mod+q" = "close_tab";

        "kitty_mod+f>h" = "launch --stdin-source=@screen_scrollback --type=overlay nvim";
        "kitty_mod+f>g" = "launch --stdin-source=@last_cmd_output --type=overlay nvim";

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
