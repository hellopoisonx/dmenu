{
  description = "dmenu";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:hellopoisonx/nixvim";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.easyOverlay
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =
        {
          config,
          self',
          inputs',
          pkgs,
          system,
          final,
          ...
        }:
        let
          lastModifiedDate = self'.lastModifiedDate or self'.lastModified or "19700101";
          version = builtins.substring 0 8 lastModifiedDate;
        in
        {
          overlayAttrs = { };
          packages.dmenu = final.stdenv.mkDerivation {
            pname = "dmenu";
            inherit version;

            src = ./.;
            buildInputs = with final; [
              xorg.libX11
              xorg.libXinerama
              xorg.libXft
            ];
            nativeBuildInputs = with final; [
              pkg-config
              makeWrapper
              inputs'.nixvim.c-cpp
              bear
            ];
            preConfigure = ''
              sed -i "s@/usr/local@$out@" config.mk
              sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
              sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path
              makeFlagsArray+=(
                CC="$CC"
                INCS="`$PKG_CONFIG --cflags fontconfig x11 xft xinerama`"
                LIBS="`$PKG_CONFIG --libs   fontconfig x11 xft xinerama`"
              )
            '';
            buildPhase = ''
              make clean
              make all
            '';
            installPhase = ''
              make clean install
            '';
          };
          packages.default = self'.packages.dmenu;
        };
      flake = {
      };
    };
}
