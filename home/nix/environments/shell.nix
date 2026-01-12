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
      f = "job list";
      e = "enter";
    } // (let
      isTty = "[ \"$XDG_SESSION_TYPE\" == \"tty\" ]";
    in {
      h = "bash -c '${isTty} && start-hyprland'";
      k = "bash -c '${isTty} && startplasma-wayland'";
    });
    loginFile.text = "h";
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

      def aln [symlink: path] {
        let real = (readlink -f $symlink)
        mv $symlink $".($symlink)"
        cat $real o> $symlink
      }
    '';
      # let chrome_open = "~/Run/feat/chrome-open"
      # mkdir $chrome_open
      # job spawn { job spawn { glob $"($chrome_open)/*" | str join "\n" | entr -r "google-chrome-stable " } }
    environmentVariables = {
      config.edit_mode = "vi";
      EDITOR = "nvim";
    };
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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  programs.direnv.nix-direnv.enable = true;
}
