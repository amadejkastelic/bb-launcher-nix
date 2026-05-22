{
  lib,
  gcc14Stdenv,
  fetchFromGitHub,
  makeWrapper,

  alsa-lib,
  boost,
  cmake,
  cryptopp,
  game-music-emu,
  glslang,
  ffmpeg,
  flac,
  fluidsynth,
  fmt,
  half,
  jack2,
  libdecor,
  libffi,
  libGL,
  libpulseaudio,
  libunwind,
  libusb1,
  libvorbis,
  libxkbcommon,
  libxmp,
  libgbm,
  libx11,
  libxcb,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  libxscrnsaver,
  libxtst,
  magic-enum,
  mesa,
  mpg123,
  pipewire,
  pkg-config,
  pugixml,
  rapidjson,
  renderdoc,
  robin-map,
  sndio,
  stb,
  toml11,
  util-linux,
  vulkan-headers,
  vulkan-loader,
  vulkan-memory-allocator,
  wayland,
  wayland-scanner,
  xbyak,
  xxhash,
  zenity,
  zlib-ng,
  zydis,
}:

gcc14Stdenv.mkDerivation (finalAttrs: {
  pname = "shadps4";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "shadps4-emu";
    repo = "shadPS4";
    tag = "v.${finalAttrs.version}";
    hash = "sha256-ZYY8PlHEz6jj000Lrllqsk4Da6/CnNdSQHx1+89+yZM=";
    fetchSubmodules = true;

    leaveDotGit = true;
    postFetch = ''
      cd "$out"
      git rev-parse --short=8 HEAD > $out/COMMIT
      date -u -d "@$(git log -1 --pretty=%ct)" "+%Y-%m-%dT%H:%M:%SZ" > $out/SOURCE_DATE_EPOCH
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  postPatch = ''
    substituteInPlace src/common/scm_rev.cpp.in \
      --replace-fail @APP_VERSION@ ${finalAttrs.version} \
      --replace-fail @GIT_REV@ $(cat COMMIT) \
      --replace-fail @GIT_BRANCH@ ${finalAttrs.version} \
      --replace-fail @GIT_DESC@ bloodborne-nix \
      --replace-fail @BUILD_DATE@ $(cat SOURCE_DATE_EPOCH)
  '';

  buildInputs = [
    alsa-lib
    boost
    cryptopp
    game-music-emu
    glslang
    ffmpeg
    flac
    fluidsynth
    fmt
    half
    jack2
    libdecor
    libffi
    libGL
    libpulseaudio
    libunwind
    libusb1
    libvorbis
    libxkbcommon
    libxmp
    libgbm
    libx11
    libxcb
    libxcursor
    libxext
    libxi
    libxrandr
    libxscrnsaver
    libxtst
    magic-enum
    mesa
    mpg123
    pipewire
    pugixml
    rapidjson
    renderdoc
    robin-map
    sndio
    stb
    toml11
    util-linux
    vulkan-headers
    vulkan-loader
    vulkan-memory-allocator
    wayland
    xbyak
    xxhash
    zlib-ng
    zydis
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
    wayland-scanner
  ];

  cmakeFlags = [
    (lib.cmakeBool "ENABLE_UPDATER" false)
    (lib.cmakeBool "SDL_WAYLAND" true)
    (lib.cmakeBool "SDL_WAYLAND_SHARED" false)
  ];

  cmakeBuildType = "RelWithDebugInfo";
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin shadps4
    install -Dm644 $src/.github/shadps4.png $out/share/icons/hicolor/512x512/apps/net.shadps4.shadPS4.png
    install -Dm644 -t $out/share/applications $src/dist/net.shadps4.shadPS4.desktop
    install -Dm644 -t $out/share/metainfo $src/dist/net.shadps4.shadPS4.metainfo.xml

    wrapProgram $out/bin/shadps4 \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libpulseaudio
          pipewire
          wayland
          libxkbcommon
          libGL
          mesa
        ]
      } \
      --prefix PATH : ${lib.makeBinPath [ zenity ]}

    runHook postInstall
  '';

  runtimeDependencies = [
    vulkan-loader
    libxi
    wayland
    libxkbcommon
    libGL
    mesa
  ];

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Early in development PS4 emulator";
    homepage = "https://github.com/shadps4-emu/shadPS4";
    license = lib.licenses.gpl2Plus;
    mainProgram = "shadps4";
    platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86_64;
  };
})
