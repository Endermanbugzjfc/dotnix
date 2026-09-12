{
  imports = [
    ../common/features/enable-cli-utils.nix
    ../../modules/features/lazy-service.nix

    ./configuration.nix
    ./internet.nix
    ./keymap.nix
    ./security.nix
    ./desktop.nix
    ./bootloader.nix
    ./compatibility.nix
    ./information.nix
    ./games.nix
    ./debug.nix
  ];
}
