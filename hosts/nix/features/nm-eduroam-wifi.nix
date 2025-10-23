{ lib, ... }: with lib; let
  inherit (lib) mkEnableOption mkDefault mkIf;
  cfg = config.features.nm-eduroam-wifi;
in {
  options.features.nm-eduroam-wifi = {
    enable = mkEnableOption "eduroam wifi config of NetworkManager";
    zid.source = mkOption {
      type = with types; path;
      description = ''
        Path to the plain-text file containing student ID

        The ID will be used as the username to authenticate eduroam so it
        should start with a lowercase "z" and followed by seven digits.

        The plain-text file should NOT be decrypted before runtime. It is
        recommended to use a secrets management tool of NixOS, such as Agenix.
      '';
      default = "";
    };
    zpass.source = mkOption {
      type = with types; path;
      description = ''
        Path to the plain-text file containing zPass

        zPass is the password for university (main-campus) websites, including
        Moodle. It will be used as the password to authenticate eduroam.

        The plain-text file should NOT be decrypted before runtime. It is
        recommended to use a secrets management tool of NixOS, such as Agenix.
      '';
      default = "";
    };
    extraConfig = mkOption {
      type = with types; lines;
      description = "Extra config to append at the end of eduroam.nmconnection";
    };
    autoConnect = mkEnableOption "auto-connecting of eduroam wifi";
  };
  config.features.nm-eduroam-wifi = {
    enable = mkDefault true;
    autoConnect = mkDefault true;
  };

# TODO
  config.environment.etc."NetworkManager/system-connections/eduroam.nmconnection".text = mkIf cfg.enable ''
    [connection]
    id=eduroam
    uuid=2e83ee0f-2ce5-4175-8e60-2b46b497e41d
    type=wifi
    autoconnect=${boolToString cfg.autoConnect}

    [wifi]
    mode=infrastructure
    ssid=eduroam

    [wifi-security]
    key-mgmt=wpa-eap

    [802-1x]
    eap=peap;
    identity=
    password=
    phase2-auth=mschapv2

    [ipv4]
    method=auto

    [ipv6]
    addr-gen-mode=default
    method=auto

    [proxy]

    ${cfg.extraConfig}
  '';
}
