{ inputs, ... }:

let
  inherit (inputs) self nixpkgs crane advisory-db;
in {
  perSystem = { system, pkgs-rustbpe, lib, ... }: let
    craneLib = crane.mkLib pkgs-rustbpe;

    src = craneLib.cleanCargoSource ../.;
    
    commonArgs = {
      inherit src;
      strictDeps = true;
      buildInputs = [
        # Add additional build inputs here
      ] ++ lib.optionals pkgs-rustbpe.stdenv.isDarwin [
        pkgs-rustbpe.libiconv
      ];
    };

    cargoArtifacts = craneLib.buildDepsOnly commonArgs;
    
  in {
    _module.args.pkgs-rustbpe = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    
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
      pythonEnv = pkgs-rustbpe.python3.withPackages (ps: with ps; [
        numpy
      ]);
    in craneLib.devShell {
      checks = self.checks."${system}";
      packages = with pkgs-rustbpe; [
        pythonEnv
        maturin
      ];
    };
  };
}
