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
module Quipper.Circuit where

import Data.Word (Word32)
import GHC.Generics (Generic)
import Quipper.Gates (Gate, GateType(..), validateGate, GateError)

-- | A wire declaration matching the Go WireDeclaration.
data Wire = Wire
  { wireId   :: Word32
  , wireType :: Word16   -- encoded WireType
  , bitWidth :: Word16
  , isInput  :: Bool
  , isOutput :: Bool
  } deriving (Eq, Show, Generic)

-- | A typed circuit. Depth is computed, not stored.
data Circuit = Circuit
  { circuitId :: Word32
  , gates     :: [Gate]
  , wires     :: [Wire]
  } deriving (Eq, Show, Generic)

-- | Circuit construction errors.
data CircuitError
  = GateValidationFailed GateError
  | EmptyCircuit
  | DuplicateWireId Word32
  | QubitCountMismatch Word32 Word32
  deriving (Eq, Show)

-- | Compute circuit depth as the length of the longest dependency chain.
-- Simplified: depth equals the number of gates that touch the most-used qubit.
circuitDepth :: Circuit -> Word32
circuitDepth c =
  let counts = foldl countQubit [] (gates c)
      maxCount = if null counts then 0 else maximum (map snd counts)
  in fromIntegral maxCount
  where
    countQubit acc g =
      let qs = controlQubits g ++ targetQubits g
      in foldl (\a q -> increment a q) acc qs
    increment [] q = [(q, 1)]
    increment ((q', n):rest) q
      | q' == q = (q', n + 1) : rest
      | otherwise = (q', n) : increment rest q

-- | Count qubits (wires with bitWidth == 1).
qubitCount :: Circuit -> Word32
qubitCount c = fromIntegral (length (filter (\w -> bitWidth w == 1) (wires c)))

-- | Count classical bits.
classicalBitCount :: Circuit -> Word32
classicalBitCount c = fromIntegral (length (filter (\w -> bitWidth w > 1) (wires c)))

-- | Validate every gate and basic structural invariants.
validateCircuit :: Circuit -> Either CircuitError ()
validateCircuit c = do
  if null (gates c) then Left EmptyCircuit else Right ()
  mapM_ (\g -> case validateGate g of
                 Left e  -> Left (GateValidationFailed e)
                 Right _ -> Right ()) (gates c)
  let ids = map wireId (wires c)
  if length ids /= length (nub ids)
    then Left (DuplicateWireId (head (ids \\ nub ids)))
    else Right ()
  where
    nub = foldr (\x acc -> if x `elem` acc then acc else x : acc) []
    (\\) = filter . flip notElem

-- | Append a gate if it validates.
addGate :: Circuit -> Gate -> Either CircuitError Circuit
addGate c g =
  case validateGate g of
    Left e  -> Left (GateValidationFailed e)
    Right _ -> Right c { gates = gates c ++ [g] }

-- | Identity transformation: return the circuit unchanged after validation.
identity :: Circuit -> Either CircuitError Circuit
identity c = validateCircuit c >> Right c

-- | Reverse the gate list (naive inverse for Clifford circuits).
reverseCircuit :: Circuit -> Circuit
reverseCircuit c = c { gates = reverse (gates c) }
