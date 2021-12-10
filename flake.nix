{
  description = "reflex-host";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        overlays = [ ];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowBroken = false;
        };
        project = returnShellEnv:
          pkgs.haskellPackages.developPackage {
            inherit returnShellEnv;
            name = "reflex-host";
            root = ./.;
            withHoogle = true;
            source-overrides = { };
            modifier = drv:
              pkgs.haskell.lib.addBuildTools drv (with pkgs; [
                # Specify your build/dev dependencies here.
                cabal-install
                cabal2nix
                haskellPackages.stan
                hlint
                haskell-language-server
                nixpkgs-fmt
                treefmt
                ormolu
                stack
              ]);
          };
      in {
        # Used by `nix build` & `nix run` (prod exe)
        defaultPackage = project false;

        # Used by `nix develop` (dev shell)
        devShell = project true;
      });
}
