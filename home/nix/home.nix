# Home lies packages and programs that require per-user (~/.config)
# configurations or login. As well as some packages that are too specific
# (see media.nix and word-processing.)

{ inputs, ... }: {
  imports = [
    inputs.stylix.homeModules.stylix
    inputs.agenix.homeManagerModules.default
    ../common

    ./environments

    ./vsc.nix
    ./media.nix
    ./editor.nix
    ./desktop.nix
    ./terminal.nix
    ./word-processing.nix
    ./information.nix
    ./social.nix
    ./internet.nix
    ./management.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  }; # TODO: make common

  home = {
    username = "rickastley";
    homeDirectory = "/home/rickastley";
    stateVersion = "25.05";
  };
}
