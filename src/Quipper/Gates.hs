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
module Quipper.Gates where

import Data.Word (Word16, Word32)
import GHC.Generics (Generic)

-- | Gate type enumeration matching Turing.go GateType constants.
data GateType
  = Hadamard
  | PauliX
  | PauliY
  | PauliZ
  | S
  | T
  | SGate
  | TGate
  | Rx
  | Ry
  | Rz
  | CNOT
  | CZ
  | SWAP
  | Toffoli
  | Measure
  | ControlledU
  | ControlledRz
  | QFT
  | QFTInverse
  deriving (Eq, Show, Enum, Bounded, Generic)

-- | Numeric code matching the Go iota values.
gateTypeCode :: GateType -> Word16
gateTypeCode = fromIntegral . fromEnum

-- | Inverse mapping. Returns Nothing for unknown codes.
fromGateTypeCode :: Word16 -> Maybe GateType
fromGateTypeCode n
  | n <= fromIntegral (fromEnum (maxBound :: GateType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Wire type matching Turing.go WireType.
data WireType = Qubit | Classical | Mixed
  deriving (Eq, Show, Enum, Bounded, Generic)

wireTypeCode :: WireType -> Word16
wireTypeCode = fromIntegral . fromEnum

fromWireTypeCode :: Word16 -> Maybe WireType
fromWireTypeCode n
  | n <= fromIntegral (fromEnum (maxBound :: WireType)) = Just (toEnum (fromIntegral n))
  | otherwise = Nothing

-- | Error codes for gate construction and validation.
data GateError
  = UnknownGateCode Word16
  | InvalidControlCount Word16
  | InvalidTargetCount Word16
  | MissingParameter GateType
  | UnexpectedParameter GateType
  deriving (Eq, Show)

-- | A typed quantum gate. Control and target lists are explicit.
data Gate = Gate
  { gateId       :: Word32
  , gateType     :: GateType
  , controlQubits :: [Word32]
  , targetQubits  :: [Word32]
  , parameter    :: Maybe Double
  } deriving (Eq, Show, Generic)

-- | Validate a gate against the type rules.
validateGate :: Gate -> Either GateError ()
validateGate g = do
  checkControls
  checkTargets
  checkParameter
  where
    checkControls =
      case gateType g of
        CNOT | length (controlQubits g) /= 1 -> Left (InvalidControlCount 1)
        CZ   | length (controlQubits g) /= 1 -> Left (InvalidControlCount 1)
        Toffoli | length (controlQubits g) /= 2 -> Left (InvalidControlCount 2)
        ControlledU | null (controlQubits g) -> Left (InvalidControlCount 1)
        ControlledRz | null (controlQubits g) -> Left (InvalidControlCount 1)
        _ -> Right ()
    checkTargets =
      case gateType g of
        Measure | length (targetQubits g) /= 1 -> Left (InvalidTargetCount 1)
        SWAP | length (targetQubits g) /= 2 -> Left (InvalidTargetCount 2)
        _ | null (targetQubits g) -> Left (InvalidTargetCount 1)
        _ -> Right ()
    checkParameter =
      case (gateType g, parameter g) of
        (Rx, Nothing) -> Left (MissingParameter Rx)
        (Ry, Nothing) -> Left (MissingParameter Ry)
        (Rz, Nothing) -> Left (MissingParameter Rz)
        (ControlledRz, Nothing) -> Left (MissingParameter ControlledRz)
        (Hadamard, Just _) -> Left (UnexpectedParameter Hadamard)
        (PauliX, Just _) -> Left (UnexpectedParameter PauliX)
        _ -> Right ()
