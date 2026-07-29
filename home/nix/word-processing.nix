# Plover, Obsidian Notes, WPS, OnlyOffice
{ pkgs, pkgs-25_05, inputs, ... }: {
  imports = [
    inputs.plover.homeManagerModules.plover
  ];

  home.packages = with pkgs; [
    affine
    obsidian

    wpsoffice
    xournalpp
    pkgs-25_05.citrix_workspace
  ];
  wayland.windowManager.hyprland.settings.bind = [
    "$mainMod, B, exec, obsidian eval code='app.plugins.plugins[\"tray\"].showWindows()'"
  ];

  programs.onlyoffice.enable = true;
  programs.foliate = {
    enable = true;
  };

  programs.plover.enable = true;
  programs.plover.package = inputs.plover.packages."x86_64-linux".plover.withPlugins (ps: with ps; [
  ]);
}
