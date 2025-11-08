# Plover, Obsidian Notes, WPS, OnlyOffice
{ config, pkgs, inputs, ... }: {
  home.packages = with pkgs; [
    obsidian

    plover.dev

    wpsoffice
    xournalpp
    config.lib.pkgs-25_05.citrix_workspace
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
}
