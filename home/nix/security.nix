{
  programs.gpg.enable = true;
  services.gnupg-agent = {
    enable = true;
    enableSshSupport = true;
    enableNushellIntegration = true;
  };
}
