# Network services, web browsers...

{
  lazy-services = [
    "sshd"
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  # Conflicts with NetworkManager:
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Install firefox.
  programs.firefox.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };

  # services.favicon-proxy = {
  #   enable = true;
  #   users = [ "rickastley" ];
  # };
}
