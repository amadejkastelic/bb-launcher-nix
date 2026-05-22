{
  pkgs ? import <nixpkgs> { },
}:

rec {
  shadps4 = pkgs.callPackage ./shadps4 { };
  bb-launcher = pkgs.callPackage ./bb-launcher { inherit shadps4; };
}
