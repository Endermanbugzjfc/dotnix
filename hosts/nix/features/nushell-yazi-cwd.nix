# https://yazi-rs.github.io/docs/quick-start/#shell-wrapper
{ config, lib, ... }: let
  inherit (lib) mkEnableOption mkDefault mkIf;
in {
  options.features.nushell-yazi-cwd.enable = mkEnableOption "yazi change-current-directory wrapper of nushell";
  config.features.nushell-yazi-cwd.enable = mkDefault true;
  config.programs.nushell.extraConfig = mkIf config.features.nushell-yazi-cwd ''
    def --env y [...args] {
      let tmp = (mktemp -t "yazi-cwd.XXXXXX")
      yazi ...$args --cwd-file $tmp
      let cwd = (open $tmp)
      if $cwd != "" and $cwd != $env.PWD {
        cd $cwd
      }
      rm -fp $tmp
    }
  '';
      # let chrome_open = "~/Run/feat/chrome-open"
      # mkdir $chrome_open
      # job spawn { job spawn { glob $"($chrome_open)/*" | str join "\n" | entr -r "google-chrome-stable " } }
}
