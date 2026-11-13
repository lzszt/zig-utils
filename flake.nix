{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    {
      nixpkgs,
      ...
    }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.zig
          pkgs.zls
        ];
      };

      packages.x86_64-linux = {
        nixwhich = pkgs.stdenv.mkDerivation {
          name = "nixwhich";
          version = "0.0.1";
          src = ./src/nixwhich.zig;
          buildInputs = [ pkgs.zig ];
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
      };
    };
}
