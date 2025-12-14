{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zlib,
}:

let
  version = "1.0.0-rc.1";
  rustVersion = "1.89.0";
  platform = "x86_64-unknown-linux-gnu";

  rustcTarball = fetchurl {
    url = "https://static.rust-lang.org/dist/rustc-${rustVersion}-${platform}.tar.gz";
    hash = "sha256-DKm0ilH2HEpeeZ0E8nypBiAA1rSTRgblurvzsCbkB0s=";
  };

  rustStdTarball = fetchurl {
    url = "https://static.rust-lang.org/dist/rust-std-${rustVersion}-${platform}.tar.gz";
    hash = "sha256-lZf2CAheDc9IoBDpgx27jq87MMi1fhhgXwLT9ARGw08=";
  };

  cargoTarball = fetchurl {
    url = "https://static.rust-lang.org/dist/cargo-${rustVersion}-${platform}.tar.gz";
    hash = "sha256-Phz/E+JkmM0pdfsY3ftEL/nHz+MBu5wxBXCkWXwDMeI=";
  };
in
stdenv.mkDerivation {
  pname = "rustowl";
  inherit version;

  src = fetchurl {
    url = "https://github.com/cordx56/rustowl/releases/download/v${version}/rustowl-${platform}.tar.gz";
    hash = "sha256-ir1fQfMEZg4xdNUrf2bgxziFtzm+xPZQv1IDIHbIOKM=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    zlib
  ];

  buildPhase = ''
    runHook preBuild

    tar -xzf ${rustcTarball}
    cp -r rustc-${rustVersion}-${platform}/rustc/* sysroot/${rustVersion}-${platform}/

    tar -xzf ${rustStdTarball}
    cp -r rust-std-${rustVersion}-${platform}/rust-std-${platform}/lib/rustlib sysroot/${rustVersion}-${platform}/lib/

    tar -xzf ${cargoTarball}
    cp -r cargo-${rustVersion}-${platform}/cargo/* sysroot/${rustVersion}-${platform}/

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib/rustowl
    cp rustowl $out/bin/rustowl-unwrapped
    cp -r sysroot $out/lib/rustowl/

    ln -s $out/lib/rustowl/sysroot/${rustVersion}-${platform}/bin/rustowlc $out/bin/rustowlc

    makeWrapper $out/bin/rustowl-unwrapped $out/bin/rustowl \
      --set RUSTOWL_SYSROOT $out/lib/rustowl/sysroot

    runHook postInstall
  '';

  meta = with lib; {
    description = "Visualize Ownership and Lifetimes in Rust";
    homepage = "https://github.com/cordx56/rustowl";
    license = licenses.mpl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "rustowl";
  };
}
