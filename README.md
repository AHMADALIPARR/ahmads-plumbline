# Ahmad's Plumbline

**Technical abstract.**
Ahmads-Plumbline assembles a dense committed-choice parallel-logic runtime, a symbolic quantum circuit DSL that emits OpenQASM 3.0, and distance-3/5 quantum error-correction circuit templates (Steane [[7,1,3]], rotated Surface-17 [[9,1,3]], and color-code variants). The logic runtime is a fixed-size arena of 64-bit tagged words with bit-mask suspension and ready queues. Liquid Haskell modules encode two refinement properties. Quipper modules construct a two-qubit CNOT Bell pair and a simplified coherent-demon cycle.

**Dual license.** SNAPKITTY OPAQUE SOURCE LICENSE v1.0 **or** GNU Affero General Public License v3.0. See [LICENSE](LICENSE).

See the local workspace README for the complete architectural reference with all 34 required sections, file inventory, theorems, and diagrams.

### Dense ready-mask wave

Rule: at time $t$, slot $i$ is marked if bit $((i+t)\bmod 16)$ is set; character density follows a sine envelope.

```text
  dense ready-mask  (16 slots, sine envelope)
  t\i 0123456789012345
 0  *........%%%#+:.
 1  ........#%%#+-.
 2  .......#%%%*=: .
 3  ......*%%%*=: ..
 4  .....*%%%#+-....
 5  ....+#%%#*-.....
 6  ...+#%%%*=:.....
 7  ..=*%%%#+-......
 8  .-+#%%#+-.......
 9  -+#%%%*=........
10  =*%%%#+........%
11  *#%%#+........%%
12  #%%%*........%%%
13  %%%*........#%%#
  ready bits travel left-to-right; density ~ sin
  rule: bit((i+t) mod 16) and sine envelope
```
