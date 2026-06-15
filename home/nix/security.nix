{ config, ... }: {
  age.identityPaths = [ "~/.ssh/id_rsa" ];
  age.secrets.github_rate_limit_pat = {
    # github_rate_limit_pat.conf
    # ```
    # access-tokens = github.com=ghp_...
    # ```
    # Expiration: 15/06/2027
    file = ../../secrets/github_rate_limit_pat.conf.age;
    mode = "440";
    owner = "rickastley";
    group = "rickastley";
  };
  nix.extraOptions = ''
    !include ${config.age.secrets.github_rate_limit_pat.path}
  '';

  programs.gpg.enable = true;
  services.gnupg-agent = {
    enable = true;
    enableSshSupport = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
}
