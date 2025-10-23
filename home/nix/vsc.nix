# Git, GitHub, Sublime Merge...

{ pkgs, ... }: {

  programs.git = {
    enable = true;
    userName = "EndermanbugZJFC";
    signing.key = "CB0AE55D51722FA6";
    # signing.key = "3A70714AD76B80F0";
    extraConfig = {
      commit.gpgsign = true;
    };
  };
}
