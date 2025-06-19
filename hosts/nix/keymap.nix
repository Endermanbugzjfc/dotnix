# Keyd (xremap does not work on my machine).

{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main = {
        capslock = "esc";
        rightalt = "'";
      };
    };
  };
}
