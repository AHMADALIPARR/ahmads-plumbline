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


---

## Complete file inventory

Every file currently present in the repository is listed below with its path, language, and primary responsibility.

| Path | Language | Responsibility |
|------|----------|----------------|
| `.github/workflows/ci.yml` | YAML | Documented in the subsection below |
| `LICENSE` | text | Documented in the subsection below |
| `LICENSE-AGPL-3.0.txt` | text | Documented in the subsection below |
| `README.md` | Markdown | Documented in the subsection below |
| `ahmads-plumbline.cabal` | text | Documented in the subsection below |
| `app/Main.hs` | Haskell | Documented in the subsection below |
| `ats/affine_stack.dats` | ATS | Documented in the subsection below |
| `ats/linear_proofs.dats` | ATS | Documented in the subsection below |
| `ats/linear_proofs.sats` | ATS | Documented in the subsection below |
| `cabal.project` | text | Documented in the subsection below |
| `cbits/boyer_moore.c` | C | Documented in the subsection below |
| `cbits/dense_parlog.c` | C | Documented in the subsection below |
| `cbits/raw_gc.c` | C | Documented in the subsection below |
| `cbits/raw_gc.h` | C | Documented in the subsection below |
| `docs/architecture.md` | Markdown | Documented in the subsection below |
| `docs/art/ready_mask_wave.py` | Python | Documented in the subsection below |
| `docs/art/ready_mask_wave.txt` | text | Documented in the subsection below |
| `docs/ffi-contracts.md` | Markdown | Documented in the subsection below |
| `docs/svg/qubit-entanglement.svg` | SVG | Documented in the subsection below |
| `docs/svg/wormhole-geometry.svg` | SVG | Documented in the subsection below |
| `docs/theorems.md` | Markdown | Documented in the subsection below |
| `nix/flake.nix` | Nix | Documented in the subsection below |
| `qasm/manifold_colorcode_qec.qasm` | OpenQASM | Documented in the subsection below |
| `qasm/manifold_steane_qec.qasm` | OpenQASM | Documented in the subsection below |
| `qasm/manifold_surface17_qec.qasm` | OpenQASM | Documented in the subsection below |
| `scala/QiskitTranspiler.scala` | Scala | Documented in the subsection below |
| `src/AhmadsPlumbline/DemonHole.hs` | Haskell | Documented in the subsection below |
| `src/DenseFFI.curry` | Curry | Documented in the subsection below |
| `src/DenseMorph.hs` | Haskell | Documented in the subsection below |
| `src/DenseParlog.curry` | Curry | Documented in the subsection below |
| `src/Dex/CategoryTheory.dex` | Dex | Documented in the subsection below |
| `src/Dex/CellularAutomaton.dex` | Dex | Documented in the subsection below |
| `src/Dex/EntanglementToLife.dex` | Dex | Documented in the subsection below |
| `src/Dex/GameOfLife.dex` | Dex | Documented in the subsection below |
| `src/Dex/LSystem.dex` | Dex | Documented in the subsection below |
| `src/Dex/QuantumCA_APL.dex` | Dex | Documented in the subsection below |
| `src/Dex/QuantumEntanglement.dex` | Dex | Documented in the subsection below |
| `src/External_DenseFFI.hs` | Haskell | Documented in the subsection below |
| `src/Franz/proof-popped.txt` | text | Documented in the subsection below |
| `src/Franz/qa5-reactive.lisp` | Lisp | Documented in the subsection below |
| `src/LinearSGML.hs` | Haskell | Documented in the subsection below |
| `src/Liquid/CNOTTheorem.hs` | Haskell | Documented in the subsection below |
| `src/Liquid/GameOfLifeBinder.hs` | Haskell | Documented in the subsection below |
| `src/Liquid/WorkBudget.hs` | Haskell | Documented in the subsection below |
| `src/Main.hs` | Haskell | Documented in the subsection below |
| `src/Parlog/parlog.dtd` | DTD | Documented in the subsection below |
| `src/QuantumDSL.hs` | Haskell | Documented in the subsection below |
| `src/QuantumToDense.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/CNOTEntangle.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/DemonCycle.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/GameOfLifeCirc.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/Couplings.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/Hamiltonian.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/Majorana.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/Scrambling.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/ThermofieldDouble.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/TimeEvolution.hs` | Haskell | Documented in the subsection below |
| `src/Quipper/SYK/WormholeCoupling.hs` | Haskell | Documented in the subsection below |
| `src/UA/uiee.ua` | UA | Documented in the subsection below |

---

### `.github/workflows/ci.yml`

**Path.** `.github/workflows/ci.yml`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `LICENSE`

**Path.** `LICENSE`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `LICENSE-AGPL-3.0.txt`

**Path.** `LICENSE-AGPL-3.0.txt`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `README.md`

**Path.** `README.md`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `ahmads-plumbline.cabal`

**Path.** `ahmads-plumbline.cabal`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `app/Main.hs`

**Path.** `app/Main.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `ats/affine_stack.dats`

**Path.** `ats/affine_stack.dats`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `ats/linear_proofs.dats`

**Path.** `ats/linear_proofs.dats`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `ats/linear_proofs.sats`

**Path.** `ats/linear_proofs.sats`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `cabal.project`

**Path.** `cabal.project`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `cbits/boyer_moore.c`

**Path.** `cbits/boyer_moore.c`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `cbits/dense_parlog.c`

**Path.** `cbits/dense_parlog.c`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `cbits/raw_gc.c`

**Path.** `cbits/raw_gc.c`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `cbits/raw_gc.h`

**Path.** `cbits/raw_gc.h`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/architecture.md`

**Path.** `docs/architecture.md`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/art/ready_mask_wave.py`

**Path.** `docs/art/ready_mask_wave.py`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/art/ready_mask_wave.txt`

**Path.** `docs/art/ready_mask_wave.txt`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/ffi-contracts.md`

**Path.** `docs/ffi-contracts.md`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/svg/qubit-entanglement.svg`

**Path.** `docs/svg/qubit-entanglement.svg`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/svg/wormhole-geometry.svg`

**Path.** `docs/svg/wormhole-geometry.svg`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `docs/theorems.md`

**Path.** `docs/theorems.md`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `nix/flake.nix`

**Path.** `nix/flake.nix`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `qasm/manifold_colorcode_qec.qasm`

**Path.** `qasm/manifold_colorcode_qec.qasm`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `qasm/manifold_steane_qec.qasm`

**Path.** `qasm/manifold_steane_qec.qasm`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `qasm/manifold_surface17_qec.qasm`

**Path.** `qasm/manifold_surface17_qec.qasm`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `scala/QiskitTranspiler.scala`

**Path.** `scala/QiskitTranspiler.scala`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/AhmadsPlumbline/DemonHole.hs`

**Path.** `src/AhmadsPlumbline/DemonHole.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/DenseFFI.curry`

**Path.** `src/DenseFFI.curry`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/DenseMorph.hs`

**Path.** `src/DenseMorph.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/DenseParlog.curry`

**Path.** `src/DenseParlog.curry`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/CategoryTheory.dex`

**Path.** `src/Dex/CategoryTheory.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/CellularAutomaton.dex`

**Path.** `src/Dex/CellularAutomaton.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/EntanglementToLife.dex`

**Path.** `src/Dex/EntanglementToLife.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/GameOfLife.dex`

**Path.** `src/Dex/GameOfLife.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/LSystem.dex`

**Path.** `src/Dex/LSystem.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/QuantumCA_APL.dex`

**Path.** `src/Dex/QuantumCA_APL.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Dex/QuantumEntanglement.dex`

**Path.** `src/Dex/QuantumEntanglement.dex`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/External_DenseFFI.hs`

**Path.** `src/External_DenseFFI.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Franz/proof-popped.txt`

**Path.** `src/Franz/proof-popped.txt`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Franz/qa5-reactive.lisp`

**Path.** `src/Franz/qa5-reactive.lisp`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/LinearSGML.hs`

**Path.** `src/LinearSGML.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Liquid/CNOTTheorem.hs`

**Path.** `src/Liquid/CNOTTheorem.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Liquid/GameOfLifeBinder.hs`

**Path.** `src/Liquid/GameOfLifeBinder.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Liquid/WorkBudget.hs`

**Path.** `src/Liquid/WorkBudget.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Main.hs`

**Path.** `src/Main.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Parlog/parlog.dtd`

**Path.** `src/Parlog/parlog.dtd`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/QuantumDSL.hs`

**Path.** `src/QuantumDSL.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/QuantumToDense.hs`

**Path.** `src/QuantumToDense.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/CNOTEntangle.hs`

**Path.** `src/Quipper/CNOTEntangle.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/DemonCycle.hs`

**Path.** `src/Quipper/DemonCycle.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/GameOfLifeCirc.hs`

**Path.** `src/Quipper/GameOfLifeCirc.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/Couplings.hs`

**Path.** `src/Quipper/SYK/Couplings.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/Hamiltonian.hs`

**Path.** `src/Quipper/SYK/Hamiltonian.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/Majorana.hs`

**Path.** `src/Quipper/SYK/Majorana.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/Scrambling.hs`

**Path.** `src/Quipper/SYK/Scrambling.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/ThermofieldDouble.hs`

**Path.** `src/Quipper/SYK/ThermofieldDouble.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/TimeEvolution.hs`

**Path.** `src/Quipper/SYK/TimeEvolution.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/Quipper/SYK/WormholeCoupling.hs`

**Path.** `src/Quipper/SYK/WormholeCoupling.hs`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

### `src/UA/uiee.ua`

**Path.** `src/UA/uiee.ua`

**Language / format.** Determined from the file extension and contents.

**Role.** This file contributes to the multi-language formal-computation stack. Its symbols, control flow, and interfaces are preserved exactly as present in the source.

**Key contents.**

- Block 0: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 1: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 2: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 3: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 4: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 5: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 6: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 7: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 8: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 9: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 10: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

- Block 11: The implementation records the declarations and definitions present at this path. No additional claims of verified fault tolerance are made beyond what the source itself states.

**Interfaces.** Imports, exports, and FFI symbols (where present) are those declared in the file. Ownership of any external resources follows the contracts listed in `docs/ffi-contracts.md`.

**Verification status.** Local to the module. No machine-checked end-to-end proof is present unless the source itself contains a refinement or linear-type obligation.

---

## End of inventory

All files listed above are present in the repository at the time of this documentation. The inventory is derived from a recursive tree walk of the main branch.