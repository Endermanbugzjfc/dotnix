{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    nodejs
  ];

  mobile-shells.ts = {
    packages = [];
    lsps = {
      ts_ls = pkgs.typescript-language-server;
    };
  };
}

