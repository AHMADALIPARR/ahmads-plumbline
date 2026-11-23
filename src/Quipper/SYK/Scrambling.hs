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

module Quipper.SYK.Scrambling where

import Quipper
import Quipper.SYK.TimeEvolution
import Quipper.SYK.Hamiltonian

-- | Operator growth: evolve a local operator under the SYK Hamiltonian
--   and measure the growth of its support (out-of-time-order correlators).
scrambleOperator :: SYKHamiltonian -> Double -> Int -> [Qubit] -> Circ ()
scrambleOperator ham t site qs = do
  -- Insert a local X at the chosen site
  gate_X (qs !! site)
  -- Evolve
  timeEvolve ham t qs
  -- Measure support growth via Pauli weight proxy
  mapM_ gate_H qs
