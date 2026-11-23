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

## QEC resource counts

| Variant | \([[n,k,d]]\) | Data / logical | 256 logical data | Ancillas |
|---------|-------------|----------------|------------------|----------|
| Steane | [[7,1,3]] | 7 | 1792 | 6 |
| Surface-17 | [[9,1,3]] | 9 | 2304 | 8 |
| Color 6.6.6 \(d=3\) | [[7,1,3]] | 7 | 1792 | (flag) |
| Color 4.8.8 \(d=5\) | [[17,1,5]] | 17 | 4352 | (flag) |

## FFI contracts

| Origin | Destination | Symbol | Representation | Ownership |
|--------|-------------|--------|----------------|-----------|
| Haskell DenseMorph | C dense_parlog.c | dense_alloc_var | Word32 index | C static arena |
| Haskell DenseMorph | C dense_parlog.c | dense_spawn | Word32, Ptr Word32 | C static arena |
| Haskell DenseMorph | C dense_parlog.c | dense_bind | Word32, Word32 | C static arena |
| Haskell DenseMorph | C dense_parlog.c | dense_next_ready | IO Int | C static masks |
| Curry DenseFFI | Haskell External_DenseFFI | cDenseAllocVar | KiCS2 C_IO | Same C arena |
| Haskell LinearSGML | C boyer_moore.c | bm_search_raw | Ptr Word8 | Linear via LinBuf |

## Theorem index

| Name | Location | Kind | Statement |
|------|----------|------|-----------|
| theorem_cnot_entangle | src/Liquid/CNOTTheorem.hs | refinement | Bell state yields concurrence 1.0 |
| netIsNegativeTwo | src/Liquid/WorkBudget.hs | refinement | Net work equals -2 k_B T ln 2 |
| theorem_push_pop | ats/linear_proofs.dats | linear | Push-then-pop restores length |
| checkThreshold | src/QuantumDSL.hs | runtime guard | p < p_th implies logical error estimate |
| dense_steane_decode | cbits/dense_parlog.c | decoder | 6-bit syndrome to (err_x, err_z) |

## Layout

```
ahmads-plumbline/
├── app/Main.hs                 Cabal executable entry
├── ats/                        ATS affine and linear stacks
├── cbits/                      C: dense arena, raw GC, Boyer-Moore
├── docs/svg/                   wormhole-geometry.svg, qubit-entanglement.svg
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
- ASCII generator: `docs/art/ready_mask_wave.py` (rule stated above).
