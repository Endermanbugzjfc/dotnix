{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs
    postman
    burpsuite
    typescript-language-server
  ];
}

