# Install but do not enable on start up.
# https://www.reddit.com/r/NixOS/comments/16mbn41/install_but_dont_enable_openssh_sshd_service/

{ lib, ... }: {

  services.sshd.enable = true;

  systemd.services.sshd.wantedBy = lib.mkForce [];
              }

