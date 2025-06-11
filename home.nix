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
      neofetch

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
      NIXPKGS_ALLOW_UNFREE = "1";
    };
  };

  programs.git = {
    enable = true;
# TODO: config
  };

#wayland.windowManager.hyprland.enable = true;
                       }
