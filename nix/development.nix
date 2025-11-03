{ inputs, ... }:

let
  inherit (inputs) nixpkgs;
in {
  perSystem = { system, pkgs-dev, lib, ... }: {
    _module.args.pkgs-dev = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  };
}
