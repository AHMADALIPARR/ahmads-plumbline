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

module Liquid.WorkBudget where

import Data.Word

-- | Constants matching the Rust spec
kb :: Double
kb = 1.380649e-23

ln2 :: Double
ln2 = 0.6931471805599453

{-@ type Joules = {v:Double | v >= 0.0} @-}

data WorkBudget = WorkBudget
  { landauerLimit      :: Double
  , wPrep              :: Double
  , wSort              :: Double
  , wErase             :: Double
  , wBatteryCoherence  :: Double
  , wBatteryExtract    :: Double
  , netExclPrep        :: Double
  , netInclPrep        :: Double
  , alphaSq            :: Double
  } deriving (Show)

{-@ coherentDemonWorkPerBit :: T:Double -> omega:Double -> hbar:Double -> WorkBudget @-}
coherentDemonWorkPerBit :: Double -> Double -> Double -> WorkBudget
coherentDemonWorkPerBit t omega hbar =
  let landauer = kb * t * ln2
      wPrep = landauer
      wSort = -landauer
      wErase = -landauer
      alphaSq = landauer / (hbar * omega)
      wBatteryCoherence = hbar * omega * alphaSq
      wBatteryExtract = -wBatteryCoherence
      netExclPrep = wSort + wErase + wBatteryExtract
      netInclPrep = wPrep + netExclPrep
  in WorkBudget
       { landauerLimit = landauer
       , wPrep = wPrep
       , wSort = wSort
       , wErase = wErase
       , wBatteryCoherence = wBatteryCoherence
       , wBatteryExtract = wBatteryExtract
       , netExclPrep = netExclPrep
       , netInclPrep = netInclPrep
       , alphaSq = alphaSq
       }

-- | Refinement: net including prep is -2 * landauer
{-@ netIsNegativeTwo :: b:WorkBudget -> {v:Bool | v <=> (netInclPrep b == -2.0 * landauerLimit b)} @-}
netIsNegativeTwo :: WorkBudget -> Bool
netIsNegativeTwo b = netInclPrep b == -2.0 * landauerLimit b
