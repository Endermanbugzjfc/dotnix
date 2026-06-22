{ config, pkgs, ... }: let
  zid = "z5667590";
  cse = "login0.cse.unsw.edu.au";
in {
  home.packages = with pkgs; [
    google-chrome
    moonlight-qt
  ];

  # services.ssh-agent.enable = true;
  # programs.nushell.extraConfig = config.sshAuthSock.initialization.nushell;
  # programs.ssh.settings."*".AddKeysToAgent = "yes";

  programs.ssh.enable = true;
  programs.ssh.enableDefaultConfig = false;
  programs.ssh.settings."cse ${cse}" = {
    HostName = cse;
    User = zid;
    IdentityFile = "~/.ssh/id_ed25519.cse";
    IdentitiesOnly = "yes";
  };
  # Default SSH key. This block is optional since `ssh` can pick up id_rsa without extra
  # configuration:
  programs.ssh.settings."*" = {
    IdentityFile = "~/.ssh/id_rsa";
  };
  # More keys in vsc.nix
}
