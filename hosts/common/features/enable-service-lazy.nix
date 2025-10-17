{ config, lib, ... }: {
  options.lazy-services = with lib; mkOption {
    type = with types; listOf str;
    description = ''
    Services to install but do not enable them on session start.
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
