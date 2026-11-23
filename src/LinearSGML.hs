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
{-# LANGUAGE GADTs #-}
{-# LANGUAGE ForeignFunctionInterface #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE NoImplicitPrelude #-}

module LinearSGML where

import Prelude (IO, Int, Bool(..), ($), (+), (-), (<), (==), fromIntegral, pure)
import Data.Int (Int64)
import Data.Kind (Type)
import Data.Word (Word8)
import Foreign.C.Types (CSize(..), CPtrdiff(..))
import Foreign.Marshal.Alloc (mallocBytes, free)
import Foreign.Ptr (Ptr)

-- | Unrestricted wrapper (bridges LinearTypes <-> standard Haskell values).
data Ur a where
  Ur :: a -> Ur a

-- | Raw Linear Functor: maps a linear function over a linear container.
class LinFunctor (f :: Type -> Type) where
  fmapL :: (a %1 -> b) -> f a %1 -> f b

-- | Affine wrapper: pairs a linear value with an explicit drop capability.
data Aff a where
  Aff :: a %1 -> (a %1 -> ()) -> Aff a

dropAff :: Aff a %1 -> ()
dropAff (Aff x release) = release x

useAff :: Aff a %1 -> (a %1 -> Ur b) -> Ur b
useAff (Aff x _) k = k x

-- | Linearly-owned raw byte buffer (cannot be leaked or double-freed).
data LinBuf a where
  LinBuf :: Ptr a -> CSize -> LinBuf a

instance LinFunctor LinBuf where
  fmapL _ (LinBuf p n) = LinBuf p n

foreign import ccall unsafe "bm_search_raw"
  c_bm_search_raw :: Ptr Word8 -> CSize -> Ptr Word8 -> CSize -> IO CPtrdiff

-- | Allocates a linear buffer, runs a linear consumer, and frees it once.
withLinBuf :: CSize -> (LinBuf Word8 %1 -> IO (Ur b, LinBuf Word8)) -> IO b
withLinBuf sz k = do
  p <- mallocBytes (fromIntegral sz)
  (Ur res, LinBuf p' _) <- k (LinBuf p sz)
  free p'
  pure res

-- | Linear Boyer-Moore scan: borrows both buffers linearly and returns them intact.
bmScanLinear :: LinBuf Word8 %1 -> LinBuf Word8 %1 -> IO (Ur Int64, (LinBuf Word8, LinBuf Word8))
bmScanLinear (LinBuf hay hLen) (LinBuf pat pLen) = do
  off <- c_bm_search_raw hay hLen pat pLen
  pure (Ur (fromIntegral off), (LinBuf hay hLen, LinBuf pat pLen))
