# Ahmad's Plumbline

Dense committed-choice parallel-logic runtime, symbolic quantum-circuit DSL with OpenQASM 3.0 emitters, Liquid Haskell refinements, and Quipper circuit construction (including an SYK/wormhole module).

**Maintainers.** Ahmad Ali Parr, Jessica Westerhoff, SnapKitty Research Lab.  
**Copyright.** 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.  
**Dual license.** SNAPKITTY OPAQUE SOURCE LICENSE v1.0 or GNU Affero General Public License v3.0. See [LICENSE](LICENSE) and [LICENSE-AGPL-3.0.txt](LICENSE-AGPL-3.0.txt).

## Layout

```
ahmads-plumbline/
├── app/Main.hs                 Cabal executable entry
├── ats/                        ATS affine and linear stacks
├── cbits/                      C: dense arena, raw GC, Boyer-Moore
├── docs/                       architecture, theorems, FFI contracts, SVGs
├── nix/flake.nix
├── qasm/                       Steane, Surface-17, color-code circuits
├── scala/QiskitTranspiler.scala
└── src/
    ├── AhmadsPlumbline/DemonHole.hs
    ├── DenseMorph.hs, QuantumDSL.hs, QuantumToDense.hs
    ├── Franz/                  Lisp reactive sketch
    ├── Liquid/                 WorkBudget, CNOTTheorem
    ├── Parlog/parlog.dtd
    ├── Quipper/                CNOTEntangle, DemonCycle, SYK/
    └── UA/uiee.ua
```

## Subsystems

| Subsystem | Location | Role |
|-----------|----------|------|
| Dense PARLOG | `cbits/dense_parlog.c` | 64-slot arena, bit-mask suspension and ready queues |
| Raw GC | `cbits/raw_gc.{h,c}` | Independent mark-sweep term heap |
| Quantum DSL | `src/QuantumDSL.hs` | AST, UA lowerer, OpenQASM / Steane / Surface-17 / color emitters |
| Dense morph | `src/DenseMorph.hs` | Linear morph of goals into dense slots |
| Liquid | `src/Liquid/` | Landauer work-budget and Bell-state concurrence refinements |
| Quipper | `src/Quipper/`, `src/AhmadsPlumbline/` | Circuit construction, including DemonHole and SYK |
| ATS | `ats/` | Indexed affine and linear stacks (not linked into Cabal) |
| QASM | `qasm/` | 1792-qubit Steane, 2304-qubit Surface-17, color-code gate libraries |

## Entry points

- Cabal executable: `app/Main.hs` (depends on the library).
- Library demo: `src/Main.hs` (not the package entry point).

## Build

```bash
cabal build all
cabal run ahmads-plumbline
```

Optional: `nix develop` (flake includes `ats2`).

## Notes

- No machine-checked fault-tolerance proof is present. Refinements and linear types are local.
- No Python. The Scala file is a pure-Scala OpenQASM header processor.
- See `docs/architecture.md`, `docs/theorems.md`, and `docs/ffi-contracts.md` for subsystem boundaries, named refinements, and FFI contracts.
