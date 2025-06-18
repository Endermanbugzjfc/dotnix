{ pkgs, ... }: {
  home.packages = with pkgs; [
    nimble
    nim_lk
  ];
}
