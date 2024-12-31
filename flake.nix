{
  description = "dmenu";

  # Nixpkgs / NixOS version to use.
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixvim.url = "github:hellopoisonx/nixvim";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixvim,
      ...
    }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );
    in
    {

      # A Nixpkgs overlay.
      overlay = final: prev: {
        dmenu = final.stdenv.mkDerivation {
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
            nixvim.packages.${final.system}.c-cpp
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

      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) dmenu;
      });
      defaultPackage = forAllSystems (system: self.packages.${system}.dmenu);
    };
}
