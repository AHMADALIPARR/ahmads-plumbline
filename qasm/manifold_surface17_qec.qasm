// Circuit: QSharp_ManifoldGreedyStep_Surface17
OPENQASM 3.0;
include "stdgates.inc";

// 256 logical qubits * 9 data qubits = 2304 data qubits (+ 8 reusable ancillas)
qubit[2304] q;
qubit[8] anc;
bit[8] syn;
input float[64] theta;

// Prepare |0>_L on a 3x3 rotated surface patch:
// reset to |0>^9, then project X-stabilizers via one QEC cycle
gate surface17_init d[9] {
  reset d;
}

// Logical RX(angle) via weight-3 X_L = X_0 X_3 X_6
gate rx_surface17(angle) d[9] {
  cx d[0], d[3];
  cx d[0], d[6];
  rx(angle) d[0];
  cx d[0], d[6];
  cx d[0], d[3];
}

// Transversal logical CNOT across the 3x3 data patch
gate cx_surface17 ctrl[9], tgt[9] {
  for int j in [0:8] {
    cx ctrl[j], tgt[j];
  }
}

// Surface-17 syndrome extraction (4 Z-plaquettes + 4 X-plaquettes)
def surface17_qec(qubit[9] d, qubit[8] a) {
  reset a;

  // Z-stabilizers (detect X errors)
  cx d[0], a[0]; cx d[1], a[0]; cx d[3], a[0]; cx d[4], a[0]; // {0,1,3,4}
  cx d[4], a[1]; cx d[5], a[1]; cx d[7], a[1]; cx d[8], a[1]; // {4,5,7,8}
  cx d[3], a[2]; cx d[6], a[2];                               // {3,6}
  cx d[2], a[3]; cx d[5], a[3];                               // {2,5}

  // X-stabilizers (detect Z errors)
  h a[4]; h a[5]; h a[6]; h a[7];
  cx a[4], d[1]; cx a[4], d[2]; cx a[4], d[4]; cx a[4], d[5]; // {1,2,4,5}
  cx a[5], d[3]; cx a[5], d[4]; cx a[5], d[6]; cx a[5], d[7]; // {3,4,6,7}
  cx a[6], d[0]; cx a[6], d[1];                               // {0,1}
  cx a[7], d[7]; cx a[7], d[8];                               // {7,8}
  h a[4]; h a[5]; h a[6]; h a[7];

  syn = measure a;

  // Lookup-table single-qubit recovery for weight-1 X/Z syndromes
  if (syn[0] && syn[2] && !syn[1] && !syn[3]) { x d[3]; }
  if (syn[0] && !syn[1] && !syn[2] && !syn[3]) { x d[0]; }
  if (syn[1] && syn[3] && !syn[0] && !syn[2]) { x d[5]; }
  if (syn[0] && syn[1] && !syn[2] && !syn[3]) { x d[4]; }

  if (syn[4] && syn[6] && !syn[5] && !syn[7]) { z d[1]; }
  if (syn[4] && syn[5] && !syn[6] && !syn[7]) { z d[4]; }
  if (syn[5] && syn[7] && !syn[4] && !syn[6]) { z d[7]; }
}

// 1. Initialize all 256 logical patches
for int i in [0:255] {
  surface17_init q[9*i : 9*i + 8];
  surface17_qec(q[9*i : 9*i + 8], anc);
}

// 2. Fault-tolerant ManifoldGreedyStep with Surface-17 QEC
for int i in [0:255] {
  rx_surface17(theta * float(i + 1)) q[9*i : 9*i + 8];
  if (i > 0) {
    cx_surface17 q[9*(i - 1) : 9*(i - 1) + 8], q[9*i : 9*i + 8];
  }
  surface17_qec(q[9*i : 9*i + 8], anc);
}
