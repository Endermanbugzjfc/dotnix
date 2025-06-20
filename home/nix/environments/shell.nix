{
  programs.nushell = {
    enable = true;
    shellAliases = {
      please = "sudo";
      fg = "job unfreeze";
    };
    loginFile.text = ''
      use std/dirs # Replacement for pushd, popd

      ln -sf /run/user/1000 ~/Run
    '';
  };
  programs.bat.enable = true;
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
  };
}
