{
  description = ''
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
    nixpkgs-25_05.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-26_05.url = "github:nixos/nixpkgs/release-26.05";
    nixpkgs-hyprland.url = "github:nixos/nixpkgs?rev=e7439b6b14ad3cc35d05608ebca9bce01a25f5f8";
    nixpkgs-protonvpn.url =
  "github:schembriaiden/nixpkgs/proton-vpn-update";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      # https://github.com/nix-community/nix-index-database?tab=readme-ov-file#usage-in-home-manager
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixche.url = "github:ezjfc/nixche";

    # stylix = {
    #   url = "github:danth/stylix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # TODO: checkout base16.nix and nix-colors

    # Hyprland stuff:
    hyprqt6engine.url = "github:hyprwm/hyprqt6engine";

    # NOTE: run `nix flake check` before rebuilding or otherwise the clone might fail:
    marble-shell = {
      url = "github:ezjfc/marble-shell/improve-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # mindustrice.url = "/home/rickastley/Documents/ts/Mindustrice/"; # TODO: test

    plover.url = "github:openstenoproject/plover-flake";

    binary-ninja.url = "github:jchv/nix-binary-ninja";
    binary-ninja.inputs.nixpkgs.follows = "nixpkgs";

    codex-cli.url = "github:sadjow/codex-cli-nix";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs : let
    inherit (self) outputs;

    system = "x86_64-linux";
    specialArgs = let
      importOpts = {
        inherit system;
        config.allowUnfree = true;
        config.allowUnfreePredicate = (_: true);
      };
    in {
      inherit inputs outputs;

      pkgs-25_05 = import inputs.nixpkgs-25_05 importOpts;
      pkgs-26_05 = import inputs.nixpkgs-26_05 importOpts;
      pkgs-hyprland = import inputs.nixpkgs-hyprland importOpts;
      # Build only the Proton stack from the PR, using our normal dependencies.
      pkgs-protonvpn = import inputs.nixpkgs (importOpts // {
        overlays = [
          (final: prev: let
            protonSource = inputs.nixpkgs-protonvpn;
          in {
            pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
              (pythonFinal: _pythonPrev: {
                proton-vpn-api-core = pythonFinal.callPackage
                  "${protonSource}/pkgs/development/python-modules/proton-vpn-api-core" {
                    # Keep the PR's sparse registry support and vendor hash,
                    # but build the fetcher with our normal dependencies.
                    rustPlatform = final.rustPlatform // {
                      fetchCargoVendor = final.callPackage
                        "${protonSource}/pkgs/build-support/rust/fetch-cargo-vendor.nix" { };
                    };
                  };
                proton-vpn-daemon = pythonFinal.callPackage
                  "${protonSource}/pkgs/development/python-modules/proton-vpn-daemon" { };
              })
            ];

            # Call linux.nix directly so withSplitTunneling can be overridden.
            proton-vpn = final.callPackage
              "${protonSource}/pkgs/by-name/pr/proton-vpn/linux.nix" {
                meta = prev.proton-vpn.meta;
              };
            proton-vpn-cli = final.callPackage
              "${protonSource}/pkgs/by-name/pr/proton-vpn-cli/package.nix" { };
          })
        ];
      });
    };

    homeModule = home-manager.nixosModules.home-manager;
    nixHome.home-manager = {
      extraSpecialArgs = specialArgs;
      users.rickastley = ./home/nix/home.nix;
    };
  in {
    nixosConfigurations.nix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = specialArgs;
      modules = [
        ./hosts/nix
        homeModule # TODO: move to home.nix
        nixHome # TODO: partially move to home.nix
      ];
    };

    # homeConfigurations = {
    #   "rickastley@nix" = home-manager.lib.homeManagerConfiguration {
    #     pkgs = nixpkgs.legacyPackages.x86_64-linux;
    #     extraSpecialArgs = specialArgs;
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
