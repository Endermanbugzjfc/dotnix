# Git, GitHub, Sublime Merge...

{ pkgs, ... }: {
  home.packages = with pkgs; [
    sublime-merge
  ];

  programs.gh.enable = true;

  programs.git = {
    enable = true;
    userName = "EndermanbugZJFC";
    signing.key = "CB0AE55D51722FA6";
    # signing.key = "3A70714AD76B80F0";
    extraConfig = {
      commit.gpgsign = true;
    };
  };
  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.matchBlocks."github.com" = {
    hostname = "github.com";
    user = "git";
    identityFile = "~/.ssh/github_ezjfc";
    identitiesOnly = true;
  };

  programs.lazygit.enable = true;
}
