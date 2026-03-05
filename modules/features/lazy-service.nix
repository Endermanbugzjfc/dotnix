{ config, lib, ... }: {
  options.lazy-services = with lib; mkOption {
    type = with types; listOf str;
    description = ''
      System-level services to install but do not enable them on boot
    '';
    default = [];
  };

  config = let services = config.lazy-services; in {
    services = builtins.listToAttrs (builtins.map (name: {
      inherit name;
      value.enable = true;
    }) services);
    systemd.services = builtins.listToAttrs (builtins.map (name: {
      inherit name;
      value.wantedBy = lib.mkForce [];
    }) services);
  };
}
