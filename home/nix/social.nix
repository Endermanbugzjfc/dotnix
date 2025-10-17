{ pkgs, ... }: {
  home.packages = with pkgs; [
    discord
    discordo # TUI client.
  ];
}
