{
  perSystem = { pkgs, ... }: {
    packages.script-apps-sshclone = pkgs.stdenvNoCC.mkDerivation {
      name = "sshclone";
      buildInputs = with pkgs; [
        php
        git
      ];
      text = ''
        #!${pkgs.php}
        ${builtins.readFile ./sshclone.php}
      '';

      buildCommand = "mkdir -p $out/bin; echo $text > $out/bin/sshclone";
    };
  };
}
