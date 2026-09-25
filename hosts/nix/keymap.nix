# Keyd (xremap does not work on my machine).

{ lib, pkgs, ... }:
let
  # "AT Translated Set 2 keyboard" -- the builtin laptop keyboard.
  # Seen as Vendor=0001 Product=0001 in /proc/bus/input/devices, and as
  # at-translated-set-2-keyboard in `hyprctl devices`.
  builtinId = "0001:0001";
  builtinHyprDevice = "at-translated-set-2-keyboard";

  # Shared by every keyboard so new binds only have to be written once.
  binds.main = {
    capslock = "esc";
    rightalt = "'"; # Quotes key broken on my laptop D:
  };
in
{
  services.keyd = {
    enable = true;

    # The builtin keyboard is excluded here and handled by its own file below.
    # Splitting it out is what makes it detachable at runtime: keyd matches a
    # device only if some config file claims it, so deleting builtin.conf makes
    # keyd let go of the keyboard entirely, which in turn lets Hyprland disable
    # it (while keyd holds an exclusive grab, Hyprland only ever sees the
    # events as keyd-virtual-keyboard, so a device rule on the real keyboard
    # does nothing).
    keyboards.default = {
      ids = [
        "*"
        "-${builtinId}"
      ];
      settings = binds;
    };
    keyboards.builtin = {
      ids = [ builtinId ];
      settings = binds;
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "builtin-keyboard";
      runtimeInputs = [ pkgs.keyd ];
      text = ''
        live=/etc/keyd/builtin.conf
        static=/etc/static/keyd/builtin.conf

        case "''${1-}" in
        off)
          # Drop keyd's claim on the keyboard, then tell Hyprland to ignore it.
          sudo rm -f "$live"
          sudo keyd reload
          hyprctl keyword 'device[${builtinHyprDevice}]:enabled' false
          ;;
        on)
          sudo ln -sfn "$static" "$live"
          sudo keyd reload
          hyprctl keyword 'device[${builtinHyprDevice}]:enabled' true
          ;;
        *)
          echo "usage: builtin-keyboard on|off" >&2
          exit 1
          ;;
        esac
      '';
    })
  ];

  # https://www.reddit.com/r/NixOS/comments/yprnch/disable_touchpad_while_typing_on_nixos/
  environment.etc."libinput/local-overrides.quirks".text = lib.mkForce ''
    [Serial Keyboards]
    MatchUdevType=keyboard
    MatchName=keyd*keyboard
    AttrKeyboardIntegration=internal
  '';
}
