{
  description = ''
    > An idiot admires complexity, a genius admires simplicity.
    -- Terry A. Davis

    https://github.com/Endermanbugzjfc/dotnix

    This is free and unencumbered software released into the public domain.

    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.

    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.

    For more information, please refer to <http://unlicense.org/>
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      # https://github.com/nix-community/nix-index-database?tab=readme-ov-file#usage-in-home-manager
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nvim-config = {
    #   url = "github:Endermanbugzjfc/nvim-config";
    #   flake = false; # TODO: turn to flake.
    # };

    agenix.url = "github:ryantm/agenix";

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # outputs = { self, nixpkgs, home-manager, nvim-config, agenix, ... } @ inputs : let
  outputs = { self, nixpkgs, home-manager, agenix, stylix, ... } @ inputs : let
    inherit (self) outputs;

    flake = {inherit inputs outputs; };

    homeModule = home-manager.nixosModules.home-manager;
    homeConfig = home-manager.lib.homeManagerConfiguration;
    nixHome.home-manager = {
      extraSpecialArgs = flake;
      users.rickastley = ./home/nix/home.nix;
    };
    agenixModule = agenix.nixosModules.default;
    stylixModule = stylix.nixosModules.stylix;
  in {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = flake;
      modules = [
        ./hosts/nix
        homeModule # TODO: move to home.nix
        nixHome # TODO: partially move to home.nix
        agenixModule # TODO: move to security.nix
        stylixModule # TODO: move to desktop.nix
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
