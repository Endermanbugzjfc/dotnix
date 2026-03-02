{ lib, pkgs, inputs, ...}: {
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

  # Use different password for login and sudo:
  security.pam.services.sudo.text = let
    passText = pkgs.writeText "passText" ''
      rickastley
      00
    '';
    passDb = pkgs.runCommand "passDb" {
      # Note: pam_userdb.so is linked to DB 4.8:
      inherit (pkgs) db48;
    } ''
      mkdir $out
      $db48/bin/db_load -T -t hash -f ${passText} $out/pass.db
    '';
  in lib.mkForce ''
    # Account management.
    account required ${pkgs.pam}/lib/security/pam_unix.so

    # Authentication management.
    auth sufficient ${pkgs.pam}/lib/security/pam_userdb.so db=${passDb}/pass
    auth sufficient ${pkgs.pam}/lib/security/pam_unix.so likeauth try_first_pass
    auth required ${pkgs.pam}/lib/security/pam_deny.so

    # Password management.
    password sufficient ${pkgs.pam}/lib/security/pam_unix.so nullok yescrypt

    # Session management.
    session required ${pkgs.pam}/lib/security/pam_env.so conffile=/etc/pam/environment readenv=0
    session required ${pkgs.pam}/lib/security/pam_unix.so
    session required ${pkgs.pam}/lib/security/pam_limits.so conf=/nix/store/i421b3fnrslb9vq18507qyll4h5qjkkz-limits.conf
  '';


  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
}
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
