{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,

  qt6,

  cryptopp,
  fmt,
  pugixml,
  sdl3,
  toml11,
  vulkan-headers,
  vulkan-loader,
  zlib,
  nlohmann_json,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bb-launcher";
  version = "16.01";

  src = fetchFromGitHub {
    owner = "rainmakerv3";
    repo = "BB_Launcher";
    tag = "Release${finalAttrs.version}";
    hash = "sha256-VAVSKsOdxsGeDW9geKYukRYoVGok/mZhTCZOZmzXM1s=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace settings/updater/BuildInfo.cpp.in \
      --replace-fail @GIT_REV@ 46fb13ff \
      --replace-fail @GIT_BRANCH@ ${finalAttrs.version} \
      --replace-fail @GIT_DESC@ bloodborne-nix \
      --replace-fail @BUILD_DATE@ "2026-05-20T04:10:21Z"

    substituteInPlace dist/BBLauncher.desktop \
      --replace-fail "Exec=BB_Launcher" "Exec=bb-launcher" \
      --replace-fail "Icon=BBIcon" "Icon=bb-launcher"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    cryptopp
    fmt
    nlohmann_json
    pugixml
    sdl3
    toml11
    vulkan-headers
    zlib

    qt6.qtbase
    qt6.qttools
    qt6.qtdeclarative
    qt6.qtmultimedia
    qt6.qtimageformats
    qt6.qtwebview
    qt6.qtwebsockets
  ];

  qtWrapperArgs = [
    "--suffix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}"
  ];

  cmakeFlags = [
    (lib.cmakeBool "USE_WEBENGINE" false)
    (lib.cmakeBool "FORCE_UAC" false)
  ];

  cmakeBuildType = "Release";

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin BB_Launcher
    install -Dm644 $src/dist/BBIcon.png $out/share/icons/hicolor/512x512/apps/bb-launcher.png
    install -Dm644 -t $out/share/applications $src/dist/BBLauncher.desktop

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Dedicated shadPS4 launcher focused on Bloodborne";
    homepage = "https://github.com/rainmakerv3/BB_Launcher";
    license = lib.licenses.gpl3Plus;
    mainProgram = "BB_Launcher";
    platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86_64;
  };
})
