{
  perSystem = { pkgs, ... }: {
    packages.script-apps-sshclone = pkgs.stdenvNoCC.mkDerivation {
      name = "sshclone";
      buildInputs = with pkgs; [
        php
        git
      ];
      text = builtins.readFile ./sshclone.sh;
      buildCommand = "mkdir -p $out/bin; echo $text > $out/bin/sshclone";
      meta.knownVulnerabilities = [
        "ArbitraryCodeExecution"
      ];
    };
  };
}
