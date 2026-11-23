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

module Quipper.DemonCycle where

import Quipper

-- | Prepare a coherent state on n qubits (Hadamard on each)
prepareCoherent :: Int -> Circ [Qubit]
prepareCoherent n = do
  qs <- qinit (replicate n False)
  mapUnary hadamard qs
  return qs

-- | Placeholder unitary erase into battery register
eraseToBattery :: [Qubit] -> [Qubit] -> Circ ()
eraseToBattery sys bat =
  sequence_ [ controlled_not (s, b) | (s, b) <- zip sys bat ]

-- | Full coherent demon cycle sketch
demonCycle :: Int -> Circ ([Qubit], [Qubit])
demonCycle n = do
  sys <- prepareCoherent n
  bat <- qinit (replicate n False)
  eraseToBattery sys bat
  return (sys, bat)
