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

module DenseParlog where

import Data.Bits ((.&.), (.|.), shiftL, complement)

-- ---------------------------------------------------------------------------
-- 1. Dense Tagged Words & Bitmask Scheduler
-- ---------------------------------------------------------------------------

data DTag = DInt | DVar | DUnbound
  deriving (Eq, Show)

-- Dense 64-bit tagged word: [payload | 3-bit tag]
type DWord = Int

mkWord :: DTag -> Int -> DWord
mkWord DInt     v = (v `shiftL` 3) .|. 0
mkWord DVar     v = (v `shiftL` 3) .|. 1
mkWord DUnbound _ = 2

wordTag :: DWord -> DTag
wordTag w = case w .&. 7 of
  0 -> DInt
  1 -> DVar
  _ -> DUnbound

wordVal :: DWord -> Int
wordVal w = w `div` 8

data GoalSlot = GoalSlot
  { gPred     :: String
  , gArgs     :: [Int]
  , gWaitMask :: Int     -- bit v = 1 => suspended on var v
  }

-- Clear variable bit `v` across all waiting goals in one pass
wakeVar :: Int -> [GoalSlot] -> ([GoalSlot], [GoalSlot])
wakeVar v = foldr step ([], [])
  where
    clearBitV = complement (1 `shiftL` v)
    step g (ready, waiting) =
      let m' = gWaitMask g .&. clearBitV
          g' = g { gWaitMask = m' }
      in if m' == 0 then (g' : ready, waiting) else (ready, g' : waiting)

-- ---------------------------------------------------------------------------
-- 2. Oz Concurrent Stack via Curry Dataflow Streams & Residuation
-- ---------------------------------------------------------------------------

data StackOp = Push Int | Pop Int

-- | Oz-style Port server: Pop carries a free logic variable `r`,
--   unified via (=:=) when the stack has an element.
ozStack :: [StackOp] -> [Int] -> Bool
ozStack []             _            = True
ozStack (Push x : ops) stk          = ensureNotFree x `seq` ozStack ops (x : stk)
ozStack (Pop r  : ops) (top : rest) = (r =:= top) &> ozStack ops rest

-- | Parlog-style AND-parallel producer/consumer using (&>) and free vars:
--   `printVal` residuates on `r` until `ozStack` binds it.
printVal :: Int -> IO ()
printVal x = putStrLn ("[Curry/Parlog] popped -> " ++ show (ensureNotFree x))

demoOzParlog :: IO ()
demoOzParlog = do
  let r   free
      ops = [Pop r, Push 42]
  if ozStack ops [] &> (ensureNotFree r > 0)
    then printVal r
    else putStrLn "Suspended"
