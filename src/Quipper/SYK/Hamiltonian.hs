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

module Quipper.SYK.Hamiltonian where

import Quipper
import Quipper.SYK.Majorana
import Quipper.SYK.Couplings

-- | The q=4 SYK Hamiltonian:
--   H = (1/(4!)) Σ_{i<j<k<l} J_{ijkl} γ_i γ_j γ_k γ_l
data SYKHamiltonian = SYKHamiltonian
  { majoranas :: [Majorana]
  , couplings :: [Coupling]
  }

-- | Build the Hamiltonian from a number of Majoranas and a seed.
buildHamiltonian :: Int -> Int -> SYKHamiltonian
buildHamiltonian n seed =
  let ms = [ Majorana i (replicate n I) | i <- [0..n-1] ]  -- simplified support
      cs = generateCouplings seed n
  in SYKHamiltonian ms cs
