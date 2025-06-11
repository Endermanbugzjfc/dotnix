{
# Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    efiSupport = true;
    fsIdentifier = "label";
    devices = [ "nodev" ];
    extraEntries = ''
      menuentry "Reboot" {
        reboot
      }
    menuentry "Poweroff" {
      halt
    }
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-e66afa16-555b-445d-a498-9b58f1b3c04e".device = "/dev/disk/by-uuid/e66afa16-555b-445d-a498-9b58f1b3c04e";
}
