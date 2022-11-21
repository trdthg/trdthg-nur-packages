{ stdenv }:

stdenv.mkDerivation rec {
  name = "example-package-1-${version}";
  version = "1.0";
  src = ./.;
  buildPhase = "echo echo Hello World > example";
  installPhase = "install -Dm755 example $out";
}
