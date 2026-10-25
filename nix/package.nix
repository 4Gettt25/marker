{ lib, stdenvNoCC, makeWrapper, python3, perl, ncurses }:

stdenvNoCC.mkDerivation {
  pname = "marker";
  version = "0-unstable-2026-10-25";
  src = lib.cleanSource ../.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/marker $out/bin
    cp -r marker tldr bin $out/share/marker/

    # Shell integration: call the wrapper below, and find python3/perl/tput
    # in the store instead of relying on PATH.
    substituteInPlace $out/share/marker/bin/marker.sh \
      --replace-fail '${"$"}{MARKER_HOME}/bin/marker' "$out/bin/marker" \
      --replace-fail 'python -c' '${python3.interpreter} -c' \
      --replace-fail 'perl -nle' '${lib.getExe perl} -nle' \
      --replace-fail 'tput cup' '${ncurses}/bin/tput cup'

    makeWrapper ${python3.interpreter} $out/bin/marker \
      --add-flags $out/share/marker/bin/marker \
      --set MARKER_HOME $out/share/marker \
      --run 'export MARKER_DATA_HOME="''${MARKER_DATA_HOME:-''${XDG_DATA_HOME:-$HOME/.local/share}/marker}"; mkdir -p "$MARKER_DATA_HOME"'
    runHook postInstall
  '';

  meta = {
    description = "Bookmark and fuzzy-search terminal commands";
    homepage = "https://github.com/4Gettt25/marker";
    license = lib.licenses.mit;
    mainProgram = "marker";
  };
} 