{
  lib,
  fetchFromGitHub,
  fetchgit,
  buildNimPackage,
  callPackage,

  xorg,
  libGL,

  copyDesktopItems,
  makeDesktopItem,
}: let
  animdustry = fetchFromGitHub {
    owner = "Anuken";
    repo = "animdustry";
    rev = "f408e632872929964a9b3f8888f1c7a18e6c1ead";
    hash = lib.fakeHash;
  };

  nimble2nix = fetchFromGitHub {
    owner = "bandithedoge";
    repo = "nimble2nix";
    rev = "6a6c4da2e2b3cc3b643744b76ecd8bb08f6be3a3";
    hash = lib.fakeHash;
  };
  buildNimblePackage = callPackage (nimble2nix + "/buildNixPackage.nix");
  nimble2nixTool = callPackage (nimble2nix + "/default.nix");
  # buildNimblePackage = (import nimble2nix + "/buildNimblePackage.nix"  { pks = {
  #   inherit lib, fetchgit;
  #   nimPackages = { inherit buildNimPackage };
  # }});

  makeNimble2nixFile = {
  };
  fau = buildNimblePackage {
    pname = "fau";
    verison = "0-unstable-2024-07-28"; # TODO: look at how makeDesktopItem defines so I can generate JSON as nativeBuildInput.

    nativeBuildInputs = [ makeNimble2nixFile ];

    src = fetchFromGitHub {
      owner = "Anuken";
      repo = "fau";
      rev = "1a4ce2a80c8aa5807cf922fd72d30b2ef7154fd6";
      hash = lib.fakeHash;
    };
  };


in stdenv.mkDerivation {
  pname = "animdustry";
  version = "0-unstable-2024-07-30";
  inherit version;

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
  installPhase = ''
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
    maintainers = with maintainers; [];
  };
}
