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

{-# LANGUAGE DeriveGeneric #-}
module Quipper.Turing where

import Data.Word (Word16, Word32)
import GHC.Generics (Generic)
import Quipper.Circuit (Circuit, validateCircuit, CircuitError)
import Quipper.Gates (GateType, gateTypeCode)

-- | Error codes matching the Go side. Numeric values are stable.
data TuringError
  = ErrNone
  | ErrInvalidMagic
  | ErrUnsupportedVersion
  | ErrChecksumMismatch
  | ErrGateCountMismatch
  | ErrWireCountMismatch
  | ErrEmptyCircuit
  | ErrInvalidGate
  | ErrDuplicateWire
  | ErrQubitCountMismatch
  deriving (Eq, Show, Enum, Bounded, Generic)

errorCode :: TuringError -> Word16
errorCode = fromIntegral . fromEnum

fromErrorCode :: Word16 -> Maybe TuringError
fromErrorCode n
  | n <= fromIntegral (fromEnum (maxBound :: TuringError)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Map a CircuitError to a TuringError.
fromCircuitError :: CircuitError -> TuringError
fromCircuitError EmptyCircuit = ErrEmptyCircuit
fromCircuitError (GateValidationFailed _) = ErrInvalidGate
fromCircuitError (DuplicateWireId _) = ErrDuplicateWire
fromCircuitError (QubitCountMismatch _ _) = ErrQubitCountMismatch

-- | Semantic validation of a circuit. Returns the first error or ErrNone.
validateSemantics :: Circuit -> TuringError
validateSemantics c =
  case validateCircuit c of
    Left e  -> fromCircuitError e
    Right _ -> ErrNone

-- | Manifest metadata that Go serializes. Haskell only constructs and checks it.
data Manifest = Manifest
  { manifestId      :: Word32
  , jobId           :: Word32
  , circuitId       :: Word32
  , instructionCount :: Word32
  , maxRetries      :: Word16
  } deriving (Eq, Show, Generic)

validateManifest :: Manifest -> Either TuringError ()
validateManifest m
  | manifestId m == 0 = Left ErrInvalidMagic
  | circuitId m == 0  = Left ErrEmptyCircuit
  | maxRetries m > 100 = Left ErrUnsupportedVersion
  | otherwise = Right ()

-- | Execution trace summary.
data Trace = Trace
  { traceId      :: Word32
  , traceCircuit :: Word32
  , totalShots   :: Word32
  , successCount :: Word32
  } deriving (Eq, Show, Generic)

validateTrace :: Trace -> Either TuringError ()
validateTrace t
  | traceId t == 0 = Left ErrInvalidMagic
  | totalShots t == 0 = Left ErrEmptyCircuit
  | successCount t > totalShots t = Left ErrChecksumMismatch
  | otherwise = Right ()

-- | Gate-type code for interoperability with the Go binary format.
exportGateCode :: GateType -> Word16
exportGateCode = gateTypeCode
