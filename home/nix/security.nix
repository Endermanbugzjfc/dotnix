{
  age.identityPaths = [ "~/.ssh/id_rsa" ];

  programs.gpg.enable = true;
  services.gnupg-agent = {
    enable = true;
    enableSshSupport = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };

  # home.file.".gnupg/private-keys-v1.d/CB0AE55D51722FA6.key".path = 
}
