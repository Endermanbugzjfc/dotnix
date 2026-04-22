{ pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs
    postman
    typescript-language-server
  ];
}

