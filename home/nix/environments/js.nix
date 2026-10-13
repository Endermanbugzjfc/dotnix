{ pkgs, pkgs-26_05, ... }: {
  home.packages = (with pkgs; [
    nodejs
    postman
    burpsuite
  ]) ++ [
    pkgs-26_05.typescript-language-server
  ];
}

