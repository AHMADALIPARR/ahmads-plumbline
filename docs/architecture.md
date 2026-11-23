# Architecture

## Subsystems

| Subsystem | Language | Location | Role |
|-----------|----------|----------|------|
| Dense PARLOG | C | `cbits/dense_parlog.c` | Bit-mask scheduling arena |
| Raw GC | C | `cbits/raw_gc.{h,c}` | Mark-sweep term heap |
| Boyer-Moore | C | `cbits/boyer_moore.c` | Raw byte search |
| Quantum DSL | Haskell | `src/QuantumDSL.hs` | Circuit AST and OpenQASM emitters |
| Dense morph | Haskell | `src/DenseMorph.hs` | Linear morph into dense slots |
| Liquid refinements | Haskell | `src/Liquid/` | Work budget and concurrence |
| Quipper circuits | Haskell/Quipper | `src/Quipper/`, `src/AhmadsPlumbline/` | Circuit construction |
| SYK model | Haskell/Quipper | `src/Quipper/SYK/` | Majorana SYK and wormhole coupling |
| ATS linear | ATS | `ats/` | Affine and linear stacks |
| Curry FFI | Curry | `src/DenseFFI.curry` | External declarations |
| Lisp reactive | Lisp | `src/Franz/` | Legacy reactive sketch |
| Scala transpiler | Scala | `scala/` | Pure-Scala QASM processor |
| QASM circuits | OpenQASM 3.0 | `qasm/` | Steane, Surface-17, color code |
| UA source | UA | `src/UA/uiee.ua` | Source pipeline |
| Parlog DTD | SGML | `src/Parlog/parlog.dtd` | Document structure |

## Entry points

- Cabal executable: `app/Main.hs` (depends on library)
- Library demo: `src/Main.hs` (not the package entry point)
