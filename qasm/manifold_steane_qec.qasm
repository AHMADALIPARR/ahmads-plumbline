// Circuit: QSharp_ManifoldGreedyStep_SteaneQEC
// Physical qubit count: 1792 data (256 logical × 7) + 6 reusable ancillas
OPENQASM 3.0;
include "stdgates.inc";

// 256 logical qubits * 7 physical qubits = 1792 data qubits
qubit[1792] q;
qubit[6] anc;       // Reusable 3 Z-ancillas + 3 X-ancillas
bit[6] syn;
input float[64] theta;

// Encode |0>_L on a 7-qubit Steane block
gate steane_encode d[7] {
  h d[0]; h d[1]; h d[3];
  cx d[0], d[2]; cx d[0], d[4]; cx d[0], d[6];
  cx d[1], d[2]; cx d[1], d[5]; cx d[1], d[6];
  cx d[3], d[4]; cx d[3], d[5]; cx d[3], d[6];
}

// Logical RX(angle) via weight-3 X_L = X_0 X_1 X_2
gate rx_logical(angle) d[7] {
  cx d[0], d[1];
  cx d[0], d[2];
  rx(angle) d[0];
  cx d[0], d[2];
  cx d[0], d[1];
}

// Transversal logical CNOT
gate cx_logical ctrl[7], tgt[7] {
  for int j in [0:6] {
    cx ctrl[j], tgt[j];
  }
}

// Steane syndrome extraction + single-qubit recovery
def steane_qec(qubit[7] d, qubit[6] a) {
  reset a;
  // Z-stabilizers (detect X errors)
  cx d[3], a[0]; cx d[4], a[0]; cx d[5], a[0]; cx d[6], a[0];
  cx d[1], a[1]; cx d[2], a[1]; cx d[5], a[1]; cx d[6], a[1];
  cx d[0], a[2]; cx d[2], a[2]; cx d[4], a[2]; cx d[6], a[2];

  // X-stabilizers (detect Z errors)
  h a[3]; h a[4]; h a[5];
  cx a[3], d[3]; cx a[3], d[4]; cx a[3], d[5]; cx a[3], d[6];
  cx a[4], d[1]; cx a[4], d[2]; cx a[4], d[5]; cx a[4], d[6];
  cx a[5], d[0]; cx a[5], d[2]; cx a[5], d[4]; cx a[5], d[6];
  h a[3]; h a[4]; h a[5];

  syn = measure a;
  int err_x = (int(syn[0]) << 2) | (int(syn[1]) << 1) | int(syn[2]);
  int err_z = (int(syn[3]) << 2) | (int(syn[4]) << 1) | int(syn[5]);
  if (err_x > 0) { x d[err_x - 1]; }
  if (err_z > 0) { z d[err_z - 1]; }
}

// 1. Encode all 256 logical manifold qubits
for int i in [0:255] {
  steane_encode q[7*i : 7*i + 6];
}

// 2. Fault-tolerant ManifoldGreedyStep with QEC rounds
for int i in [0:255] {
  rx_logical(theta * float(i + 1)) q[7*i : 7*i + 6];
  if (i > 0) {
    cx_logical q[7*(i - 1) : 7*(i - 1) + 6], q[7*i : 7*i + 6];
  }
  steane_qec(q[7*i : 7*i + 6], anc);
}
