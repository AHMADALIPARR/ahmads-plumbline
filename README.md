# Ahmad's Plumbline — Demon's Hole Traversable Wormhole Transfer

**SnapKitty Research Lab** · Bel esprit D'accord Trust  
Researchers: Ahmad Ali Parr, Jessica Westerhoff

Dual-licensed under the **SNAPKITTY OPAQUE SOURCE LICENSE v1.0** and **GNU Affero General Public License v3.0**.

See [LICENSE](LICENSE) and [LICENSE-AGPL-3.0.txt](LICENSE-AGPL-3.0.txt).

## 1. Circuit Model

\( U_{DH} \in U(2^{2N}) \) acts on \( \mathcal{H}_D \otimes \mathcal{H}_{sh} \cong (\mathbb{C}^2)^{\otimes N} \otimes (\mathbb{C}^2)^{\otimes N} \).

```
R_D ───────┤                                         ├─────── |0>^N
 (Full)    │  U_DH = exp(-i H_GJW t_scr)            │       (Reset)
           │  [Gao-Jafferis-Wall Double-Trace]       │
R_sh ──────┤                                         ├─────── ρ_sh
 (Ground)  └────────────────────────────────────────┘    (Excited)
```

Time-evolution operator:

- \( H_D, H_{sh} \): boundary scramblers — k-local SYK Hamiltonians
- \( t_{scr} = (\beta / 2\pi) \ln N \) — thermal scrambling time
- \( H_{int} \): GJW double-trace coupling

Nielsen Geodesic Metric on \( SU(2^{2N}) \):

- \( g_{II} = 1 \) for 1- and 2-qubit gates
- \( g_{II} = \Omega^{2(k-2)} \gg 1 \) for k-body operators (\( k > 2 \))

## 2. Gate Decomposition and Scaling

- **Step 1 — Scrambling Layer**: \( O(N \ln N) \) gates per full scramble
- **Step 2 — GJW Wormhole Channel**: \( O(N^2 \ln N / \varepsilon) \) Trotterized 2-qubit Pauli rotations

**Theorem 1 (Complexity Lower Bound for \( U_{DH} \))**:  
\( C(U_{DH}) = \Omega(N^2 \log^2(N / \varepsilon)) \)

## 3. Complexity-Theoretic Landauer's Principle

Standard Landauer: \( \Delta Q_{thermal} = k_B T \ln 2 \) per erased bit.  
Demon's Hole: \( \Delta Q_{thermal} = 0 \) (globally unitary erasure).

Susskind CA conjecture — generating circuit complexity \( C \) requires:  
\( E \cdot t \geq \hbar \cdot C(U_{DH}) \) → \( E_{min} = \hbar C(U_{DH}) / t_{scr} = O(N^2 \log^2(N/\varepsilon) \cdot k_B T) \)

**Resolution**: Demon substitutes Thermodynamic Heat Dissipation with Quantum Computational Work.  
\( \Delta S_{total} = \Delta S_{thermo} + (k_B / \hbar) \Delta C \)

## 4. Quipper Implementation

See [src/AhmadsPlumbline/DemonHole.hs](src/AhmadsPlumbline/DemonHole.hs) for the recursive black wormhole entropy DSL.

## 5. Gate Count Recurrence

\[
T(N) = 2 \cdot T(N/2) + S(N) + O(N)
\]

where \( S(N) = O(N \ln N) \) (scramble_register complexity).

By the Master Theorem: \( T(N) = O(N \log^2 N) \)

## Conclusion

The Demon does not bypass Landauer's bound. It substitutes thermodynamic heat dissipation with quantum computational work. The total generalized entropic cost includes a complexity penalty:  
\( \Delta S_{total} = \Delta S_{thermo} + k_B \Delta C / \hbar \)

---

**License**: Dual — Snapkitty Opaque Source License v1.0 **OR** AGPLv3.  
Commercial use requires separate written authorization under the Opaque terms.  
Contact: A.parr@belespritdaccord.uk
