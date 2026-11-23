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

module Quipper.SYK.Couplings where

-- | Reproducible Gaussian couplings J_{ijkl} for the q=4 SYK model.
--   Seeded so the same seed always yields the same interaction graph.
data Coupling = Coupling
  { indices :: (Int, Int, Int, Int)
  , value   :: Double
  }

-- | Generate a deterministic list of couplings from a seed and number of Majoranas.
generateCouplings :: Int -> Int -> [Coupling]
generateCouplings seed n =
  [ Coupling (i,j,k,l) (hash (seed,i,j,k,l) * scale)
  | i <- [0..n-1], j <- [i+1..n-1]
  , k <- [j+1..n-1], l <- [k+1..n-1]
  ]
  where
    scale = sqrt (6.0 / fromIntegral (n * (n-1) * (n-2) * (n-3)))
    hash (s,a,b,c,d) = fromIntegral ((s * 1664525 + a * 1013904223 + b * 22695477 + c * 214013 + d * 2531011) `mod` 1000) / 1000.0 - 0.5
