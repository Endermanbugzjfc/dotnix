{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    prismlauncher
    mindustry
    mindustry-wayland
    (callPackage ../../pkgs/animdustry/package.nix {})
  ];

  programs.steam.enable = true;
}
