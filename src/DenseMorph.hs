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

{-# LANGUAGE LinearTypes #-}
{-# LANGUAGE ForeignFunctionInterface #-}

module DenseMorph where

import Data.Int (Int64)
import Data.Word (Word32, Word64, Word8)
import Foreign.Marshal.Array (withArray)
import Foreign.Ptr (Ptr)

foreign import ccall unsafe "dense_alloc_var"  c_dense_alloc_var  :: IO Word32
foreign import ccall unsafe "dense_alloc_int"  c_dense_alloc_int  :: Int64 -> IO Word32
foreign import ccall unsafe "dense_spawn"      c_dense_spawn      :: Word32 -> Word32 -> Ptr Word32 -> Word8 -> Word64 -> IO ()
foreign import ccall unsafe "dense_bind"       c_dense_bind       :: Word32 -> Word32 -> IO ()
foreign import ccall unsafe "dense_next_ready" c_dense_next_ready :: IO Int

-- | Linearly morph a sparse SGML goal list into dense GoalSlots.
morphGoalsDense :: Word32 -> [(Word32, [Word32], Word64)] -> IO ()
morphGoalsDense _ [] = pure ()
morphGoalsDense slot ((predId, args, inMask) : rest) = do
  withArray args $ \ptr ->
    c_dense_spawn slot predId ptr (fromIntegral (length args)) inMask
  morphGoalsDense (slot + 1) rest
