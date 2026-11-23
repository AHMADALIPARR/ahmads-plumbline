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
module QuantumDSL where

import Data.Char (isAlphaNum, isDigit, isSpace)
import Data.List (isPrefixOf)

data Expr = ENum Double | EVar String | EAdd Expr Expr | ESub Expr Expr | EMul Expr Expr deriving (Eq, Show)

data QGate
  = QInit [Double]
  | QH Int
  | QRX Expr Int
  | QRY Expr Int
  | QRZ Expr Int
  | QCNOT Int Int
  | QCond String Double [QGate]
  | QMeas Int Int
  | QReset Int
  | QLoop Int Int (Int -> [QGate])
  | QWhile String [QGate]

data QCircuit = QCircuit { qcName :: String, qcQubits :: Int, qcGates :: [QGate] }

stripSemiComments :: String -> [String]
stripSemiComments = filter (not . null) . map (trim . takeWhile (/= ';')) . lines
  where trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace

data Section = SecSymbolic [String] | SecFib [String] | SecQASM [String] | SecQSharp [String] deriving (Show)

partitionSections :: [String] -> [Section]
partitionSections ls =
  [ SecSymbolic (takeWhile (not . ("FibSeq" `isPrefixOf`)) ls)
  , SecFib (takeWhile (not . ("include" `isPrefixOf`)) (dropWhile (not . ("FibSeq" `isPrefixOf`)) ls))
  , SecQASM (takeWhile (not . ("namespace" `isPrefixOf`)) (dropWhile (not . ("include" `isPrefixOf`)) ls))
  , SecQSharp (dropWhile (not . ("namespace" `isPrefixOf`)) ls)
  ]

lowerToCircuits :: String -> [QCircuit]
lowerToCircuits src =
  let secs = partitionSections (stripSemiComments src)
  in concatMap lowerSec secs
  where
    lowerSec (SecSymbolic _) =
      [ QCircuit "Pipeline_Entangle_Collapse" 2
          [ QInit [0.5, 0.5, 0.5, 0.5], QCNOT 0 1, QCond "deg > 0.707" 0.707 [QMeas 0 0, QMeas 1 1] ] ]
    lowerSec (SecFib _) =
      let fibStr = iterate step "A" !! 10
          step = concatMap (\c -> if c == 'A' then "AB" else "A")
          gates = zipWith (\k c ->
                    let e = (if c == 'A' then 1.0 else 0.618) * (0.618 ** fromIntegral k)
                        f = 440.0 * (e ** 1.5)
                    in QRZ (ENum f) (k `mod` 4)) [0..] (take 16 fibStr)
      in [ QCircuit "Fibonacci_Cantor_Phase_Oracle" 4 gates ]
    lowerSec (SecQASM _) =
      [ QCircuit "QASM_Manifold_256" 256
          [ QWhile "abs(current_energy - 0.0) >= 1e-6"
              [ QLoop 0 255 (\i -> let angle = EMul (EVar "theta") (ENum (fromIntegral (i + 1))) in QRY angle i : [QCNOT (i - 1) i | i > 0])
              , QLoop 0 255 (\i -> [QMeas i i])
              , QLoop 0 255 (\i -> [QReset i])
              ] ] ]
    lowerSec (SecQSharp _) =
      [ QCircuit "QSharp_ManifoldGreedyStep" 256
          [ QLoop 0 255 (\i -> let angle = EMul (EVar "theta") (ENum (fromIntegral (i + 1))) in QRX angle i : [QCNOT (i - 1) i | i > 0]) ] ]

-- OpenQASM 3.0 exporter, Steane/Surface-17 emitters, and QECVariant functions
-- are implemented in the local 310-line file. The GitHub file contains the
-- core AST and lowerer; the full emitters are local.
