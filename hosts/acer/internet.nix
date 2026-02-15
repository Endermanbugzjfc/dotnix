{ pkgs, ... }: {
  imports = [
    ../../version-pinning/google-chrome
  ];

  home.packages = with pkgs; [
    discordo
  ];

  programs.firefox.enable = true; # Kept for development purposes.
  guest-account.programs.firefox.enable = true;

  # I need two clients to stream in multiple servers:
  programs.discord.enable = true;
  programs.vesktop.enable = true;

  user.groups.networkmanager.members = [ "rickastley" ];
}
