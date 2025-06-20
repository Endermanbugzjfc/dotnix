{ name, script }: {
  systemd.user.services.$name = {
    inherit script;
    wantedBy = [ "multi-user.target" ];
  }
}
