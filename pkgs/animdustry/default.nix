{
  pkgs,
  lib,
  fetchFromGitHub,
}:
pkgs.stdenv.mkDerivation rec {
  pname = "animdustry";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "anuken";
    repo = "animdustry";
    rev = "v" + version;
    # hash = "sha256-QWr+xog16MmybhQlEWbskYa/dypb9Ld54MOdobTbyMo=";
    fetchSubmodules = true;
  };

  # https://nixos.org/manual/nixpkgs/stable/#var-stdenv-depsBuildBuild
  nativeBuildBuild = with pkgs; [ nimble ];
  # https://gist.github.com/CMCDragonkai/45359ee894bc0c7f90d562c4841117b5
  nativeBuildInputs = with pkgs; [ # (depsBuildHost)
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libgl
    xorg.libXxf86vm

    copyDesktopItems
  ];

  enableParallelBuilding = true;

  NIMBLE_DIR="$(pwd)/.nimble";
  PATH="$PATH:$NIMBLE_DIR";

  configurePhase = ''
    runHook preConfigure

    mkdir .nimble

    nimble install -y -d

    runHook postConfigure
  '';

  desktopItems = [ let {
    name = "Animdustry";
    exec = "animdustry";
    icon = exec;
  } in pkgs.makeDesktopItem {
    name = name;
    desktopName = name;
    icon = icon;
    exec = exec;
    categories = [ "Game" ];
  } ];


  # https://nixos.org/manual/nixpkgs/stable/#sec-stdenv-phases
  buildPhase = ''
    runHook preBuild

    nimble deploy lin

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 ./assets/icon.png $out/share/icons/hicolor/64x64/apps/animdustry.png
    mkdir -p $out/bin
    mv ./build/main-* $out/bin/animdustry

    runHook postInstall
  '';

  meta = with lib; {
    # https://nixos.org/manual/nixpkgs/stable/#var-meta-description
    description = "Anime gacha bullet hell rhythm game";
    longDescription = "the anime gacha bullet hell rhythm game; created as a mindustry april 1st event";
    homepage = "https://github.com/Anuken/animdustry";
    downloadPage = "https://github.com/Anuken/animdustry/releases";
    sourceProvenance = with sourceTypes; [ fromSource ];
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
