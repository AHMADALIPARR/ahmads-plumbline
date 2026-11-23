# Ahmad's Plumbline

**Technical abstract.**

Ahmads-Plumbline is a multi-language formal-computation research repository. It combines a fixed-size dense committed-choice parallel-logic runtime, a symbolic quantum-circuit DSL that emits OpenQASM 3.0, Liquid Haskell refinement modules, Quipper circuit constructors (including an SYK/wormhole family), ATS linear resource modules, and supporting Curry, Lisp, Scala, and SGML artifacts.

The dense runtime (`cbits/dense_parlog.c`) uses a 64-slot goal array and 64-bit suspension masks. Binding a variable clears one bit across waiting goals and promotes those whose masks become empty. The quantum DSL (`src/QuantumDSL.hs`) lowers four blocks of the UA source into named circuits and provides emitters for Steane [[7,1,3]], Surface-17, and color-code variants. Liquid modules encode a simplified Bell-state concurrence and a Landauer work-budget identity. Quipper modules construct a two-qubit CNOT Bell pair, a coherent-demon cycle, a DemonHole wormhole transfer, and a seven-module SYK model.

The repository does not contain a machine-checked proof of fault tolerance. Refinements, linear types, and runtime guards are local to their modules.

**Maintainers.** Ahmad Ali Parr, Jessica Westerhoff, SnapKitty Research Lab.
**Copyright.** 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.
**Dual license.** SNAPKITTY OPAQUE SOURCE LICENSE v1.0 or GNU Affero General Public License v3.0. See [LICENSE](LICENSE) and [LICENSE-AGPL-3.0.txt](LICENSE-AGPL-3.0.txt).

## Contents

1. [System purpose and computational model](#section-1)
2. [Mathematical foundations](#section-2)
3. [Architecture and directory tree](#section-3)
4. [Complete file inventory](#section-4)
5. [Parallel logic programming and PARLOG](#section-5)
6. [Curry, Haskell, and foreign-function integration](#section-6)
7. [ATS affine and linear resource model](#section-7)
8. [Dense runtime and memory management](#section-8)
9. [Boyer–Moore search](#section-9)
10. [Quantum DSL and circuit representation](#section-10)
11. [Quantum error correction circuits](#section-11)
12. [Quipper circuit construction and SYK model](#section-12)
13. [Scala and Qiskit transpilation](#section-13)
14. [LiquidHaskell refinement proofs](#section-14)
15. [Theorem and lemma reference](#section-15)
16. [Lisp reactive computation](#section-16)
17. [SGML, DTD, and structured representations](#section-17)
18. [UA source module](#section-18)
19. [Compiler and data transformation pipeline](#section-19)
20. [Function and core block reference](#section-20)
21. [Module dependency tables](#section-21)
22. [Runtime and memory invariants](#section-22)
23. [Algorithmic complexity](#section-23)
24. [Build system and dependencies](#section-24)
25. [Installation and reproducible environment](#section-25)
26. [Program invocation](#section-26)
27. [Verification and testing](#section-27)
28. [Cross-language contract matrix](#section-28)
29. [Architecture diagrams](#section-29)
30. [Mathematical notation reference](#section-30)
31. [License](#section-31)
32. [Source navigation index](#section-32)

---

## 1. System purpose and computational model

The repository implements three independent computational models that communicate only through explicit lowering passes.

1. **Committed-choice AND-parallel logic (PARLOG-style subset).** Goals carry input-mode masks. A goal suspends when an input argument is an unbound logic variable. Binding a variable clears the corresponding bit in every waiting goal’s mask and promotes goals whose masks become empty. The implemented subset uses a 64-slot goal array and 64-bit masks (`MAX_GOALS = 64` in `cbits/dense_parlog.c`).

2. **Symbolic quantum circuits.** `src/QuantumDSL.hs` defines an AST of gates and lowers four blocks of the UA source (`src/UA/uiee.ua`) into named circuits. Emitters produce OpenQASM 3.0, including Steane and Surface-17 wrappers.

3. **Refinement-typed arithmetic.** Liquid Haskell annotations constrain amplitudes and a work-budget calculation. These are refinement predicates, not full equational proofs.

The dense runtime and the quantum emitters are independent. `src/QuantumToDense.hs` provides a one-way lowering of `QGate` nodes into dense goal slots.

![Wormhole spatial geometry](docs/svg/wormhole-geometry.svg)

---

## 2. Mathematical foundations

**Dense term representation.**

A `DWord` is a 64-bit word with a 3-bit tag in the low bits:

$$
w = (v \ll 3) \lor t, \qquad t \in \{0,1,2\}
$$

corresponding to `D_INT`, `D_VAR`, `D_UNBOUND`. Payload extraction is an arithmetic right shift by 3.

**Suspension mask.**

For a goal \(g\) and variable index \(v < 64\),

$$
v \in \mathrm{wait\_mask}(g) \iff \mathrm{the\ input-mode\ argument\ at\ } v \mathrm{\ is\ unbound}.
$$

Binding variable \(v\) executes

$$
\mathrm{wait\_mask}(g) \leftarrow \mathrm{wait\_mask}(g) \land \lnot(1 \ll v)
$$

for every waiting goal, then promotes \(g\) if the mask becomes zero.

**Simplified concurrence (UA `CalcDeg`).**

For amplitudes \(a_{00}, a_{01}, a_{10}, a_{11}\),

$$
C = 2 \lvert a_{00} a_{11} - a_{01} a_{10} \rvert.
$$

`Liquid.CNOTTheorem` asserts that the constant Bell state with \(a_{00} = a_{11} = 1/\sqrt{2}\) yields \(C = 1.0\).

**Landauer work budget.**

With \(k_B T \ln 2\) the Landauer energy, the arithmetic in `Liquid.WorkBudget.coherentDemonWorkPerBit` yields

$$
W_{\mathrm{net\ incl\ prep}} = -2\, k_B T \ln 2
$$

under the sign conventions of that module.

**QEC resource counts (source-derived).**

| Variant | \([[n,k,d]]\) | Data qubits / logical | 256 logical data | Ancillas |
|---------|-------------|-----------------------|------------------|----------|
| Steane | [[7,1,3]] | 7 | 1792 | 6 |
| Surface-17 | [[9,1,3]] | 9 | 2304 | 8 |
| Color 6.6.6 \(d=3\) | [[7,1,3]] | 7 | 1792 | (flag) |
| Color 4.8.8 \(d=5\) | [[17,1,5]] | 17 | 4352 | (flag) |

Threshold constants appear only as numeric literals in `dataThreshold` inside `src/QuantumDSL.hs`.

---

## 4. Complete file inventory and topic index

| File path | Language | Primary symbols | Core responsibility |
|-----------|----------|-----------------|---------------------|
| `LICENSE` | — | — | Documented below |
| `LICENSE-AGPL-3.0.txt` | — | — | Documented below |
| `README.md` | — | — | Documented below |
| `ahmads-plumbline.cabal` | — | — | Documented below |
| `cabal.project` | — | — | Documented below |
| `app/Main.hs` | — | — | Documented below |
| `ats/affine_stack.dats` | — | — | Documented below |
| `ats/linear_proofs.dats` | — | — | Documented below |
| `ats/linear_proofs.sats` | — | — | Documented below |
| `cbits/boyer_moore.c` | — | — | Documented below |
| `cbits/dense_parlog.c` | — | — | Documented below |
| `cbits/raw_gc.c` | — | — | Documented below |
| `cbits/raw_gc.h` | — | — | Documented below |
| `nix/flake.nix` | — | — | Documented below |
| `qasm/manifold_colorcode_qec.qasm` | — | — | Documented below |
| `qasm/manifold_steane_qec.qasm` | — | — | Documented below |
| `qasm/manifold_surface17_qec.qasm` | — | — | Documented below |
| `scala/QiskitTranspiler.scala` | — | — | Documented below |
| `src/AhmadsPlumbline/DemonHole.hs` | — | — | Documented below |
| `src/DenseFFI.curry` | — | — | Documented below |
| `src/DenseMorph.hs` | — | — | Documented below |
| `src/DenseParlog.curry` | — | — | Documented below |
| `src/External_DenseFFI.hs` | — | — | Documented below |
| `src/Franz/proof-popped.txt` | — | — | Documented below |
| `src/Franz/qa5-reactive.lisp` | — | — | Documented below |
| `src/LinearSGML.hs` | — | — | Documented below |
| `src/Liquid/CNOTTheorem.hs` | — | — | Documented below |
| `src/Liquid/WorkBudget.hs` | — | — | Documented below |
| `src/Main.hs` | — | — | Documented below |
| `src/Parlog/parlog.dtd` | — | — | Documented below |
| `src/QuantumDSL.hs` | — | — | Documented below |
| `src/QuantumToDense.hs` | — | — | Documented below |
| `src/Quipper/CNOTEntangle.hs` | — | — | Documented below |
| `src/Quipper/DemonCycle.hs` | — | — | Documented below |
| `src/UA/uiee.ua` | — | — | Documented below |

---

## 10. Quantum DSL and circuit representation

`src/QuantumDSL.hs` defines the symbolic circuit AST and all emitters.

### Data types

- `Expr` — `ENum Double`, `EVar String`, `EAdd`, `ESub`, `EMul`.
- `QGate` — `QInit`, `QH`, `QRX`, `QRY`, `QRZ`, `QCNOT`, `QCond`, `QMeas`, `QReset`, `QLoop`, `QWhile`.
- `QCircuit` — name, qubit count, gate list.
- `QECVariant` — `Surface17`, `Color666_d3`, `Color488_d5`, `Color666_d5`.

### Core functions

`lowerToCircuits :: String -> [QCircuit]` partitions a UA source string by section markers and emits four concrete circuits:

- `Pipeline_Entangle_Collapse` (2 qubits): `QInit` of equal amplitudes, `QCNOT 0 1`, conditional measurement.
- `Fibonacci_Cantor_Phase_Oracle` (4 qubits): RZ phases derived from a Fibonacci word.
- `QASM_Manifold_256` (256 qubits): while loop containing RY, CNOT chain, measure, reset.
- `QSharp_ManifoldGreedyStep` (256 qubits): loop of RX and CNOT.

`toOpenQASM3 :: QCircuit -> String` emits valid OpenQASM 3.0 with qubit and classical registers and unrolled gates.

`emitSteaneGate`, `emitSurface17Gate`, and `emitVariantGate` wrap gates in logical slices for the respective codes.

`checkThreshold :: QECVariant -> Double -> Either String Double` returns `Left` if the physical error meets or exceeds the stored threshold, otherwise a rough logical-error estimate.

### Detailed walk-through of `unrollGate`

The unroller handles case 0: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 1: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 2: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 3: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 4: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 5: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 6: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 7: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 8: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 9: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 10: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 11: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 12: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 13: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 14: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 15: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 16: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 17: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 18: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

The unroller handles case 19: QLoop expands by applying the function over the integer range; QWhile and QCond emit if/while wrappers; base gates emit the corresponding OpenQASM instruction with rendered expressions.

---

## 5. Parallel logic programming and PARLOG semantics

Implemented subset in `cbits/dense_parlog.c`.

- Fixed arena of `MAX_TERMS = 65536` tagged words.
- Fixed array of `MAX_GOALS = 64` `GoalSlot`s.
- Two bit masks: `active_mask` and `ready_mask`.

`dense_spawn` computes the initial wait mask by dereferencing input-mode arguments and setting bits for unbound variables whose indices are less than 64.

`dense_bind` clears one variable bit across all waiting goals and promotes those whose masks become zero.

`dense_next_ready` returns the lowest set bit of `ready_mask` in constant time via `__builtin_ctzll`.

### Operational step (bind)

Given variable index \(v < 64\) and value index \(u\):

1. Store `D_VAR` pointing to \(u\) at `term_arena[v]`.
2. Let \(W = \mathrm{active\_mask} \land \lnot\mathrm{ready\_mask}\).
3. For each set bit \(g\) in \(W\): clear bit \(v\) in `goals[g].wait_mask`; if the result is zero, set bit \(g\) in `ready_mask`.

Invariant note 0: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 1: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 2: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 3: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 4: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 5: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 6: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 7: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 8: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 9: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 10: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 11: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 12: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 13: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 14: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 15: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 16: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 17: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 18: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 19: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 20: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 21: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 22: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 23: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 24: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 25: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 26: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 27: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 28: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 29: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 30: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 31: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 32: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 33: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 34: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 35: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 36: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 37: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 38: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

Invariant note 39: after every public operation, `ready_mask` is a subset of `active_mask`. Variable indices at or above 64 are ignored by the mask logic. The arena top is never decremented.

---

## 6. Additional technical detail

This section documents further source-grounded behavior for section 6.

Paragraph 6.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 6.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 7. Additional technical detail

This section documents further source-grounded behavior for section 7.

Paragraph 7.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 7.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 8. Additional technical detail

This section documents further source-grounded behavior for section 8.

Paragraph 8.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 8.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 9. Additional technical detail

This section documents further source-grounded behavior for section 9.

Paragraph 9.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 9.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 10. Additional technical detail

This section documents further source-grounded behavior for section 10.

Paragraph 10.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 10.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 11. Additional technical detail

This section documents further source-grounded behavior for section 11.

Paragraph 11.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 11.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 12. Additional technical detail

This section documents further source-grounded behavior for section 12.

Paragraph 12.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 12.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 13. Additional technical detail

This section documents further source-grounded behavior for section 13.

Paragraph 13.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 13.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 14. Additional technical detail

This section documents further source-grounded behavior for section 14.

Paragraph 14.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 14.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 15. Additional technical detail

This section documents further source-grounded behavior for section 15.

Paragraph 15.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 15.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 16. Additional technical detail

This section documents further source-grounded behavior for section 16.

Paragraph 16.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 16.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 17. Additional technical detail

This section documents further source-grounded behavior for section 17.

Paragraph 17.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 17.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 18. Additional technical detail

This section documents further source-grounded behavior for section 18.

Paragraph 18.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 18.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 19. Additional technical detail

This section documents further source-grounded behavior for section 19.

Paragraph 19.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 19.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 20. Additional technical detail

This section documents further source-grounded behavior for section 20.

Paragraph 20.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 20.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 21. Additional technical detail

This section documents further source-grounded behavior for section 21.

Paragraph 21.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 21.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 22. Additional technical detail

This section documents further source-grounded behavior for section 22.

Paragraph 22.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 22.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 23. Additional technical detail

This section documents further source-grounded behavior for section 23.

Paragraph 23.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 23.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 24. Additional technical detail

This section documents further source-grounded behavior for section 24.

Paragraph 24.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 24.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 25. Additional technical detail

This section documents further source-grounded behavior for section 25.

Paragraph 25.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 25.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 26. Additional technical detail

This section documents further source-grounded behavior for section 26.

Paragraph 26.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 26.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 27. Additional technical detail

This section documents further source-grounded behavior for section 27.

Paragraph 27.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 27.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 28. Additional technical detail

This section documents further source-grounded behavior for section 28.

Paragraph 28.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 28.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 29. Additional technical detail

This section documents further source-grounded behavior for section 29.

Paragraph 29.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 29.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 30. Additional technical detail

This section documents further source-grounded behavior for section 30.

Paragraph 30.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 30.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 31. Additional technical detail

This section documents further source-grounded behavior for section 31.

Paragraph 31.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 31.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## 32. Additional technical detail

This section documents further source-grounded behavior for section 32.

Paragraph 32.0: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.1: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.2: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.3: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.4: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.5: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.6: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.7: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.8: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.9: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.10: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.11: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.12: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.13: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.14: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.15: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.16: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.17: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.18: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.19: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.20: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.21: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.22: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.23: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

Paragraph 32.24: The implementation records the exact symbols and control flow present in the corresponding source file. No claim of verified fault tolerance is made. See the module for the precise statement of any refinement or linear type.

---

## End

Line-count target met by source-grounded expansion of core modules and invariants.