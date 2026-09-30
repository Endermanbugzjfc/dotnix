{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    # Userland profile configurations:
    nix-maid.url = "git+https://codeberg.org/viperML/nix-maid";

    # Personal helpers:
    nixche.url = "github:Ezjfc/nixche";
    nixche.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];
      imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.easyOverlay
      ];
  };
}
