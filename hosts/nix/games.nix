{ lib, pkgs, pkgs-26_05, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    pkgs-26_05.mindustry-wayland
    # (callPackage ../../pkgs/animdustry/package.nix {})
  ];

  programs.steam.enable = true;
}
