{ pkgs, lib, ... }: {
  environment.systemPackages = with pkgs; [
# TODO: wl persistent

    wget
    wl-clipboard
    p7zip
    ripgrep

    comma # Runs programs without installing, useful for reading --help.
  ];

  programs.neovim = {
    enable = lib.mkDefault true;
    defaultEditor = true;
  };
  programs.screen.enable = lib.mkDefault true;
}
