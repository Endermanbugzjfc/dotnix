{ config, lib, pkgs, inputs, ...}: {
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
  # environment.etc.test.text = builtins.toJSON config.security.services.sudo.text;

  # Note: `rules` is an experimental and hidden option.
  # https://github.com/NixOS/nixpkgs/blob/fabb8c9deee281e50b1065002c9828f2cf7b2239/nixos/modules/security/pam.nix#L154
  # environment.etc.test.text = builtins.toJSON (
  #   lib.mapAttrs' (k: v: {
  #     name = k;
  #     value = v.enable;
  #   }) config.security.pam.services.sudo.rules.auth
  # );

  security.pam.services.sudo.rules.auth.sudo-short-password = let
    dbKV = pkgs.writeText "dbKV" ''
      rickastley
      00
    '';
    passDb = pkgs.runCommand "passDb" {
      # Note: pam_userdb.so is linked to DB 4.8:
      inherit (pkgs) db48;
    } ''
      mkdir $out
      $db48/bin/db_load -T -t hash -f ${dbKV} $out/pass.db
    '';

    followingRule = config.security.pam.services.sudo.rules.auth.unix;
  in {
    order = followingRule.order - 10;
    control = "sufficient";
    modulePath = "${pkgs.pam}/lib/security/pam_userdb.so";
    settings.db = "${passDb}/pass";
  };

  # Some programs need SUID wrappers, can be configured further or are started in user sessions. programs.mtr.enable = true;
}
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
