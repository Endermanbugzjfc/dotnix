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
    nix-update-input.url = "github:vimjoyer/nix-update-input";
    nix-update-input.inputs.nixpkgs.follows = "nixpkgs";
    # }}}
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
}
