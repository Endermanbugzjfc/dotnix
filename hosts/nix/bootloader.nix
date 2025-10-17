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


  # boot.kernelParams = ["resume_offset=<offset>"];
#
# # https://nixos.wiki/wiki/Hibernation
#
  boot.resumeDevice = "/dev/disk/by-uuid/0cabbb22-9054-4d56-8bbe-93497858d879"; # root parition

  powerManagement.enable = true;


  # already has swap device at hardware-configuration

  # swapDevices = [
  # {
  #   device = "/var/lib/swapfile";
  #   size = 17 * 1024; # 17GB in MB
  # }
  # ];
}
