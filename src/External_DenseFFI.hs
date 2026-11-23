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

{-# LANGUAGE ForeignFunctionInterface #-}
module External_DenseFFI where

import Basics (Cover, ConstStore, fromHaskellIO0, fromHaskellIO1, fromHaskellIO2)
import Curry_Prelude (C_IO, C_Int, OP_Unit, fromCurry, toCurry)
import Data.Int (Int64)
import Data.Word (Word32)

-- Raw C bindings to cbits/dense_parlog.c
foreign import ccall unsafe "dense_alloc_var"
  c_dense_alloc_var :: IO Word32

foreign import ccall unsafe "dense_alloc_int"
  c_dense_alloc_int :: Int64 -> IO Word32

foreign import ccall unsafe "dense_bind"
  c_dense_bind :: Word32 -> Word32 -> IO ()

foreign import ccall unsafe "dense_next_ready"
  c_dense_next_ready :: IO Int

-- KiCS2 external glue (Cover -> ConstStore -> C_IO ...)
external_d_C_cDenseAllocVar :: Cover -> ConstStore -> C_IO C_Int
external_d_C_cDenseAllocVar =
  fromHaskellIO0 (fmap (toCurry . (fromIntegral :: Word32 -> Int)) c_dense_alloc_var)

external_d_C_cDenseAllocInt :: C_Int -> Cover -> ConstStore -> C_IO C_Int
external_d_C_cDenseAllocInt n =
  fromHaskellIO1 (\x -> fmap (toCurry . (fromIntegral :: Word32 -> Int))
                             (c_dense_alloc_int (fromIntegral (fromCurry x :: Int)))) n

external_d_C_cDenseBind :: C_Int -> C_Int -> Cover -> ConstStore -> C_IO OP_Unit
external_d_C_cDenseBind v val =
  fromHaskellIO2 (\a b -> fmap toCurry
    (c_dense_bind (fromIntegral (fromCurry a :: Int))
                  (fromIntegral (fromCurry b :: Int)))) v val

external_d_C_cDenseNextReady :: Cover -> ConstStore -> C_IO C_Int
external_d_C_cDenseNextReady =
  fromHaskellIO0 (fmap toCurry c_dense_next_ready)
