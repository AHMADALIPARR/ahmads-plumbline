#!/usr/bin/env python3
"""
Deterministic ASCII art for ahmads-plumbline.
Rule: A 16-slot ready-mask wave. At time t, slot i is marked if
bit ((i + t) mod 16) is set in a rotating mask whose density
follows a sine envelope. Characters come from a fixed ramp.
"""

import math
import argparse

RAMP = " .:-=+*#%@"

def generate(width=72, rows=18, seed=7):
    phase = (seed % 16) * 0.4
    canvas = [[" " for _ in range(width)] for _ in range(rows)]

    def put(r, c, s):
        if 0 <= r < rows and 0 <= c < width:
            for i, ch in enumerate(s):
                if c + i < width:
                    canvas[r][c + i] = ch

    put(0, 2, "dense ready-mask  (16 slots, sine envelope)")
    put(1, 2, "t\\i " + "".join(f"{i%10}" for i in range(16)))

    for t in range(rows - 4):
        row = t + 2
        put(row, 0, f"{t:2d} ")
        for i in range(16):
            bit = ((i + t + seed) % 16) < 8
            env = 0.5 + 0.5 * math.sin(0.35 * t + 0.5 * i + phase)
            if bit:
                idx = int(env * (len(RAMP) - 1))
                ch = RAMP[idx]
            else:
                ch = "."
            put(row, 4 + i, ch)

    put(rows - 2, 2, "ready bits travel left-to-right; density ~ sin")
    put(rows - 1, 2, "rule: bit((i+t) mod 16) and sine envelope")

    lines = ["".join(row).rstrip() for row in canvas]
    for line in lines:
        assert len(line) <= width, f"line too long: {len(line)}"
    return "\n".join(lines)

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--width", type=int, default=72)
    p.add_argument("--rows", type=int, default=18)
    p.add_argument("--seed", type=int, default=7)
    args = p.parse_args()
    print(generate(args.width, args.rows, args.seed))
