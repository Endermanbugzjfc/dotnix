{ pkgs, ... }: {
  imports = [
    ./minecraft.nix
  ];

  # home.packages = with pkgs; [
  #   (callPackage ../../../pkgs/animdustry {})
  # ];
}
