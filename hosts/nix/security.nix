{ pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    keybase-gui
    agenix-cli
  ];

  lazy-services = [
    "keybase"
    "kbfs"
  ];

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
}
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
