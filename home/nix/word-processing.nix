# Plover, Obsidian Notes, WPS, OnlyOffice
{ config, pkgs, inputs, ... }: {
  imports = [
    inputs.plover.homeManagerModules.plover
  ];

  home.packages = with pkgs; [
    obsidian

    wpsoffice
    xournalpp
    config.lib.pkgs-25_05.citrix_workspace
  ];
  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, B, exec, obsidian eval code='app.plugins.plugins[\"tray\"].showWindows()'"
  ];

# citrix:
  # nixpkgs.config.allowBroken = true;
  lib.pkgs-25_05 = import inputs.nixpkgs-25_05 ({
    system = "x86_64-linux";
      config.allowUnfree = true;
      config.allowUnfreePredicate = (_: true);
  });

  programs.onlyoffice.enable = true;
  programs.foliate = {
    enable = true;
  };

  programs.plover.enable = true;
  programs.plover.package = inputs.plover.packages."x86_64-linux".plover.withPlugins (ps: with ps; [
  ]);
}
