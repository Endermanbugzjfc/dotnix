# Network services, web browsers...

{ lib, ... }: {
  imports = [
    ../common/features/install-sshd.nix
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

# Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
