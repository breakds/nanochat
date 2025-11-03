{
  description = "The best ChatGPT that $100 can buy";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    crane.url = "github:ipetkov/crane";
    advisory-db = {
      url = "github:rustsec/advisory-db";
      flake = false;
    };
  };

  outputs = { self, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./nix/development.nix
        ./rustbpe/nix/development.nix
      ];

      # perSystem = { system, config, pkgs-dev, ... }: {
      #   formatter = pkgs-dev.nixfmt-classic;
      # };
    };
}
