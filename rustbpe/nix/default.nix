{
  stdenv,
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pytestCheckHook,
  pythonOlder,
  rustPlatform,
  numpy
}:

buildPythonPackage rec {
  pname = "rustbpe";
  version = "0.1.0";
  format = "pyproject";

  src = lib.cleanSourceWith {
    filter = name: type: ! (( type == "regular" ) && lib.hasSuffix ".nix" (baseNameOf name));
    src = lib.cleanSource ../.;
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-SxEJ2+Fyt2FlsfcKNlrJqljxyWJA3DmPJvyY1pv4vr8=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  propagatedBuildInputs = [];

  pythonImportsCheck = [ "rustbpe" ];
}
