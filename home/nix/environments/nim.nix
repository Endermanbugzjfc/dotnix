{ pkgs, ... }: {
  home.packages = with pkgs; [
    nim_lk
  ];
}
