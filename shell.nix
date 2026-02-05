{
  mkShellNoCC,

  jujutsu,
}: mkShellNoCC {
  packages = [
    jujutsu
  ];
}
