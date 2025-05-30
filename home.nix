{ config, pkgs, lib, ... }: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "rickastley";
    homeDirectory = "/home/rickastley";
    stateVersion = "25.05";

    packages = with pkgs; [
      # wl-clip-persistent
      wl-clipboard
      neofetch
      activate-linux
      sublime-merge

        google-chrome

        gcc
        cargo
# https://nixos.wiki/wiki/Python
        (python3.withPackages (python-pkgs: with python-pkgs; [
          tkinter
        ]))
    ];

#shell = {
#enableBashIntegration = true;
#enableNushellIntegration = true;
#};

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  programs.bash = {
    enable = true;
  };
  programs.nushell = {
    enable = true;
  };
  programs.kitty = lib.mkForce {
    enable = true;
    settings = {
      enable_audio_bell = false;
      background_opacity = "0.9";
      dynamic_backgronud_opacity = true;
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.git = {
    enable = true;
  };
  programs.gh = {
    enable = true;
  };
  programs.ripgrep = {
    enable = true;
  };

#wayland.windowManager.hyprland.enable = true;
                       }
