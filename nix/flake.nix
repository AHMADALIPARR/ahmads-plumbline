========================================================================
; SOVEREIGN LEVIATHAN NODE LICENSE
; License-ID: SL-AGPL3-001 | Covenant-Version: 1.0
; SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
; Copyright (C) 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.
; ========================================================================
;
; This file is a covered work under the GNU Affero General Public License,
; version 3, together with the Sovereign Leviathan additional terms.
;
; Hark, though this node be but a spark,
; Its covenant endureth through the dark.
;
; Ignorantia juris non excusat.
; ========================================================================

{
  description = "SGML + Parlog interpreter with raw C GC";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hpkgs = pkgs.haskellPackages;
        pkg = hpkgs.callCabal2nix "parlog-sgml" ./. { };
      in {
        packages.default = pkg;

        devShells.default = hpkgs.shellFor {
          packages = _: [ pkg ];
          nativeBuildInputs = with pkgs; [
            cabal-install
            haskell-language-server
            gcc
            gdb
            ats2
            opensp # optional: onsgmls for strict SGML DTD validation
          ];
        };
      });
}
