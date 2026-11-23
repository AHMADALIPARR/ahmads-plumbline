#!/usr/bin/env python3
"""Transpile OpenQASM 3.0 circuits from QuantumDSL.hs with Qiskit."""

import argparse
from pathlib import Path
from qiskit import transpile
from qiskit.qasm3 import loads as qasm3_loads, dumps as qasm3_dumps
from qiskit.transpiler import CouplingMap


def build_coupling_map(num_qubits: int, topology: str) -> CouplingMap:
    if topology == "line":
        return CouplingMap.from_line(num_qubits)
    if topology == "grid":
        cols = int(num_qubits ** 0.5)
        rows = (num_qubits + cols - 1) // cols
        return CouplingMap.from_grid(rows, cols)
    raise ValueError(f"Unknown topology: {topology}")


def transpile_qasm3(
    in_path: Path,
    out_path: Path,
    topology: str = "line",
    basis: list[str] | None = None,
    opt_level: int = 3,
    bind_theta: float | None = None,
) -> None:
    basis_gates = basis or ["rz", "sx", "x", "cx"]
    qc = qasm3_loads(in_path.read_text(encoding="utf-8"))

    if bind_theta is not None and qc.parameters:
        qc = qc.assign_parameters({p: bind_theta for p in qc.parameters})

    cmap = build_coupling_map(qc.num_qubits, topology)

    tqc = transpile(
        qc,
        basis_gates=basis_gates,
        coupling_map=cmap,
        layout_method="sabre",
        routing_method="sabre",
        optimization_level=opt_level,
    )

    print(f"Input  -> qubits={qc.num_qubits}, depth={qc.depth()}, ops={dict(qc.count_ops())}")
    print(f"Output -> qubits={tqc.num_qubits}, depth={tqc.depth()}, ops={dict(tqc.count_ops())}")

    out_path.write_text(qasm3_dumps(tqc), encoding="utf-8")
    print(f"Wrote transpiled OpenQASM 3.0 to {out_path}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("input", type=Path, help="Input .qasm (OpenQASM 3.0)")
    p.add_argument("-o", "--output", type=Path, default=Path("transpiled.qasm"))
    p.add_argument("--topology", choices=["line", "grid"], default="line")
    p.add_argument("--opt-level", type=int, choices=[0, 1, 2, 3], default=3)
    p.add_argument("--theta", type=float, default=None, help="Bind symbolic theta")
    args = p.parse_args()

    transpile_qasm3(
        args.input,
        args.output,
        topology=args.topology,
        opt_level=args.opt_level,
        bind_theta=args.theta,
    )
