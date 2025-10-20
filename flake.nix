{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense

    NixOS / Nix package manager configurations for my personal environments,
    including laptop, desktop and VPS.
    For briefs regarding each environment, see hosts/README.md.

    Other flakes in this repository:
    - ./utils/flake.nix
    - ./wallpapers/flake.nix
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utilities.url = ./utils;

    hyprqt6engine.url = "github:hyprwm/hyprqt6engine";
    mindustrice.url = "/home/rickastley/Documents/ts/Mindustrice/"; # TODO: test
  };

  outputs = { self, nixpkgs, home-manager, utilities, ... } @ inputs : let
    # agenixModule = agenix.nixosModules.default;
    # stylixModule = stylix.nixosModules.stylix;
  in {
    nixosConfigurations.nix = let
      system = "x86_64-linux";
    in nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit system inputs; };
      modules = [
        # ./hosts/nix/configuration.nix
        ./hosts/nix/dev.nix
      ];
    };

    # homeConfigurations = {
    #   "rickastley@nix" = homeConfig {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #     extraSpecialArgs = flake;
    #     modules = [
    #       ./home/nix/home.nix
    #     ];
    #   };
    #   "rickastley@arch" = home-manager.lib.homeManagerConfiguration {
    #     extraSpecialArgs = flake;
    #     pkgs = nixpkgs.legacyPackages."x86_64-linux";
    #     modules = [
    #       ./home/arch/home.nix
    #     ];
    #   };
    # };
  };
}
