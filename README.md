# Ahmad's Plumbline — Demon's Hole Traversable Wormhole Transfer

**SnapKitty Research Lab** · Bel esprit D'accord Trust  
Researchers: Ahmad Ali Parr, Jessica Westerhoff

Dual-licensed under the **SNAPKITTY OPAQUE SOURCE LICENSE v1.0** and **GNU Affero General Public License v3.0**.

See [LICENSE](LICENSE) and [LICENSE-AGPL-3.0.txt](LICENSE-AGPL-3.0.txt).

## 1. Circuit Model

\( U_{DH} \in U(2^{2N}) \) acts on \( \mathcal{H}_D \otimes \mathcal{H}_{sh} \cong (\mathbb{C}^2)^{\otimes N} \otimes (\mathbb{C}^2)^{\otimes N} \).

## Additional Components

- `src/Parlog/parlog.dtd` — SGML DTD for Parlog programs (validated abstract syntax).
- `cbits/raw_gc.{h,c}` — Raw C mark-sweep GC for Parlog term heap (FFI-friendly, independent of GHC RTS).
- `nix/flake.nix` — Nix flake wrapping the Cabal build with `callCabal2nix` and a dev shell including `opensp` for DTD validation.
- Racket remains the preferred host for the interpreter; POPLOG/Franz are legacy compatibility only.

**License**: Dual — Snapkitty Opaque Source License v1.0 **OR** AGPLv3.  
Commercial use requires separate written authorization under the Opaque terms.  
Contact: A.parr@belespritdaccord.uk
