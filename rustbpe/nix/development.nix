{ inputs, ... }:

let
  inherit (inputs) self nixpkgs crane advisory-db;
in {
  perSystem = { system, pkgs-dev, lib, ... }: let
    craneLib = crane.mkLib pkgs-dev;

    src = craneLib.cleanCargoSource ../.;
    
    commonArgs = {
      inherit src;
      strictDeps = true;
      buildInputs = [
        # Add additional build inputs here
      ] ++ lib.optionals pkgs-dev.stdenv.isDarwin [
        pkgs-dev.libiconv
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    
  in {
    checks = {
      rustbpe-clippy = craneLib.cargoClippy (commonArgs // { inherit cargoArtifacts; });

      rustbpe-doc = craneLib.cargoDoc (commonArgs // {
        inherit cargoArtifacts;
        env.RUSTDOCFLAGS = "--deny warnings";
      });

      rustbpe-fmt = craneLib.cargoFmt {
        inherit src;
      };

      rustbpe-tool-fmt = craneLib.taploFmt {
        src = lib.sources.sourceFilesBySuffices src [ ".toml" ];
      };

      rustbpe-deny = craneLib.cargoDeny {
        inherit src;
      };

      rustbpe-nextest = craneLib.cargoNextest (commonArgs // {
        inherit cargoArtifacts;
        partitions = 1;
        partitionType = "count";
        cargoNextestPartitionsExtraArgs = "--no-tests=pass";
      });
    };

    devShells.rustbpe = let
      pythonEnv = pkgs-dev.python3.withPackages (ps: with ps; [
        numpy
      ]);
    in craneLib.devShell {
      checks = self.checks."${system}";
      packages = with pkgs-dev; [
        pythonEnv
        maturin
      ];
    };
  };
}
