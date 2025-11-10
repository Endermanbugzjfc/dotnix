{
# Bootloader.
  boot.loader.systemd-boot.enable = true;
  # boot.loader.grub = {
  #   #enable = true;
  #   enable = false;
  #   useOSProber = true;
  #   efiSupport = true;
  #   fsIdentifier = "label";
  #   devices = [ "nodev" ];
  #   extraEntries = ''
  #     menuentry "Reboot" {
  #       reboot
  #     }
  #   menuentry "Poweroff" {
  #     halt
  #   }
  #   '';
  # };
  boot.loader.efi.canTouchEfiVariables = true;


# # https://nixos.wiki/wiki/Hibernation
#
  # boot.resumeDevice = "/dev/disk/by-uuid/0cabbb22-9054-4d56-8bbe-93497858d879"; # root parition
  # boot.resumeDevice = "/dev/mapper/luks-5de558fd-2f7c-4c6b-8ec1-400897cdb0e5"; # root parition
  boot.kernelParams = [
    # "mem_sleep_default=deep" # suspend before sleep.
    # also tried resume=/dev/disk/by-uuid/6afe82f3-8b75-4600-bd1a-df51fd7898cf
    "resume=/dev/disk/by-uuid/6afe82f3-8b75-4600-bd1a-df51fd7898cf"
    # "resume=/dev/dm-1"
  ];

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  # swapDevices =
  #   [
  #     {
  #       device = "/var/lib/swapfile";
  #       size = 17 * 1024;
  #     }
  #   ];
}
