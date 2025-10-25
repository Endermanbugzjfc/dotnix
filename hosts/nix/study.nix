# vim:fileencoding=utf-8:foldmethod=marker

{ pkgs, lib', ... }: lib'.easyMerge "m" {
# {{{ Writing
  m.writing.environment.systemPackages = with pkgs; [
    obsidian

    plover.dev

    wpsoffice
    xournalpp

    citrix_workspace
  ];
  m.writing.programs = lib'.enableMulti ''
    onlyoffice
  '';
# }}}

  m.math.environment.systemPackages = with pkgs; [
    numbat
  ];

  m.reading = lib'.enableMulti ''
    foliate
  '';
}
