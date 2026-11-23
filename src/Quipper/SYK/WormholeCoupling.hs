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

module Quipper.SYK.WormholeCoupling where

import Quipper
import Quipper.SYK.ThermofieldDouble
import Quipper.SYK.TimeEvolution
import Quipper.SYK.Hamiltonian

-- | Couple two SYK systems with a double-trace interaction μ Σ_i γ_i^L γ_i^R
--   used in theoretical traversable-wormhole protocols.
coupleWormhole :: Double -> [Qubit] -> [Qubit] -> Circ ()
coupleWormhole mu left right =
  sequence_ [ controlled_phase mu qL qR | (qL, qR) <- zip left right ]

-- | Full traversable-wormhole protocol:
--   1. Prepare TFD
--   2. Evolve both sides under SYK
--   3. Apply double-trace coupling
--   4. Evolve again
traversableProtocol :: SYKHamiltonian -> Double -> Double -> [Qubit] -> [Qubit] -> Circ ()
traversableProtocol ham t mu left right = do
  prepareTFD 1.0 left right
  timeEvolve ham t left
  timeEvolve ham t right
  coupleWormhole mu left right
  timeEvolve ham t left
  timeEvolve ham t right
