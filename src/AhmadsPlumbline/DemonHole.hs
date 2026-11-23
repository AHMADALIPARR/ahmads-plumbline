{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE FlexibleContexts #-}

{-
  Ahmad's Plumbline — Demon's Hole Traversable Wormhole Transfer

  Copyright (C) 2026 Ahmad Ali Parr, Jessica Westerhoff, SnapKitty Research Lab
  Bel esprit D'accord Trust

  This work is dual-licensed under:
  - SNAPKITTY OPAQUE SOURCE LICENSE v1.0 (see LICENSE)
  - GNU Affero General Public License v3.0 (see LICENSE-AGPL-3.0.txt)

  You may choose either license. For commercial use beyond AGPL obligations,
  contact the Licensor for written authorization under the Opaque terms.

  SPDX-License-Identifier: LicenseRef-Sovereign-Leviathan-SL-AGPL3-001 OR AGPL-3.0-only
-}

module AhmadsPlumbline.DemonHole where

import Quipper
import Quipper.Libraries.Matrix
import Quipper.Libraries.Arith
import Control.Monad (forM_)

-- | Representation of the Holographic Screen Registers
data DemonState = DemonState {
    registerD  :: [Qubit],  -- ^ Boundary Demon Register R_D (Size N)
    registerSH :: [Qubit]   -- ^ Auxiliary Shadow Horizon R_sh (Size N)
}

-- | Topological Coupling Parameters
data WormholeParams = WormholeParams {
    couplingG :: Double,  -- ^ Double-trace coupling parameter (g > 0)
    betaTemp  :: Double,  -- ^ Inverse Hawking Temperature (beta)
    errorEps  :: Double   -- ^ Target precision epsilon
}

-- | Elementary 2-Qubit GJW Entangling Gate: Exp(-i * (g/N) * Z_d * Z_sh)
gjw_entangler :: Double -> Qubit -> Qubit -> Circ ()
gjw_entangler theta qD qSH = do
    qmultigate "CNOT" [qD, qSH]
    gate_RZ theta qSH
    qmultigate "CNOT" [qD, qSH]

-- | Recursive SYK Fast-Scrambler Circuit Generator
scramble_register :: [Qubit] -> Circ ()
scramble_register []       = return ()
scramble_register [_]      = return ()
scramble_register (q1:q2:qs) = do
    gate_H q1
    qmultigate "CNOT" [q1, q2]
    gate_T q2
    scramble_register (q2:qs)
    scramble_register (q1:qs)

-- | Recursive Wormhole Entropy Channel (The Demon's Action U_DH)
-- Base Case:  N=1 -> SWAP + GJW Coupling
-- Recursive:  Split, scramble sub-blocks, cross-couple
invoke_demon_hole_rec :: WormholeParams -> [Qubit] -> [Qubit] -> Circ ()
invoke_demon_hole_rec _ [] [] = return ()
invoke_demon_hole_rec params [qD] [qSH] = do
    let theta = couplingG params * betaTemp params
    gjw_entangler theta qD qSH
    swap qD qSH
invoke_demon_hole_rec params qD qSH = do
    let n      = length qD
        half   = n `div` 2
        (qD_left,  qD_right)  = splitAt half qD
        (qSH_left, qSH_right) = splitAt half qSH

    -- Step 1: Forward Scrambling
    scramble_register qD
    scramble_register qSH

    -- Step 2: Recurse into sub-throats
    invoke_demon_hole_rec params qD_left  qSH_left
    invoke_demon_hole_rec params qD_right qSH_right

    -- Step 3: Global Cross-Coupling
    forM_ (zip qD qSH) $ \(qd, qsh) ->
        gjw_entangler (couplingG params / fromIntegral n) qd qsh

    -- Step 4: Time-Reversed Unscramble
    reverse_geometry (scramble_register qD)
    reverse_geometry (scramble_register qSH)

-- | Main Entry Point: Unitary Erasure Pipeline
ahmad_plumbline_udh :: WormholeParams -> DemonState -> Circ DemonState
ahmad_plumbline_udh params state = do
    comment "--- BEGIN AHMADS PLUMBLINE: DEMON HOLE U_DH ---"
    let qD  = registerD  state
        qSH = registerSH state
    if length qD /= length qSH
        then error "Topology Error: Hilbert Space Dimension Mismatch!"
        else return ()
    invoke_demon_hole_rec params qD qSH
    comment "--- END AHMADS PLUMBLINE: STATE TRANSFERRED TO SHADOW HORIZON ---"
    return state
