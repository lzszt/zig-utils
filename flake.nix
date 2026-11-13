{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ (import ./nix/overlays.nix) ];
      };
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = [
          pkgs.zig
          pkgs.zls
        ];
      };

      packages.x86_64-linux = {
        nixwhich = pkgs.nixwhich;
      };
      overlays.default = import ./nix/overlays.nix;
      nixosModules.default = import ./nix/nixosModules.nix { inherit self; };
    };
}
