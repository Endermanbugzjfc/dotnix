{ self, ... }: {
  flake.homeModules.obsidian-live-sync = {
    imports = [
      self.homeModules.couchdb
    ];

    services.couchdb.enable = true;
  };
}
