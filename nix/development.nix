{ inputs, ... }:

let
  inherit (inputs) self nixpkgs;
in {
  flake.overlays.dev = final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (py-final: py-prev: {
        rustbpe = py-final.callPackage ../rustbpe/nix/default.nix {};
      })
    ];
  };
  
  perSystem = { system, pkgs-dev, lib, ... }: {
    _module.args.pkgs-dev = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        cudaSupport = true;
        cudaForwardCompat = true;
        cudaCapabilities = [ "7.5" "8.6" "8.9" "12.0" ];
      };
      overlays = [
        self.overlays.dev
      ];
    };

    devShells.default = pkgs-dev.mkShell rec {
      name = "nanochat";

      packages = with pkgs-dev; [
        (python3.withPackages (p: with p; [
          datasets
          fastapi
          files-to-prompt
          psutil
          regex
          rustbpe
          tiktoken
          tokenizers
          torch
          uvicorn
          wandb
          click
        ]))
      ];
    };

    packages = {
      rustbpe = pkgs-dev.python3Packages.rustbpe;
    };
  };
}
