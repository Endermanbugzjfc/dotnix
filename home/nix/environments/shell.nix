{ pkgs, ... }: {
  home.packages = with pkgs; [
    entr # Re-run command when file changes.
  ];

  home.shell = {
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
  programs.nushell = {
    enable = true;
    shellAliases = {
      please = "sudo";
      fg = "job unfreeze";
    };
    configFile.text = ''
      use std/dirs # Replacement for pushd, popd
      use std/dirs shells-aliases *

      ln -sf /run/user/1000 ~/Run
    '';
  };
  programs.bat.enable = true;
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.jq.enable = true;
}
