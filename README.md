# Ahmad's Plumbline

Dense committed-choice parallel-logic runtime, symbolic quantum-circuit DSL with OpenQASM 3.0 emitters, Liquid Haskell refinements, and Quipper circuit construction (including an SYK/wormhole module).

**Maintainers.** Ahmad Ali Parr, Jessica Westerhoff, SnapKitty Research Lab.  
**Copyright.** 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.  
**Dual license.** SNAPKITTY OPAQUE SOURCE LICENSE v1.0 or GNU Affero General Public License v3.0. See [LICENSE](LICENSE) and [LICENSE-AGPL-3.0.txt](LICENSE-AGPL-3.0.txt).

![Wormhole spatial geometry](docs/svg/wormhole-geometry.svg)

## Dense ready-mask wave

Rule: at time \( t \), slot \( i \) is marked if bit \( ((i + t) \bmod 16) \) is set; character density follows a sine envelope.

```text
dense ready-mask  (16 slots, sine envelope)
t \i 0123456789012345
0    **#%@%#*=:.   .:
1    *#%@%#*=:.   .:*
2    #%@%#*=:.   .:**
3    %@%#*=:.   .:**#
4    @%#*=:.   .:**#%
5    %#*=:.   .:**#%@
6    #*=:.   .:**#%@%
7    *=:.   .:**#%@%#
8    =:.   .:**#%@%#*
9    :.   .:**#%@%#*=
0    .   .:**#%@%#*=:
1       .:**#%@%#*=:.
2      .:**#%@%#*=:.
3     .:**#%@%#*=:.
4    .:**#%@%#*=:.
5    :**#%@%#*=:.   .
6    **#%@%#*=:.   .:
7    *#%@%#*=:.   .:*
8    #%@%#*=:.   .:**
9    %@%#*=:.   .:**#
ready bits travel left-to-right; density ~ sin
rule: bit((i+t) mod 16) and sine envelope

```

![Qubit entanglement circuit](docs/svg/qubit-entanglement.svg)

## File inventory

| Path | Language | Role |
|------|----------|------|
| `.github/workflows/ci.yml` | YAML | Haskell build and C compilation jobs |
| `LICENSE` | text | Dual license text |
| `LICENSE-AGPL-3.0.txt` | text | AGPLv3 text |
| `ahmads-plumbline.cabal` | Cabal | Package definition; library and executable |
| `cabal.project` | Cabal | Project configuration |
| `app/Main.hs` | Haskell | Cabal executable entry point |
| `ats/affine_stack.dats` | ATS | Indexed affine stack |
| `ats/linear_proofs.dats` | ATS | Linear stack, arena, goal |
| `ats/linear_proofs.sats` | ATS | Static signatures |
| `cbits/boyer_moore.c` | C | Boyer–Moore on raw bytes |
| `cbits/dense_parlog.c` | C | Arena, masks, Steane decoder |
| `cbits/raw_gc.c` | C | Mark-sweep heap |
| `cbits/raw_gc.h` | C | Term type and accessors |
| `docs/architecture.md` | Markdown | Subsystem boundaries |
| `docs/art/ready_mask_wave.py` | Python | ASCII generator |
| `docs/art/ready_mask_wave.txt` | text | Generated art |
| `docs/ffi-contracts.md` | Markdown | FFI matrix |
| `docs/svg/qubit-entanglement.svg` | SVG | Bell-state circuit diagram |
| `docs/svg/wormhole-geometry.svg` | SVG | Morris–Thorne embedding |
| `docs/theorems.md` | Markdown | Named refinements and lemmas |
| `nix/flake.nix` | Nix | Dev shell and package |
| `qasm/manifold_colorcode_qec.qasm` | OpenQASM | Color-code gate library |
| `qasm/manifold_steane_qec.qasm` | OpenQASM | 1792-qubit Steane manifold |
| `qasm/manifold_surface17_qec.qasm` | OpenQASM | 2304-qubit Surface-17 manifold |
| `scala/QiskitTranspiler.scala` | Scala | Pure-Scala QASM header processor |
| `src/AhmadsPlumbline/DemonHole.hs` | Haskell/Quipper | Demon’s Hole \(U_{DH}\) circuit |
| `src/DenseFFI.curry` | Curry | External declarations |
| `src/DenseMorph.hs` | Haskell | Linear morph into dense slots |
| `src/DenseParlog.curry` | Curry | Dense-word sketch |
| `src/Dex/CategoryTheory.dex` | Dex | Compose, id, tensor |
| `src/Dex/CellularAutomaton.dex` | Dex | Elementary CA |
| `src/Dex/EntanglementToLife.dex` | Dex | Measurement to Life grid |
| `src/Dex/GameOfLife.dex` | Dex | Life front-end |
| `src/Dex/LSystem.dex` | Dex | L-system rewrites |
| `src/Dex/QuantumCA_APL.dex` | Dex | APL-style quantum CA |
| `src/Dex/QuantumEntanglement.dex` | Dex | Bell, GHZ, CNOT, concurrence |
| `src/External_DenseFFI.hs` | Haskell | KiCS2 glue |
| `src/Franz/proof-popped.txt` | text | Recorded QA5 output |
| `src/Franz/qa5-reactive.lisp` | Lisp | Reactive sketch |
| `src/LinearSGML.hs` | Haskell | LinearTypes Boyer–Moore wrapper |
| `src/Liquid/CNOTTheorem.hs` | Liquid Haskell | Bell-state concurrence refinement |
| `src/Liquid/GameOfLifeBinder.hs` | Liquid Haskell | Refined Life rules and Dex interface |
| `src/Liquid/WorkBudget.hs` | Liquid Haskell | Landauer identity refinement |
| `src/Main.hs` | Haskell | Library-level demo |
| `src/Parlog/parlog.dtd` | DTD | PARLOG document structure |
| `src/QuantumDSL.hs` | Haskell | DSL, lowerer, emitters, QEC variants |
| `src/QuantumToDense.hs` | Haskell | QGate to dense goals |
| `src/Quipper/CNOTEntangle.hs` | Haskell/Quipper | Bell-pair circuit |
| `src/Quipper/DemonCycle.hs` | Haskell/Quipper | Coherent-demon sketch |
| `src/Quipper/GameOfLifeCirc.hs` | Haskell/Quipper | Life circuit skeleton |
| `src/Quipper/SYK/Couplings.hs` | Haskell/Quipper | Seeded Gaussian couplings |
| `src/Quipper/SYK/Hamiltonian.hs` | Haskell/Quipper | q=4 SYK Hamiltonian |
| `src/Quipper/SYK/Majorana.hs` | Haskell/Quipper | Majorana algebra |
| `src/Quipper/SYK/Scrambling.hs` | Haskell/Quipper | Operator growth |
| `src/Quipper/SYK/ThermofieldDouble.hs` | Haskell/Quipper | TFD preparation |
| `src/Quipper/SYK/TimeEvolution.hs` | Haskell/Quipper | Trotterized evolution |
| `src/Quipper/SYK/WormholeCoupling.hs` | Haskell/Quipper | Double-trace coupling |
| `src/UA/uiee.ua` | UA | Source pipeline |

## Entry points

- Cabal executable: `app/Main.hs` (depends on the library).
- Library demo: `src/Main.hs` (not the package entry point).

## Build

```bash
cabal build all
cabal run ahmads-plumbline
```

Optional: `nix develop`.

## Notes

- No machine-checked fault-tolerance proof is present. Refinements and linear types are local.
- No Python in the build. The Scala file is a pure-Scala OpenQASM header processor.
- See `docs/architecture.md`, `docs/theorems.md`, and `docs/ffi-contracts.md`.
