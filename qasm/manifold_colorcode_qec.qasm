// Circuit: QSharp_ManifoldGreedyStep_ColorCode
OPENQASM 3.0;
include "stdgates.inc";

// --- Variant A: 6.6.6 Color Code [[7,1,3]] (256 * 7 = 1792 data qubits) ---
// Transversal Clifford set: H, S, CNOT
gate h_color666 d[7]   { for int j in [0:6] { h d[j]; } }
gate s_color666 d[7]   { for int j in [0:6] { s d[j]; } }
gate cx_color666 c[7], t[7] { for int j in [0:6] { cx c[j], t[j]; } }

// Fault-tolerant flagged weight-4 plaquette measurement (prevents hook errors)
def measure_flagged_plaquette_z(qubit[4] face, qubit syn_q, qubit flag_q) {
  reset syn_q;
  reset flag_q;
  h flag_q;
  cx face[0], syn_q;
  cx syn_q, flag_q;          // open flag
  cx face[1], syn_q;
  cx face[2], syn_q;
  cx syn_q, flag_q;          // close flag
  cx face[3], syn_q;
  h flag_q;
  bit s = measure syn_q;
  bit f = measure flag_q;    // f == 1 => hook error occurred; trigger d=3/d=5 lookup
}

// --- Variant B: 4.8.8 Color Code [[17,1,5]] (distance 5, corrects 2 errors) ---
// 17 data qubits: 3 octagons (weight-8) + 5 squares (weight-4) for both X and Z
// Logical RX(angle) decomposed via transversal H + Z_L parity gadget:
// H_L * RZ_L(angle) * H_L
gate rx_color488(angle) d[17] {
  for int j in [0:16] { h d[j]; }
  // Weight-5 logical Z_L along the top-to-bottom boundary {0,1,2,3,4}
  cx d[0], d[1]; cx d[0], d[2]; cx d[0], d[3]; cx d[0], d[4];
  rz(angle) d[0];
  cx d[0], d[4]; cx d[0], d[3]; cx d[0], d[2]; cx d[0], d[1];
  for int j in [0:16] { h d[j]; }
}

gate cx_color488 ctrl[17], tgt[17] {
  for int j in [0:16] { cx ctrl[j], tgt[j]; }
}
