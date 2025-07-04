{
  imports = [
    ../common/features/enable-cli-utils.nix
    ../common/features/enable-service-lazy.nix

    ./configuration.nix
    ./internet.nix
    ./keymap.nix
    ./security.nix
    ./desktop.nix
    ./bootloader.nix
    ./cross-platform.nix
    ./information.nix
    ./games.nix
  ];
}
