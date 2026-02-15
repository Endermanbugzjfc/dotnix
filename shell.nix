{
  mkShellNoCC,

  jujutsu,
  nh,
}: mkShellNoCC {
  packages = [
    jujutsu # version control.
    nh      # Nix Helper.
  ];
}
