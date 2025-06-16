{
  lib,
  buildNimPackage,
  fetchFromGitHub,

  xorg,
  libGL,
  copyDesktopItems,
  makeDesktopItem,
}: let
  animdustry = fetchFromGitHub {
    owner = "anuken";
    repo = "animdustry";
    rev = "v" + final.version;
    deepClone = true;
    leaveDotGit = true;
    hash = "sha256-gOa/LUBjQYcgW9QBlR/2zO114ngxwkkYd0nFwLmVsaw=";
  };

  fau = buildNimPackage (final: prev: {
    src = fetchFromGitHub {
      owner = "anuken";
      repo = "fau";
      rev = "v" + final.version;
      deepClone = true;
      leaveDotGit = true;
      hash = "sha256-gOa/LUBjQYcgW9QBlR/2zO114ngxwkkYd0nFwLmVsaw=";
    };
  });
  msgpack4nim = fetchFromGitHub {

  };
in buildNimPackage (final: prev: {
  pname = "animdustry";
  version = "1.2";

  src = animdustry;

  nativeBuildInputs = [ # (depsBuildHost)
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libGL
    xorg.libXxf86vm
    # TODO: compile for wayland

    # git
    copyDesktopItems
  ];

  enableParallelBuilding = false;
  # doCheck = false;

  nimbleFile = "animdustry.nimble";

  NIMBLE_DIR = (builtins.toString ./.) + "/.nimble";
  PATH = "$PATH:$NIMBLE_DIR/bin";
  postConfigure = ''
    nimble install -y -d
  '';

  postBuild = ''
    nimble deploy lin
  '';
  installPhase = # Avoid the installation of dependencies (faupack).
  ''
    runHook preInstall

    install -Dm644 ./assets/icon.png $out/share/icons/hicolor/64x64/apps/animdustry.png
    mkdir -p $out/bin
    mv ./build/main-* $out/bin/animdustry

    runHook postInstall
  '';

  desktopItems = let
    name = "Animdustry";
    exec = "animdustry";
    icon = exec;
  in makeDesktopItem {
    name = name;
    desktopName = name;
    icon = icon;
    exec = exec;
    categories = [ "Game" ];
  };

  meta = with lib; {
    # https://nixos.org/manual/nixpkgs/stable/#var-meta-description
    description = "Anime gacha bullet hell rhythm game";
    longDescription = "the anime gacha bullet hell rhythm game; created as a mindustry april 1st event";
    homepage = "https://github.com/Anuken/animdustry";
    downloadPage = "https://github.com/Anuken/animdustry/releases";
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = licenses.gpl3;
    # platforms = platforms.all;
  };
})
