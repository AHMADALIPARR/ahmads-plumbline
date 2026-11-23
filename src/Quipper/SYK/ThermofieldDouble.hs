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

module Quipper.SYK.ThermofieldDouble where

import Quipper

-- | Prepare a thermofield-double state |TFD(β)> between two SYK systems
--   by entangling corresponding modes with a controlled-phase of strength β.
prepareTFD :: Double -> [Qubit] -> [Qubit] -> Circ ()
prepareTFD beta left right =
  sequence_ [ do
      gate_H qL
      controlled_phase (beta / 2) qL qR
    | (qL, qR) <- zip left right ]
