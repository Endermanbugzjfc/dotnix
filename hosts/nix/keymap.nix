# Keyd (xremap does not work on my machine).

{
  services.keyd = {
    keyboards = {
      ids = [ "*" ];
      settings.main = {
        capslock = "esc";
        rightalt = "\"";
      };
    };
  };
}
