# vim:fileencoding=utf-8:foldmethod=marker

{ pkgs, lib', ... }: lib'.easyMerge "m" {
# {{{ Writing
  m.writing-pkgs.system.environmentPackages = with pkgs; [
    obsidian

    plover.dev

    wpsoffice
    xournalpp

    citrix_workspace
  ];
  m.writing-programs.programs = lib'.enableMulti ''
    onlyoffice
  ''
# }}}

  m.math.environment.systemPackages = with pkgs; [
    numbat
  ];

  m.reading-programs = lib'.enableMulti ''
    foliate
  '';
}
