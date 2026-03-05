{ config, lib, pkgs, inputs, ...}: {
  imports = [
    ../../modules/features/sudo-short-password.nix
  ];

  sudo-short-password = {
    enable = true;
    users.rickastley.password = "00";
  };

  environment.systemPackages = with pkgs; [
    keybase-gui
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    openssl
  ];

  lazy-services = [
    "keybase"
    "kbfs"
  ];

  programs.gnupg.agent.enable = true;
  programs.gnupg.agent.settings = let
    storeSeconds = 60 * 60 * 2;
  in {
    default-cache-ttl = storeSeconds;
    max-cache-ttl = storeSeconds;
  };
  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
}
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
