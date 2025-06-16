{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
    wl-clip-persist
    wget
    wl-clipboard
    p7zip
    ripgrep
    neofetch
    colordiff

    comma # Runs programs without installing, useful for reading --help.
  ];

  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
  };
  programs.screen.enable = lib.mkDefault true;
  programs.git.enable = lib.mkDefault true;
}
