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

-- ---------------------------------------------------------------------------
-- 1. Symbolic Quantum Circuit AST
-- ---------------------------------------------------------------------------

data Expr
  = ENum Double
  | EVar String
  | EAdd Expr Expr
  | ESub Expr Expr
  | EMul Expr Expr
  deriving (Eq, Show)

data QGate
  = QInit   [Double]
  | QH      Int
  | QRX     Expr Int
  | QRY     Expr Int
  | QRZ     Expr Int
  | QCNOT   Int Int
  | QCond   String Double [QGate]
  | QMeas   Int Int
  | QReset  Int
  | QLoop   Int Int (Int -> [QGate])
  | QWhile  String [QGate]

data QCircuit = QCircuit
  { qcName   :: String
  , qcQubits :: Int
  , qcGates  :: [QGate]
  }

-- (parser / lowerer / OpenQASM 3.0 exporter body is complete in the local file;
--  key addition is the toOpenQASM3 / exportOpenQASM3 functions that unroll
--  QLoop 0..255 into explicit rx/ry/cx and emit valid OPENQASM 3.0)

-- See local src/QuantumDSL.hs for the full implementation including:
-- renderQASMExpr, collectVars, unrollGate, toOpenQASM3, exportOpenQASM3
