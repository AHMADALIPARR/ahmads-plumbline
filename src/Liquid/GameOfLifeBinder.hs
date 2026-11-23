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

{-@ LIQUID "--reflection" @-}
{-@ LIQUID "--ple" @-}

module Liquid.GameOfLifeBinder where

import Data.Word
import Data.Int

-- | Cell state: 0 dead, 1 alive.
{-@ type Cell = {v:Int | v == 0 || v == 1} @-}
type Cell = Int

-- | Grid size is a positive power of two for Dex array alignment.
{-@ type GridSize = {v:Int | v > 0 && v <= 1024} @-}

-- | Neighbour count is between 0 and 8.
{-@ type NeighbourCount = {v:Int | 0 <= v && v <= 8} @-}

-- | Birth rule: exactly 3 live neighbours.
{-@ predicate IsBirth N = N == 3 @-}

-- | Survival rule: 2 or 3 live neighbours.
{-@ predicate IsSurvival N = N == 2 || N == 3 @-}

-- | Next state under Conway rules.
{-@ nextState :: Cell -> NeighbourCount -> Cell @-}
nextState :: Cell -> Int -> Cell
nextState cell n
  | n == 3             = 1
  | n == 2 && cell == 1 = 1
  | otherwise          = 0

-- | Sum of eight neighbours, refined to NeighbourCount.
{-@ countNeighbours :: Cell -> Cell -> Cell -> Cell
                    -> Cell -> Cell -> Cell -> Cell
                    -> NeighbourCount @-}
countNeighbours :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int
countNeighbours nw n ne w e sw s se =
  nw + n + ne + w + e + sw + s + se

-- | One step for a single cell given its eight neighbours.
{-@ stepCell :: Cell -> Cell -> Cell -> Cell
             -> Cell -> Cell -> Cell -> Cell -> Cell
             -> Cell @-}
stepCell :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int -> Int
stepCell c nw n ne w e sw s se =
  nextState c (countNeighbours nw n ne w e sw s se)

-- | Dex-facing interface: export a flattened step function.
--   Dex can call this via FFI once the module is compiled.
{-@ dexStepFlat :: {n:Int | n > 0} -> [Cell] -> [Cell] @-}
dexStepFlat :: Int -> [Int] -> [Int]
dexStepFlat n grid = grid  -- placeholder; full version indexes the Moore neighbourhood

-- | Generation counter is non-negative.
{-@ type Generation = {v:Int | v >= 0} @-}

-- | Run a fixed number of generations.
{-@ runGenerations :: Generation -> [Cell] -> [Cell] @-}
runGenerations :: Int -> [Int] -> [Int]
runGenerations 0 g = g
runGenerations k g = runGenerations (k - 1) (dexStepFlat (length g) g)

-- | Still-life: next state equals current state.
{-@ predicate IsStillLife C N = nextState C N == C @-}

-- | Oscillator period-2: two steps restore the original.
{-@ predicate IsPeriod2 C1 C2 = nextState C1 3 == C2 && nextState C2 3 == C1 @-}


-- | Helper 1: refined neighbour offset.
{-@ offset1 :: {v:Int | -1 <= v && v <= 1} @-}
offset1 :: Int
offset1 = 0

-- | Helper 1: population bound for a 1-cell block.
{-@ popBound1 :: {v:Int | 0 <= v && v <= 1} @-}
popBound1 :: Int
popBound1 = 1


-- | Helper 2: refined neighbour offset.
{-@ offset2 :: {v:Int | -1 <= v && v <= 1} @-}
offset2 :: Int
offset2 = 1

-- | Helper 2: population bound for a 2-cell block.
{-@ popBound2 :: {v:Int | 0 <= v && v <= 2} @-}
popBound2 :: Int
popBound2 = 2


-- | Helper 3: refined neighbour offset.
{-@ offset3 :: {v:Int | -1 <= v && v <= 1} @-}
offset3 :: Int
offset3 = -1

-- | Helper 3: population bound for a 3-cell block.
{-@ popBound3 :: {v:Int | 0 <= v && v <= 3} @-}
popBound3 :: Int
popBound3 = 3


-- | Helper 4: refined neighbour offset.
{-@ offset4 :: {v:Int | -1 <= v && v <= 1} @-}
offset4 :: Int
offset4 = 0

-- | Helper 4: population bound for a 4-cell block.
{-@ popBound4 :: {v:Int | 0 <= v && v <= 4} @-}
popBound4 :: Int
popBound4 = 4


-- | Helper 5: refined neighbour offset.
{-@ offset5 :: {v:Int | -1 <= v && v <= 1} @-}
offset5 :: Int
offset5 = 1

-- | Helper 5: population bound for a 5-cell block.
{-@ popBound5 :: {v:Int | 0 <= v && v <= 5} @-}
popBound5 :: Int
popBound5 = 5


-- | Helper 6: refined neighbour offset.
{-@ offset6 :: {v:Int | -1 <= v && v <= 1} @-}
offset6 :: Int
offset6 = -1

-- | Helper 6: population bound for a 6-cell block.
{-@ popBound6 :: {v:Int | 0 <= v && v <= 6} @-}
popBound6 :: Int
popBound6 = 6


-- | Helper 7: refined neighbour offset.
{-@ offset7 :: {v:Int | -1 <= v && v <= 1} @-}
offset7 :: Int
offset7 = 0

-- | Helper 7: population bound for a 7-cell block.
{-@ popBound7 :: {v:Int | 0 <= v && v <= 7} @-}
popBound7 :: Int
popBound7 = 7


-- | Helper 8: refined neighbour offset.
{-@ offset8 :: {v:Int | -1 <= v && v <= 1} @-}
offset8 :: Int
offset8 = 1

-- | Helper 8: population bound for a 8-cell block.
{-@ popBound8 :: {v:Int | 0 <= v && v <= 8} @-}
popBound8 :: Int
popBound8 = 8


-- | Helper 9: refined neighbour offset.
{-@ offset9 :: {v:Int | -1 <= v && v <= 1} @-}
offset9 :: Int
offset9 = -1

-- | Helper 9: population bound for a 9-cell block.
{-@ popBound9 :: {v:Int | 0 <= v && v <= 9} @-}
popBound9 :: Int
popBound9 = 9


-- | Helper 10: refined neighbour offset.
{-@ offset10 :: {v:Int | -1 <= v && v <= 1} @-}
offset10 :: Int
offset10 = 0

-- | Helper 10: population bound for a 10-cell block.
{-@ popBound10 :: {v:Int | 0 <= v && v <= 10} @-}
popBound10 :: Int
popBound10 = 10


-- | Helper 11: refined neighbour offset.
{-@ offset11 :: {v:Int | -1 <= v && v <= 1} @-}
offset11 :: Int
offset11 = 1

-- | Helper 11: population bound for a 11-cell block.
{-@ popBound11 :: {v:Int | 0 <= v && v <= 11} @-}
popBound11 :: Int
popBound11 = 11


-- | Helper 12: refined neighbour offset.
{-@ offset12 :: {v:Int | -1 <= v && v <= 1} @-}
offset12 :: Int
offset12 = -1

-- | Helper 12: population bound for a 12-cell block.
{-@ popBound12 :: {v:Int | 0 <= v && v <= 12} @-}
popBound12 :: Int
popBound12 = 12


-- | Helper 13: refined neighbour offset.
{-@ offset13 :: {v:Int | -1 <= v && v <= 1} @-}
offset13 :: Int
offset13 = 0

-- | Helper 13: population bound for a 13-cell block.
{-@ popBound13 :: {v:Int | 0 <= v && v <= 13} @-}
popBound13 :: Int
popBound13 = 13


-- | Helper 14: refined neighbour offset.
{-@ offset14 :: {v:Int | -1 <= v && v <= 1} @-}
offset14 :: Int
offset14 = 1

-- | Helper 14: population bound for a 14-cell block.
{-@ popBound14 :: {v:Int | 0 <= v && v <= 14} @-}
popBound14 :: Int
popBound14 = 14


-- | Helper 15: refined neighbour offset.
{-@ offset15 :: {v:Int | -1 <= v && v <= 1} @-}
offset15 :: Int
offset15 = -1

-- | Helper 15: population bound for a 15-cell block.
{-@ popBound15 :: {v:Int | 0 <= v && v <= 15} @-}
popBound15 :: Int
popBound15 = 15


-- | Helper 16: refined neighbour offset.
{-@ offset16 :: {v:Int | -1 <= v && v <= 1} @-}
offset16 :: Int
offset16 = 0

-- | Helper 16: population bound for a 16-cell block.
{-@ popBound16 :: {v:Int | 0 <= v && v <= 16} @-}
popBound16 :: Int
popBound16 = 16


-- | Helper 17: refined neighbour offset.
{-@ offset17 :: {v:Int | -1 <= v && v <= 1} @-}
offset17 :: Int
offset17 = 1

-- | Helper 17: population bound for a 17-cell block.
{-@ popBound17 :: {v:Int | 0 <= v && v <= 17} @-}
popBound17 :: Int
popBound17 = 17


-- | Helper 18: refined neighbour offset.
{-@ offset18 :: {v:Int | -1 <= v && v <= 1} @-}
offset18 :: Int
offset18 = -1

-- | Helper 18: population bound for a 18-cell block.
{-@ popBound18 :: {v:Int | 0 <= v && v <= 18} @-}
popBound18 :: Int
popBound18 = 18


-- | Helper 19: refined neighbour offset.
{-@ offset19 :: {v:Int | -1 <= v && v <= 1} @-}
offset19 :: Int
offset19 = 0

-- | Helper 19: population bound for a 19-cell block.
{-@ popBound19 :: {v:Int | 0 <= v && v <= 19} @-}
popBound19 :: Int
popBound19 = 19


-- | Helper 20: refined neighbour offset.
{-@ offset20 :: {v:Int | -1 <= v && v <= 1} @-}
offset20 :: Int
offset20 = 1

-- | Helper 20: population bound for a 20-cell block.
{-@ popBound20 :: {v:Int | 0 <= v && v <= 20} @-}
popBound20 :: Int
popBound20 = 20


-- | Helper 21: refined neighbour offset.
{-@ offset21 :: {v:Int | -1 <= v && v <= 1} @-}
offset21 :: Int
offset21 = -1

-- | Helper 21: population bound for a 21-cell block.
{-@ popBound21 :: {v:Int | 0 <= v && v <= 21} @-}
popBound21 :: Int
popBound21 = 21


-- | Helper 22: refined neighbour offset.
{-@ offset22 :: {v:Int | -1 <= v && v <= 1} @-}
offset22 :: Int
offset22 = 0

-- | Helper 22: population bound for a 22-cell block.
{-@ popBound22 :: {v:Int | 0 <= v && v <= 22} @-}
popBound22 :: Int
popBound22 = 22


-- | Helper 23: refined neighbour offset.
{-@ offset23 :: {v:Int | -1 <= v && v <= 1} @-}
offset23 :: Int
offset23 = 1

-- | Helper 23: population bound for a 23-cell block.
{-@ popBound23 :: {v:Int | 0 <= v && v <= 23} @-}
popBound23 :: Int
popBound23 = 23


-- | Helper 24: refined neighbour offset.
{-@ offset24 :: {v:Int | -1 <= v && v <= 1} @-}
offset24 :: Int
offset24 = -1

-- | Helper 24: population bound for a 24-cell block.
{-@ popBound24 :: {v:Int | 0 <= v && v <= 24} @-}
popBound24 :: Int
popBound24 = 24


-- | Helper 25: refined neighbour offset.
{-@ offset25 :: {v:Int | -1 <= v && v <= 1} @-}
offset25 :: Int
offset25 = 0

-- | Helper 25: population bound for a 25-cell block.
{-@ popBound25 :: {v:Int | 0 <= v && v <= 25} @-}
popBound25 :: Int
popBound25 = 25


-- | Helper 26: refined neighbour offset.
{-@ offset26 :: {v:Int | -1 <= v && v <= 1} @-}
offset26 :: Int
offset26 = 1

-- | Helper 26: population bound for a 26-cell block.
{-@ popBound26 :: {v:Int | 0 <= v && v <= 26} @-}
popBound26 :: Int
popBound26 = 26


-- | Helper 27: refined neighbour offset.
{-@ offset27 :: {v:Int | -1 <= v && v <= 1} @-}
offset27 :: Int
offset27 = -1

-- | Helper 27: population bound for a 27-cell block.
{-@ popBound27 :: {v:Int | 0 <= v && v <= 27} @-}
popBound27 :: Int
popBound27 = 27


-- | Helper 28: refined neighbour offset.
{-@ offset28 :: {v:Int | -1 <= v && v <= 1} @-}
offset28 :: Int
offset28 = 0

-- | Helper 28: population bound for a 28-cell block.
{-@ popBound28 :: {v:Int | 0 <= v && v <= 28} @-}
popBound28 :: Int
popBound28 = 28


-- | Helper 29: refined neighbour offset.
{-@ offset29 :: {v:Int | -1 <= v && v <= 1} @-}
offset29 :: Int
offset29 = 1

-- | Helper 29: population bound for a 29-cell block.
{-@ popBound29 :: {v:Int | 0 <= v && v <= 29} @-}
popBound29 :: Int
popBound29 = 29


-- | Helper 30: refined neighbour offset.
{-@ offset30 :: {v:Int | -1 <= v && v <= 1} @-}
offset30 :: Int
offset30 = -1

-- | Helper 30: population bound for a 30-cell block.
{-@ popBound30 :: {v:Int | 0 <= v && v <= 30} @-}
popBound30 :: Int
popBound30 = 30


-- | Helper 31: refined neighbour offset.
{-@ offset31 :: {v:Int | -1 <= v && v <= 1} @-}
offset31 :: Int
offset31 = 0

-- | Helper 31: population bound for a 31-cell block.
{-@ popBound31 :: {v:Int | 0 <= v && v <= 31} @-}
popBound31 :: Int
popBound31 = 31


-- | Helper 32: refined neighbour offset.
{-@ offset32 :: {v:Int | -1 <= v && v <= 1} @-}
offset32 :: Int
offset32 = 1

-- | Helper 32: population bound for a 32-cell block.
{-@ popBound32 :: {v:Int | 0 <= v && v <= 32} @-}
popBound32 :: Int
popBound32 = 32


-- | Helper 33: refined neighbour offset.
{-@ offset33 :: {v:Int | -1 <= v && v <= 1} @-}
offset33 :: Int
offset33 = -1

-- | Helper 33: population bound for a 33-cell block.
{-@ popBound33 :: {v:Int | 0 <= v && v <= 33} @-}
popBound33 :: Int
popBound33 = 33


-- | Helper 34: refined neighbour offset.
{-@ offset34 :: {v:Int | -1 <= v && v <= 1} @-}
offset34 :: Int
offset34 = 0

-- | Helper 34: population bound for a 34-cell block.
{-@ popBound34 :: {v:Int | 0 <= v && v <= 34} @-}
popBound34 :: Int
popBound34 = 34


-- | Helper 35: refined neighbour offset.
{-@ offset35 :: {v:Int | -1 <= v && v <= 1} @-}
offset35 :: Int
offset35 = 1

-- | Helper 35: population bound for a 35-cell block.
{-@ popBound35 :: {v:Int | 0 <= v && v <= 35} @-}
popBound35 :: Int
popBound35 = 35


-- | Helper 36: refined neighbour offset.
{-@ offset36 :: {v:Int | -1 <= v && v <= 1} @-}
offset36 :: Int
offset36 = -1

-- | Helper 36: population bound for a 36-cell block.
{-@ popBound36 :: {v:Int | 0 <= v && v <= 36} @-}
popBound36 :: Int
popBound36 = 36


-- | Helper 37: refined neighbour offset.
{-@ offset37 :: {v:Int | -1 <= v && v <= 1} @-}
offset37 :: Int
offset37 = 0

-- | Helper 37: population bound for a 37-cell block.
{-@ popBound37 :: {v:Int | 0 <= v && v <= 37} @-}
popBound37 :: Int
popBound37 = 37


-- | Helper 38: refined neighbour offset.
{-@ offset38 :: {v:Int | -1 <= v && v <= 1} @-}
offset38 :: Int
offset38 = 1

-- | Helper 38: population bound for a 38-cell block.
{-@ popBound38 :: {v:Int | 0 <= v && v <= 38} @-}
popBound38 :: Int
popBound38 = 38


-- | Helper 39: refined neighbour offset.
{-@ offset39 :: {v:Int | -1 <= v && v <= 1} @-}
offset39 :: Int
offset39 = -1

-- | Helper 39: population bound for a 39-cell block.
{-@ popBound39 :: {v:Int | 0 <= v && v <= 39} @-}
popBound39 :: Int
popBound39 = 39


-- | Helper 40: refined neighbour offset.
{-@ offset40 :: {v:Int | -1 <= v && v <= 1} @-}
offset40 :: Int
offset40 = 0

-- | Helper 40: population bound for a 40-cell block.
{-@ popBound40 :: {v:Int | 0 <= v && v <= 40} @-}
popBound40 :: Int
popBound40 = 40


-- | Helper 41: refined neighbour offset.
{-@ offset41 :: {v:Int | -1 <= v && v <= 1} @-}
offset41 :: Int
offset41 = 1

-- | Helper 41: population bound for a 41-cell block.
{-@ popBound41 :: {v:Int | 0 <= v && v <= 41} @-}
popBound41 :: Int
popBound41 = 41


-- | Helper 42: refined neighbour offset.
{-@ offset42 :: {v:Int | -1 <= v && v <= 1} @-}
offset42 :: Int
offset42 = -1

-- | Helper 42: population bound for a 42-cell block.
{-@ popBound42 :: {v:Int | 0 <= v && v <= 42} @-}
popBound42 :: Int
popBound42 = 42


-- | Helper 43: refined neighbour offset.
{-@ offset43 :: {v:Int | -1 <= v && v <= 1} @-}
offset43 :: Int
offset43 = 0

-- | Helper 43: population bound for a 43-cell block.
{-@ popBound43 :: {v:Int | 0 <= v && v <= 43} @-}
popBound43 :: Int
popBound43 = 43


-- | Helper 44: refined neighbour offset.
{-@ offset44 :: {v:Int | -1 <= v && v <= 1} @-}
offset44 :: Int
offset44 = 1

-- | Helper 44: population bound for a 44-cell block.
{-@ popBound44 :: {v:Int | 0 <= v && v <= 44} @-}
popBound44 :: Int
popBound44 = 44


-- | Helper 45: refined neighbour offset.
{-@ offset45 :: {v:Int | -1 <= v && v <= 1} @-}
offset45 :: Int
offset45 = -1

-- | Helper 45: population bound for a 45-cell block.
{-@ popBound45 :: {v:Int | 0 <= v && v <= 45} @-}
popBound45 :: Int
popBound45 = 45


-- | Helper 46: refined neighbour offset.
{-@ offset46 :: {v:Int | -1 <= v && v <= 1} @-}
offset46 :: Int
offset46 = 0

-- | Helper 46: population bound for a 46-cell block.
{-@ popBound46 :: {v:Int | 0 <= v && v <= 46} @-}
popBound46 :: Int
popBound46 = 46


-- | Helper 47: refined neighbour offset.
{-@ offset47 :: {v:Int | -1 <= v && v <= 1} @-}
offset47 :: Int
offset47 = 1

-- | Helper 47: population bound for a 47-cell block.
{-@ popBound47 :: {v:Int | 0 <= v && v <= 47} @-}
popBound47 :: Int
popBound47 = 47


-- | Helper 48: refined neighbour offset.
{-@ offset48 :: {v:Int | -1 <= v && v <= 1} @-}
offset48 :: Int
offset48 = -1

-- | Helper 48: population bound for a 48-cell block.
{-@ popBound48 :: {v:Int | 0 <= v && v <= 48} @-}
popBound48 :: Int
popBound48 = 48


-- | Helper 49: refined neighbour offset.
{-@ offset49 :: {v:Int | -1 <= v && v <= 1} @-}
offset49 :: Int
offset49 = 0

-- | Helper 49: population bound for a 49-cell block.
{-@ popBound49 :: {v:Int | 0 <= v && v <= 49} @-}
popBound49 :: Int
popBound49 = 49


-- | Helper 50: refined neighbour offset.
{-@ offset50 :: {v:Int | -1 <= v && v <= 1} @-}
offset50 :: Int
offset50 = 1

-- | Helper 50: population bound for a 50-cell block.
{-@ popBound50 :: {v:Int | 0 <= v && v <= 50} @-}
popBound50 :: Int
popBound50 = 50


-- | Helper 51: refined neighbour offset.
{-@ offset51 :: {v:Int | -1 <= v && v <= 1} @-}
offset51 :: Int
offset51 = -1

-- | Helper 51: population bound for a 51-cell block.
{-@ popBound51 :: {v:Int | 0 <= v && v <= 51} @-}
popBound51 :: Int
popBound51 = 51


-- | Helper 52: refined neighbour offset.
{-@ offset52 :: {v:Int | -1 <= v && v <= 1} @-}
offset52 :: Int
offset52 = 0

-- | Helper 52: population bound for a 52-cell block.
{-@ popBound52 :: {v:Int | 0 <= v && v <= 52} @-}
popBound52 :: Int
popBound52 = 52


-- | Helper 53: refined neighbour offset.
{-@ offset53 :: {v:Int | -1 <= v && v <= 1} @-}
offset53 :: Int
offset53 = 1

-- | Helper 53: population bound for a 53-cell block.
{-@ popBound53 :: {v:Int | 0 <= v && v <= 53} @-}
popBound53 :: Int
popBound53 = 53


-- | Helper 54: refined neighbour offset.
{-@ offset54 :: {v:Int | -1 <= v && v <= 1} @-}
offset54 :: Int
offset54 = -1

-- | Helper 54: population bound for a 54-cell block.
{-@ popBound54 :: {v:Int | 0 <= v && v <= 54} @-}
popBound54 :: Int
popBound54 = 54


-- | Helper 55: refined neighbour offset.
{-@ offset55 :: {v:Int | -1 <= v && v <= 1} @-}
offset55 :: Int
offset55 = 0

-- | Helper 55: population bound for a 55-cell block.
{-@ popBound55 :: {v:Int | 0 <= v && v <= 55} @-}
popBound55 :: Int
popBound55 = 55


-- | Helper 56: refined neighbour offset.
{-@ offset56 :: {v:Int | -1 <= v && v <= 1} @-}
offset56 :: Int
offset56 = 1

-- | Helper 56: population bound for a 56-cell block.
{-@ popBound56 :: {v:Int | 0 <= v && v <= 56} @-}
popBound56 :: Int
popBound56 = 56


-- | Helper 57: refined neighbour offset.
{-@ offset57 :: {v:Int | -1 <= v && v <= 1} @-}
offset57 :: Int
offset57 = -1

-- | Helper 57: population bound for a 57-cell block.
{-@ popBound57 :: {v:Int | 0 <= v && v <= 57} @-}
popBound57 :: Int
popBound57 = 57


-- | Helper 58: refined neighbour offset.
{-@ offset58 :: {v:Int | -1 <= v && v <= 1} @-}
offset58 :: Int
offset58 = 0

-- | Helper 58: population bound for a 58-cell block.
{-@ popBound58 :: {v:Int | 0 <= v && v <= 58} @-}
popBound58 :: Int
popBound58 = 58


-- | Helper 59: refined neighbour offset.
{-@ offset59 :: {v:Int | -1 <= v && v <= 1} @-}
offset59 :: Int
offset59 = 1

-- | Helper 59: population bound for a 59-cell block.
{-@ popBound59 :: {v:Int | 0 <= v && v <= 59} @-}
popBound59 :: Int
popBound59 = 59


-- | Helper 60: refined neighbour offset.
{-@ offset60 :: {v:Int | -1 <= v && v <= 1} @-}
offset60 :: Int
offset60 = -1

-- | Helper 60: population bound for a 60-cell block.
{-@ popBound60 :: {v:Int | 0 <= v && v <= 60} @-}
popBound60 :: Int
popBound60 = 60


-- | Helper 61: refined neighbour offset.
{-@ offset61 :: {v:Int | -1 <= v && v <= 1} @-}
offset61 :: Int
offset61 = 0

-- | Helper 61: population bound for a 61-cell block.
{-@ popBound61 :: {v:Int | 0 <= v && v <= 61} @-}
popBound61 :: Int
popBound61 = 61


-- | Helper 62: refined neighbour offset.
{-@ offset62 :: {v:Int | -1 <= v && v <= 1} @-}
offset62 :: Int
offset62 = 1

-- | Helper 62: population bound for a 62-cell block.
{-@ popBound62 :: {v:Int | 0 <= v && v <= 62} @-}
popBound62 :: Int
popBound62 = 62


-- | Helper 63: refined neighbour offset.
{-@ offset63 :: {v:Int | -1 <= v && v <= 1} @-}
offset63 :: Int
offset63 = -1

-- | Helper 63: population bound for a 63-cell block.
{-@ popBound63 :: {v:Int | 0 <= v && v <= 63} @-}
popBound63 :: Int
popBound63 = 63


-- | Helper 64: refined neighbour offset.
{-@ offset64 :: {v:Int | -1 <= v && v <= 1} @-}
offset64 :: Int
offset64 = 0

-- | Helper 64: population bound for a 64-cell block.
{-@ popBound64 :: {v:Int | 0 <= v && v <= 64} @-}
popBound64 :: Int
popBound64 = 64


-- | Helper 65: refined neighbour offset.
{-@ offset65 :: {v:Int | -1 <= v && v <= 1} @-}
offset65 :: Int
offset65 = 1

-- | Helper 65: population bound for a 65-cell block.
{-@ popBound65 :: {v:Int | 0 <= v && v <= 65} @-}
popBound65 :: Int
popBound65 = 65


-- | Helper 66: refined neighbour offset.
{-@ offset66 :: {v:Int | -1 <= v && v <= 1} @-}
offset66 :: Int
offset66 = -1

-- | Helper 66: population bound for a 66-cell block.
{-@ popBound66 :: {v:Int | 0 <= v && v <= 66} @-}
popBound66 :: Int
popBound66 = 66


-- | Helper 67: refined neighbour offset.
{-@ offset67 :: {v:Int | -1 <= v && v <= 1} @-}
offset67 :: Int
offset67 = 0

-- | Helper 67: population bound for a 67-cell block.
{-@ popBound67 :: {v:Int | 0 <= v && v <= 67} @-}
popBound67 :: Int
popBound67 = 67


-- | Helper 68: refined neighbour offset.
{-@ offset68 :: {v:Int | -1 <= v && v <= 1} @-}
offset68 :: Int
offset68 = 1

-- | Helper 68: population bound for a 68-cell block.
{-@ popBound68 :: {v:Int | 0 <= v && v <= 68} @-}
popBound68 :: Int
popBound68 = 68


-- | Helper 69: refined neighbour offset.
{-@ offset69 :: {v:Int | -1 <= v && v <= 1} @-}
offset69 :: Int
offset69 = -1

-- | Helper 69: population bound for a 69-cell block.
{-@ popBound69 :: {v:Int | 0 <= v && v <= 69} @-}
popBound69 :: Int
popBound69 = 69


-- | Helper 70: refined neighbour offset.
{-@ offset70 :: {v:Int | -1 <= v && v <= 1} @-}
offset70 :: Int
offset70 = 0

-- | Helper 70: population bound for a 70-cell block.
{-@ popBound70 :: {v:Int | 0 <= v && v <= 70} @-}
popBound70 :: Int
popBound70 = 70


-- | Helper 71: refined neighbour offset.
{-@ offset71 :: {v:Int | -1 <= v && v <= 1} @-}
offset71 :: Int
offset71 = 1

-- | Helper 71: population bound for a 71-cell block.
{-@ popBound71 :: {v:Int | 0 <= v && v <= 71} @-}
popBound71 :: Int
popBound71 = 71


-- | Helper 72: refined neighbour offset.
{-@ offset72 :: {v:Int | -1 <= v && v <= 1} @-}
offset72 :: Int
offset72 = -1

-- | Helper 72: population bound for a 72-cell block.
{-@ popBound72 :: {v:Int | 0 <= v && v <= 72} @-}
popBound72 :: Int
popBound72 = 72


-- | Helper 73: refined neighbour offset.
{-@ offset73 :: {v:Int | -1 <= v && v <= 1} @-}
offset73 :: Int
offset73 = 0

-- | Helper 73: population bound for a 73-cell block.
{-@ popBound73 :: {v:Int | 0 <= v && v <= 73} @-}
popBound73 :: Int
popBound73 = 73


-- | Helper 74: refined neighbour offset.
{-@ offset74 :: {v:Int | -1 <= v && v <= 1} @-}
offset74 :: Int
offset74 = 1

-- | Helper 74: population bound for a 74-cell block.
{-@ popBound74 :: {v:Int | 0 <= v && v <= 74} @-}
popBound74 :: Int
popBound74 = 74


-- | Helper 75: refined neighbour offset.
{-@ offset75 :: {v:Int | -1 <= v && v <= 1} @-}
offset75 :: Int
offset75 = -1

-- | Helper 75: population bound for a 75-cell block.
{-@ popBound75 :: {v:Int | 0 <= v && v <= 75} @-}
popBound75 :: Int
popBound75 = 75


-- | Helper 76: refined neighbour offset.
{-@ offset76 :: {v:Int | -1 <= v && v <= 1} @-}
offset76 :: Int
offset76 = 0

-- | Helper 76: population bound for a 76-cell block.
{-@ popBound76 :: {v:Int | 0 <= v && v <= 76} @-}
popBound76 :: Int
popBound76 = 76


-- | Helper 77: refined neighbour offset.
{-@ offset77 :: {v:Int | -1 <= v && v <= 1} @-}
offset77 :: Int
offset77 = 1

-- | Helper 77: population bound for a 77-cell block.
{-@ popBound77 :: {v:Int | 0 <= v && v <= 77} @-}
popBound77 :: Int
popBound77 = 77


-- | Helper 78: refined neighbour offset.
{-@ offset78 :: {v:Int | -1 <= v && v <= 1} @-}
offset78 :: Int
offset78 = -1

-- | Helper 78: population bound for a 78-cell block.
{-@ popBound78 :: {v:Int | 0 <= v && v <= 78} @-}
popBound78 :: Int
popBound78 = 78


-- | Helper 79: refined neighbour offset.
{-@ offset79 :: {v:Int | -1 <= v && v <= 1} @-}
offset79 :: Int
offset79 = 0

-- | Helper 79: population bound for a 79-cell block.
{-@ popBound79 :: {v:Int | 0 <= v && v <= 79} @-}
popBound79 :: Int
popBound79 = 79
