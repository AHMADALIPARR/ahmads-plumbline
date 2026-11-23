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
  = QInit   [Double]                   -- Statevector initialization
  | QH      Int                        -- Hadamard
  | QRX     Expr Int                   -- RX(angle, qubit)
  | QRY     Expr Int                   -- RY(angle, qubit)
  | QRZ     Expr Int                   -- RZ(angle, qubit)
  | QCNOT   Int Int                    -- CNOT(ctrl, target)
  | QCond   String Double [QGate]      -- Classical guard (e.g. deg > 0.707)
  | QMeas   Int Int                    -- Measure qubit -> cbit
  | QReset  Int                        -- Reset qubit
  | QLoop   Int Int (Int -> [QGate])   -- Parametric unrolled/symbolic loop
  | QWhile  String [QGate]             -- Variational classical-quantum loop

data QCircuit = QCircuit
  { qcName   :: String
  , qcQubits :: Int
  , qcGates  :: [QGate]
  }

-- ---------------------------------------------------------------------------
-- 2. Tokenizer & Multi-DSL Parser
-- ---------------------------------------------------------------------------

stripSemiComments :: String -> [String]
stripSemiComments =
  filter (not . null) . map (trim . takeWhile (/= ';')) . lines
  where
    trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace

data Section
  = SecSymbolic [String]
  | SecFib      [String]
  | SecQASM     [String]
  | SecQSharp   [String]
  deriving (Show)

partitionSections :: [String] -> [Section]
partitionSections ls =
  [ SecSymbolic (takeWhile (not . ("FibSeq" `isPrefixOf`)) ls)
  , SecFib      (takeWhile (not . ("include" `isPrefixOf`))
                  (dropWhile (not . ("FibSeq" `isPrefixOf`)) ls))
  , SecQASM     (takeWhile (not . ("namespace" `isPrefixOf`))
                  (dropWhile (not . ("include" `isPrefixOf`)) ls))
  , SecQSharp   (dropWhile (not . ("namespace" `isPrefixOf`)) ls)
  ]

-- | Lower parsed sections into hand-written symbolic quantum circuits.
lowerToCircuits :: String -> [QCircuit]
lowerToCircuits src =
  let secs = partitionSections (stripSemiComments src)
  in concatMap lowerSec secs
  where
    lowerSec (SecSymbolic _) =
      [ QCircuit "Pipeline_Entangle_Collapse" 2
          [ QInit [0.5, 0.5, 0.5, 0.5] -- equivalent to H(0); H(1)
          , QCNOT 0 1                  -- Entangle @ [S CNOT]
          , QCond "deg > 0.707" 0.707 [QMeas 0 0, QMeas 1 1]
          ]
      ]

    lowerSec (SecFib _) =
      let fibStr = iterate step "A" !! 10
          step   = concatMap (\c -> if c == 'A' then "AB" else "A")
          gates  = zipWith (\k c ->
                     let e = (if c == 'A' then 1.0 else 0.618) * (0.618 ** fromIntegral k)
                         f = 440.0 * (e ** 1.5)
                     in QRZ (ENum f) (k `mod` 4)) [0..] (take 16 fibStr)
      in [ QCircuit "Fibonacci_Cantor_Phase_Oracle" 4 gates ]

    lowerSec (SecQASM _) =
      [ QCircuit "QASM_Manifold_256" 256
          [ QWhile "abs(current_energy - 0.0) >= 1e-6"
              [ QLoop 0 255 (\i ->
                  let angle = EMul (EVar "theta") (ENum (fromIntegral (i + 1)))
                  in QRY angle i : [QCNOT (i - 1) i | i > 0])
              , QLoop 0 255 (\i -> [QMeas i i])
              , QLoop 0 255 (\i -> [QReset i])
              ]
          ]
      ]

    lowerSec (SecQSharp _) =
      [ QCircuit "QSharp_ManifoldGreedyStep" 256
          [ QLoop 0 255 (\i ->
              let angle = EMul (EVar "theta") (ENum (fromIntegral (i + 1)))
              in QRX angle i : [QCNOT (i - 1) i | i > 0])
          ]
      ]

-- ---------------------------------------------------------------------------
-- 3. Pretty-Printer for Hand-Written Circuit Output
-- ---------------------------------------------------------------------------

renderGate :: QGate -> String
renderGate (QInit amps)    = "init_state " <> show amps <> "  // == H q[0]; H q[1];"
renderGate (QH q)          = "h q[" <> show q <> "];"
renderGate (QRX e q)       = "rx(" <> show e <> ") q[" <> show q <> "];"
renderGate (QRY e q)       = "ry(" <> show e <> ") q[" <> show q <> "];"
renderGate (QRZ e q)       = "rz(" <> show e <> ") q[" <> show q <> "];"
renderGate (QCNOT c t)     = "cx q[" <> show c <> "], q[" <> show t <> "];"
renderGate (QMeas q c)     = "measure q[" <> show q <> "] -> c[" <> show c <> "];"
renderGate (QReset q)      = "reset q[" <> show q <> "];"
renderGate (QCond g _ gs)  = "if (" <> g <> ") { " <> unwords (map renderGate gs) <> " }"
renderGate (QLoop lo hi f) = "for i in " <> show lo <> ".." <> show hi <> ": "
                             <> unwords (map renderGate (f lo)) <> " ..."
renderGate (QWhile c gs)   = "while (" <> c <> ") {\n  "
                             <> unlines (map renderGate gs) <> "}"

-- ---------------------------------------------------------------------------
-- 4. OpenQASM 3.0 Exporter
-- ---------------------------------------------------------------------------

renderQASMExpr :: Expr -> String
renderQASMExpr (ENum d)   = show d
renderQASMExpr (EVar v)   = v
renderQASMExpr (EAdd a b) = "(" <> renderQASMExpr a <> " + " <> renderQASMExpr b <> ")"
renderQASMExpr (ESub a b) = "(" <> renderQASMExpr a <> " - " <> renderQASMExpr b <> ")"
renderQASMExpr (EMul a b) = "(" <> renderQASMExpr a <> " * " <> renderQASMExpr b <> ")"

collectVars :: [QGate] -> [String]
collectVars = foldr go []
  where
    go (QRX e _)    acc = exprVars e <> acc
    go (QRY e _)    acc = exprVars e <> acc
    go (QRZ e _)    acc = exprVars e <> acc
    go (QLoop lo _ f) acc = collectVars (f lo) <> acc
    go (QWhile _ gs)  acc = collectVars gs <> acc
    go (QCond _ _ gs) acc = collectVars gs <> acc
    go _              acc = acc

    exprVars (EVar v)   = [v]
    exprVars (EAdd a b) = exprVars a <> exprVars b
    exprVars (ESub a b) = exprVars a <> exprVars b
    exprVars (EMul a b) = exprVars a <> exprVars b
    exprVars _          = []

nubVars :: [String] -> [String]
nubVars = foldr (\x acc -> if x `elem` acc then acc else x : acc) []

unrollGate :: String -> QGate -> [String]
unrollGate ind gate = case gate of
  QInit [0.5, 0.5, 0.5, 0.5] ->
    [ind <> "h q[0];", ind <> "h q[1];"]
  QInit amps ->
    [ind <> "// init_state " <> show amps]
  QH q ->
    [ind <> "h q[" <> show q <> "];"]
  QRX e q ->
    [ind <> "rx(" <> renderQASMExpr e <> ") q[" <> show q <> "];"]
  QRY e q ->
    [ind <> "ry(" <> renderQASMExpr e <> ") q[" <> show q <> "];"]
  QRZ e q ->
    [ind <> "rz(" <> renderQASMExpr e <> ") q[" <> show q <> "];"]
  QCNOT c t ->
    [ind <> "cx q[" <> show c <> "], q[" <> show t <> "];"]
  QMeas q c ->
    [ind <> "c[" <> show c <> "] = measure q[" <> show q <> "];"]
  QReset q ->
    [ind <> "reset q[" <> show q <> "];"]
  QLoop lo hi f ->
    concatMap (unrollGate ind) (concatMap f [lo .. hi])
  QCond cond _ gs ->
    [ind <> "if (" <> cond <> ") {"]
    <> concatMap (unrollGate (ind <> "  ")) gs
    <> [ind <> "}"]
  QWhile cond gs ->
    [ind <> "while (" <> cond <> ") {"]
    <> concatMap (unrollGate (ind <> "  ")) gs
    <> [ind <> "}"]

-- | Render a QCircuit to valid OpenQASM 3.0 source.
toOpenQASM3 :: QCircuit -> String
toOpenQASM3 (QCircuit name n gs) =
  let vars = nubVars (collectVars gs)
      hdr  = [ "// Circuit: " <> name
             , "OPENQASM 3.0;"
             , "include \"stdgates.inc\";"
             , "qubit[" <> show n <> "] q;"
             , "bit["   <> show n <> "] c;"
             ]
             <> [ "input float[64] " <> v <> ";" | v <- vars ]
      body = concatMap (unrollGate "") gs
  in unlines (hdr <> [""] <> body)

-- ---------------------------------------------------------------------------
-- 5. Steane [[7,1,3]] CSS code wrapper
--    7 physical data qubits per logical qubit
--    (distinct from Surface-17 which uses 9 data qubits)
-- ---------------------------------------------------------------------------

steaneSlice :: Int -> String
steaneSlice i =
  let base = 7 * i
  in "q[" <> show base <> ":" <> show (base + 6) <> "]"

emitSteaneGate :: QGate -> [String]
emitSteaneGate (QRX e i) =
  ["rx_logical(" <> renderQASMExpr e <> ") " <> steaneSlice i <> ";"]
emitSteaneGate (QCNOT c t) =
  [ "cx_logical " <> steaneSlice c <> ", " <> steaneSlice t <> ";"
  , "steane_qec(" <> steaneSlice t <> ", anc);"
  , "// dense_steane_decode(syn) → dense_steane_correct"
  ]
emitSteaneGate (QLoop lo hi f) =
  concatMap emitSteaneGate (concatMap f [lo .. hi])
emitSteaneGate g = unrollGate "" g

-- ---------------------------------------------------------------------------
-- 6. Surface-17 (distance-3 rotated surface code) pass
--    Physical qubits: 9 data per logical qubit
--    256 logical → 2304 physical data qubits (+ 8 reusable ancillas)
-- ---------------------------------------------------------------------------

surface17Slice :: Int -> String
surface17Slice i =
  let base = 9 * i
  in "q[" <> show base <> ":" <> show (base + 8) <> "]"

emitSurface17Gate :: QGate -> [String]
emitSurface17Gate (QRX e i) =
  ["rx_surface17(" <> renderQASMExpr e <> ") " <> surface17Slice i <> ";"]
emitSurface17Gate (QCNOT c t) =
  [ "cx_surface17 " <> surface17Slice c <> ", " <> surface17Slice t <> ";"
  , "surface17_qec(" <> surface17Slice t <> ", anc);"
  ]
emitSurface17Gate (QLoop lo hi f) =
  concatMap emitSurface17Gate (concatMap f [lo .. hi])
emitSurface17Gate g = unrollGate "" g

-- ---------------------------------------------------------------------------
-- 7. QEC variants, thresholds, and fault-tolerance guard
-- ---------------------------------------------------------------------------

data QECVariant
  = Surface17      -- [[9,1,3]]  + 8 ancillas
  | Color666_d3    -- [[7,1,3]]  triangular 6.6.6
  | Color488_d5    -- [[17,1,5]] square-octagon 4.8.8
  | Color666_d5    -- [[19,1,5]] hexagonal 6.6.6
  deriving (Eq, Show)

-- (n_data, d, p_th)
dataThreshold :: QECVariant -> (Int, Int, Double)
dataThreshold Surface17   = (9,  3, 0.008)
dataThreshold Color666_d3 = (7,  3, 0.003)
dataThreshold Color488_d5 = (17, 5, 0.002)
dataThreshold Color666_d5 = (19, 5, 0.002)

-- | Verify p < p_th and estimate logical error rate P_L ~ 0.1 * (p / p_th)^((d+1)/2).
checkThreshold :: QECVariant -> Double -> Either String Double
checkThreshold var pPhys =
  let (_, d, pTh) = dataThreshold var
      expPow      = fromIntegral ((d + 1) `div` 2) :: Double
  in if pPhys >= pTh
       then Left $ show var <> ": physical error " <> show pPhys
                   <> " >= threshold " <> show pTh <> " (not fault-tolerant)"
       else Right $ 0.1 * ((pPhys / pTh) ** expPow)

emitVariantGate :: QECVariant -> QGate -> [String]
emitVariantGate var gate =
  let (nData, _, _) = dataThreshold var
      slice i = "q[" <> show (nData * i) <> ":" <> show (nData * i + nData - 1) <> "]"
      (rxName, cxName) = case var of
        Surface17   -> ("rx_surface17", "cx_surface17")
        Color666_d3 -> ("rx_color666",  "cx_color666")
        Color488_d5 -> ("rx_color488",  "cx_color488")
        Color666_d5 -> ("rx_color666",  "cx_color666")
  in case gate of
       QRX e i       -> [rxName <> "(" <> renderQASMExpr e <> ") " <> slice i <> ";"]
       QCNOT c t     -> [cxName <> " " <> slice c <> ", " <> slice t <> ";"]
       QLoop lo hi f -> concatMap (emitVariantGate var) (concatMap f [lo .. hi])
       other         -> unrollGate "" other





