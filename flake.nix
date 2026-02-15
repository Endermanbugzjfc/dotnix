{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense
  '';

  inputs = {
    # {{{ Dendritic Pattern
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    default-systems.url = "github:nix-systems/default";
    # }}}

    # {{{ General
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    nix-update-input.url = "github:vimjoyer/nix-update-input";
    # }}}

    # {{{ Inputs Override
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-update-input.inputs.nixpkgs.follows = "nixpkgs";
    # }}}
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
}
