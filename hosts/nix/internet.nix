# Network services, web browsers...

{ pkgs, pkgs-protonvpn, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    openvpn
    sshfs

    rustdesk-flutter
  ];

  imports = let
    vpn = moduleArgs: import "${inputs.nixpkgs-protonvpn}/nixos/modules/programs/proton-vpn.nix" (moduleArgs // {
      pkgs = pkgs-protonvpn;
    });
  in [
    vpn
  ];

  programs.proton-vpn = {
    gui.enable = true;
    protonProtocols.enable = true;
    splitTunneling.enable = false;
  };

  programs.virt-manager.enable = true;
  users.users.rickastley.extraGroups = [ "libvirt" ];

  lazy-services = [
    "sshd"
    # "rustdesk-server"
  ];

  # Enable networking
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [ networkmanager-openvpn ];
  };
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
}
