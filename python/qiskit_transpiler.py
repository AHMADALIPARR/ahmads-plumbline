========================================================================
; SOVEREIGN LEVIATHAN NODE LICENSE
; License-ID: SL-AGPL3-001 | Covenant-Version: 1.0
; SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001
; Copyright (C) 2026 SnapKittyWest. Ahmad Ali Parr, Bel Esprit D'Accord Irrevocable Trust.
; ========================================================================
;
; This file is a covered work under the GNU Affero General Public License,
; version 3, together with the Sovereign Leviathan additional terms.
;
; Hark, though this node be but a spark,
; Its covenant endureth through the dark.
;
; Ignorantia juris non excusat.
; ========================================================================

"""
Qiskit transpiler bridge for Ahmad's Plumbline circuits.

Loads OpenQASM 3.0 emitted by QuantumDSL.toOpenQASM3,
transpiles to a chosen basis, and writes the optimized circuit.
"""

from qiskit import QuantumCircuit, transpile
from qiskit.qasm3 import loads as qasm3_loads
from pathlib import Path
import argparse

def transpile_qasm(qasm_path: str, basis: list[str] | None = None, optimization_level: int = 2) -> QuantumCircuit:
    src = Path(qasm_path).read_text()
    circ = qasm3_loads(src)
    basis = basis or ["u", "cx"]
    return transpile(circ, basis_gates=basis, optimization_level=optimization_level)

def main():
    p = argparse.ArgumentParser(description="Transpile Plumbline OpenQASM via Qiskit")
    p.add_argument("qasm", help="Path to .qasm file produced by QuantumDSL")
    p.add_argument("-o", "--output", help="Write transpiled QASM 2/3")
    p.add_argument("--level", type=int, default=2, help="Optimization level 0-3")
    args = p.parse_args()

    tc = transpile_qasm(args.qasm, optimization_level=args.level)
    print(tc)
    if args.output:
        Path(args.output).write_text(tc.qasm())
        print(f"Wrote {args.output}")

if __name__ == "__main__":
    main()
