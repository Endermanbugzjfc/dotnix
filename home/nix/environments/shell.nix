{ pkgs, ... }: {
  home.packages = with pkgs; [
    entr # Re-run command when file changes.
    nushell
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
      f = "job list";
    };
    configFile.text = ''
      use std/dirs # Replacement for pushd, popd
      use std/dirs shells-aliases *

      ln -sf /run/user/1000 ~/Run

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
  };
  programs.bat.enable = true;
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  programs.jq.enable = true;
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  programs.direnv.enable = true;
  programs.nix-direnv.enable = true;
}
