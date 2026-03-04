{ pkgs, ... }: {
  home.packages = with pkgs; [
    entr # Re-run command when file changes.
    (writeShellScriptBin "mv-swap" ''
      [ "$#" != "2" ] && echo "Please enter exactly two paths" && exit 1
      path_one="$1"
      path_two="$2"
      [ ! -e "$path_one" ] && echo "Path #1 does not exist" && exit 1
      [ ! -e "$path_two" ] && echo "Path #2 does not exist" && exit 1

      path_one_safe="''${path_one%/}"
      shunt="$path_one_safe.tmp"
      [ -e "$shunt" ] && echo "Temporary path occupied: $shunt" && exit 1

      mv "$path_one" "$shunt"
      mv "$path_two" "$path_one"
      mv "$shunt" "$path_two"
    '')
  ];

  home.shell = {
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
  programs.nushell = {
    enable = true;

    settings.edit_mode = "vi";
    settings.history.sync_on_enter = false; # Disable shared history.

    shellAliases = {
      please = "sudo";
      fg = "job unfreeze";
      f = "job list";
      e = "enter";
      ssh = "kitty +kitten ssh";
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

      # Actualise link:
      def aln [symlink: path] {
        let real = (readlink -f $symlink)
        mv $symlink $".($symlink)"
        cat $real o> $symlink
      }
    '';
      # let chrome_open = "~/Run/feat/chrome-open"
      # mkdir $chrome_open
      # job spawn { job spawn { glob $"($chrome_open)/*" | str join "\n" | entr -r "google-chrome-stable " } }

    # programs.neovim.defaultEditor not working for some reason, retry in future:
    environmentVariables.EDITOR = "nvim";
  };
  programs.bat.enable = true;
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";

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
