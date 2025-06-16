{
  imports = [
    ../common/features/enable-cli-utils.nix

    ./configuration.nix
    ./internet.nix
    ./keymap.nix
    ./security.nix
    ./desktop.nix
    ./bootloader.nix
    ./cross-platform.nix
    ./utils.nix
  ];
}
