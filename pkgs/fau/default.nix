{
  lib,
  fetchFromGitHub,
  buildNimPackage,
}: buildNimPackage (finalAttrs: {
  pname = "fau";
  verison = "0-unstable-2024-07-28";

  src = fetchFromGitHub {
    owner = "Anuken";
    repo = "fau";
    rev = "1a4ce2a80c8aa5807cf922fd72d30b2ef7154fd6";
    deepClone = true;
    hash = lib.fakeHash;
  };

  lockFile = ./lock.json;

  nimFlags = [
    "-d:NimblePkgVersion=${finalAttrs.version}"
  ];

  meta = with lib; {
    description = "Nim game framework";
    homepage = "https://github.com/Anuken/fau";
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with maintainers; [];
  };
})
