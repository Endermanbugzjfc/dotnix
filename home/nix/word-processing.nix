# Plover, Obsidian Notes, WPS, OnlyOffice
{ pkgs, ... }: {
  home.packages = with pkgs; [
    obsidian

    plover.dev

    wpsoffice
    xournalpp
  ];

  programs.onlyoffice.enable = true;
  programs.foliate = {
    enable = true;
  };
}
