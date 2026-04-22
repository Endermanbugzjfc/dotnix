{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs
    postman
  ];

  mobile-shells.ts = {
    packages = [];
    lsps = {
      ts_ls = pkgs.typescript-language-server;
    };
  };
}

