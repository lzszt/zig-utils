(final: prev: {
  nixwhich = prev.stdenv.mkDerivation {
    name = "nixwhich";
    version = "0.0.1";
    src = ../src/nixwhich.zig;
    buildInputs = [ prev.zig ];
    unpackPhase = ''
      cp $src main.zig
    '';
    buildPhase = ''
      zig build-exe -O ReleaseSafe -target x86_64-native main.zig
    '';
    installPhase = ''
      mkdir -p $out/bin
      mv main $out/bin/nixwhich
    '';
  };
})
