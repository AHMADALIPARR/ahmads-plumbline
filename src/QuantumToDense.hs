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

{-# LANGUAGE OverloadedStrings #-}
module QuantumToDense where

import QuantumDSL
import DenseMorph
import Data.Word (Word32, Word64)

-- | Compile a symbolic QCircuit into dense Parlog GoalSlots.
-- Each gate becomes a dense goal with an input-mode mask.
compileToDense :: QCircuit -> IO ()
compileToDense circ = do
  putStrLn $ "Compiling " <> qcName circ <> " to dense Parlog (" <> show (qcQubits circ) <> " qubits)"
  let goals = gatesToGoals 0 (qcGates circ)
  morphGoalsDense 0 goals
  putStrLn "Dense spawn complete."

gatesToGoals :: Word32 -> [QGate] -> [(Word32, [Word32], Word64)]
gatesToGoals _ [] = []
gatesToGoals slot (g:gs) =
  case g of
    QCNOT c t ->
      (slot, [fromIntegral c, fromIntegral t], 1) : gatesToGoals (slot + 1) gs
    QH q ->
      (slot, [fromIntegral q], 0) : gatesToGoals (slot + 1) gs
    QRY _ q ->
      (slot, [fromIntegral q], 0) : gatesToGoals (slot + 1) gs
    QRX _ q ->
      (slot, [fromIntegral q], 0) : gatesToGoals (slot + 1) gs
    QRZ _ q ->
      (slot, [fromIntegral q], 0) : gatesToGoals (slot + 1) gs
    QMeas q _ ->
      (slot, [fromIntegral q], 1) : gatesToGoals (slot + 1) gs
    QReset q ->
      (slot, [fromIntegral q], 0) : gatesToGoals (slot + 1) gs
    QCond _ _ body ->
      gatesToGoals slot (body ++ gs)
    QLoop lo hi f ->
      gatesToGoals slot (concatMap f [lo..hi] ++ gs)
    QWhile _ body ->
      gatesToGoals slot (body ++ gs)
    _ -> gatesToGoals slot gs

-- | Entry point: lower the UA / Plumbline DSL then compile every circuit
compileAll :: String -> IO ()
compileAll src = mapM_ compileToDense (lowerToCircuits src)
