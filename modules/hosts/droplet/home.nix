{ inputs, self, ... }: let
  home-manager = inputs.home-manager;
in {
  flake.homeConfigurations.rickastley = home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    modules = let
      modules = self.homeModules;
    in [
      {
        home.stateVersion = "25.11"; # Do NOT change.
        programs.home-manager.enable = true;
        # Note: when home-manager CLI is not available:
        # $ nix run home-manager/master -- init --switch
      }
      modules.obsidian-live-sync
    ];
  };

  imports = [
    home-manager.flakeModules.home-manager
  ];
}
