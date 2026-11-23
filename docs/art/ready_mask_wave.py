#!/usr/bin/env python3
"""
Dense ready-mask wave.
Rule: at time t, slot i is marked if bit ((i + t) mod 16) is set;
character density follows a sine envelope.
"""
import math
import argparse

RAMP = " .:-=+*#%@"

def put(grid, r, c, ch):
    if 0 <= r < len(grid) and 0 <= c < len(grid[0]):
        grid[r][c] = ch

def generate(width=72, rows=24, seed=42):
    grid = [[" "] * width for _ in range(rows)]
    title = "dense ready-mask  (16 slots, sine envelope)"
    for i, ch in enumerate(title[:width]):
        put(grid, 0, i, ch)
    put(grid, 1, 0, "t")
    put(grid, 1, 2, "\\")
    put(grid, 1, 3, "i")
    for col in range(16):
        put(grid, 1, 5 + col, str(col % 10))
    for t in range(rows - 3):
        put(grid, t + 2, 0, str(t % 10))
        for i in range(16):
            phase = (i + t) / 16.0 * 2 * math.pi
            density = (math.sin(phase) + 1) / 2
            idx = int(density * (len(RAMP) - 1))
            # Traveling bit: mark when (i + t) % 16 == 0
            if (i + t) % 16 == 0:
                ch = "*"
            else:
                ch = RAMP[idx]
            put(grid, t + 2, 5 + i, ch)
    caption = "ready bits travel left-to-right; density ~ sin"
    for i, ch in enumerate(caption[:width]):
        put(grid, rows - 2, i, ch)
    rule = "rule: bit((i+t) mod 16) and sine envelope"
    for i, ch in enumerate(rule[:width]):
        put(grid, rows - 1, i, ch)
    lines = ["".join(row).rstrip() for row in grid]
    for line in lines:
        assert len(line) <= width, f"line exceeds width: {len(line)}"
    return "\n".join(lines)

if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--width", type=int, default=72)
    p.add_argument("--rows", type=int, default=24)
    p.add_argument("--seed", type=int, default=42)
    args = p.parse_args()
    print(generate(args.width, args.rows, args.seed))
