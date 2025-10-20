# Keyd (xremap does not work on my machine).

{ lib, ... }: {
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "esc";
        rightalt = "'"; # Quotes key broken on my laptop D:
      };
    };
  };

  # https://www.reddit.com/r/NixOS/comments/yprnch/disable_touchpad_while_typing_on_nixos/
  environment.etc."libinput/local-overrides.quirks".text = lib.mkForce ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd*keyboard
    AttrKeyboardIntegration=internal
  '';
}
