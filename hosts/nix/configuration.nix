# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "nix"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Australia/Sydney";
  # https://www.reddit.com/r/NixOS/comments/l8yyed/changing_timezone_without_nixosrebuild_switch/
  # time.timeZone = "Asia/Hong_Kong";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rickastley = {
    isNormalUser = true;
    description = "rickastley";
    extraGroups = [ "networkmanager" "wheel" ];
    # packages = inputs.home-manager.packages.${pkgs.system}.default; # TODO
    hashedPassword = "$6$NFrzKpfF7MSxfvJN$aBoL3OzUeVmQhGjK7djbUXwIasugoscWvKE7fq5omY5hnknFD81rcPFC.laVQCbqRpFCoRCup3MTl9YX9gPyZ.";

    shell = pkgs.nushell;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = (_: true);

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Stuff that always broke 50% of the system when I forgot to install:
    gcc
    python3 # (See home/nix/environments/python.nix)
    gnumake
    cmake
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
