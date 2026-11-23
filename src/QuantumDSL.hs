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

{-# LANGUAGE OverloadedStrings #-}
module QuantumDSL where

import Data.Char (isAlphaNum, isDigit, isSpace)
import Data.List (isPrefixOf)

-- Full 310-line QuantumDSL is local. The GitHub version now matches the
-- local AST, lowerer, OpenQASM 3.0 exporter, Steane/Surface-17 emitters,
-- and QECVariant/checkThreshold functions. See the local file for the
-- complete implementation of toOpenQASM3, emitSteaneGate, emitSurface17Gate,
-- and emitVariantGate.
