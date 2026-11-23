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

(* ats/affine_stack.dats *)
#include "share/atspre_staload.hats"

dataviewtype aff_stack (n: int) =
  | AffNil (0) of ()
  | {n:nat} AffCons (n + 1) of (int, aff_stack (n))

extern fun aff_push {n:nat} (s: aff_stack(n), x: int): aff_stack(n + 1)
extern fun aff_pop  {n:pos} (s: aff_stack(n)): @(int, aff_stack(n - 1))
extern fun aff_drop {n:nat} (s: aff_stack(n)): void

implement aff_push (s, x) = AffCons (x, s)

implement aff_pop (s) =
  let val ~AffCons (x, rest) = s in @(x, rest) end

(* Affine escape hatch: safely free any remaining linear nodes *)
implement aff_drop (s) =
  case+ s of
  | ~AffNil ()         => ()
  | ~AffCons (_, rest) => aff_drop (rest)
