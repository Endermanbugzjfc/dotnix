{ inputs, ... }: {
  systems = import inputs.default-systems;
  perSystem = { system, pkgs, ... }: {
    devShells.default = pkgs.mkShellNoCC {
      packages = (with pkgs; [
        jujutsu # Version control.
        nh      # Nix Helper.
      ]) ++ [
        inputs.nix-update-input.packages.${system}.default
      ];
    };
  };
}
