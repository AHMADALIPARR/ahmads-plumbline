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

{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

module Quipper.SYK.Majorana where

import Quipper

-- | A Majorana operator γ_i is represented by a Pauli string on a qubit register.
--   The standard embedding maps γ_{2k-1} = Z_1 ... Z_{k-1} X_k and
--   γ_{2k} = Z_1 ... Z_{k-1} Y_k.
data Majorana = Majorana
  { majoranaIndex :: Int
  , support       :: [Pauli]
  }

data Pauli = I | X | Y | Z deriving (Eq, Show)

-- | Anticommutation: {γ_i, γ_j} = 2 δ_{ij}.
--   This is enforced by the Pauli embedding above.
anticommutes :: Majorana -> Majorana -> Bool
anticommutes m1 m2 = majoranaIndex m1 /= majoranaIndex m2

-- | Apply a Majorana operator (as a Pauli string) to a qubit register.
applyMajorana :: Majorana -> [Qubit] -> Circ ()
applyMajorana m qs = sequence_ (zipWith applyPauli (support m) qs)
  where
    applyPauli X q = gate_X q
    applyPauli Y q = gate_Y q
    applyPauli Z q = gate_Z q
    applyPauli I _ = return ()
