# Ahmad's Plumbline

**Technical abstract.**
Ahmads-Plumbline is a multi-language research repository that assembles a dense, committed-choice parallel-logic runtime, a symbolic quantum circuit DSL with OpenQASM 3.0 emitters, and several distance-3/5 quantum error-correction circuit templates (Steane [[7,1,3]], rotated Surface-17 [[9,1,3]], and color-code variants).

**Dual license.** SNAPKITTY OPAQUE SOURCE LICENSE v1.0 **or** GNU Affero General Public License v3.0.

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

See the local README for the full architectural reference.
