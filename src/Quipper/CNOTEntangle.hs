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

module Quipper.CNOTEntangle where

import Quipper

-- | CNOT circuit drawn from Ahmad's Plumbline DSL and UA Entangle
-- UA defines CNOT matrix and Entangle = matrix-vector multiplication
-- producing entanglement (CalcDeg concurrence).

-- | Two-qubit CNOT (control, target)
cnot :: Qubit -> Qubit -> Circ (Qubit, Qubit)
cnot control target = do
  controlled_not control target
  return (control, target)

-- | Prepare |+> on control, |0> on target, then CNOT → Bell state
-- Matches UA InitState + Entangle pipeline idea
bellFromPlus :: Circ (Qubit, Qubit)
bellFromPlus = do
  c <- qinit False
  t <- qinit False
  hadamard c
  (c', t') <- cnot c t
  return (c', t')

-- | UA-style gated collapse placeholder (measure if concurrence high)
-- In Quipper we just measure the Bell pair
measureBell :: Circ Bit
measureBell = do
  (c, t) <- bellFromPlus
  cBit <- measure c
  tBit <- measure t
  -- Both bits should be equal for the Φ+ Bell state
  return cBit
