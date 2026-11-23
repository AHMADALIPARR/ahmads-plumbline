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

(* ats/linear_proofs.sats
 *
 * Static interface for the linear proofs.
 * All dataviewtypes are linear: they must be consumed exactly once.
 *)

#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

dataviewtype lin_stack (n: int)

fun lin_push {n:nat}
  (s: lin_stack(n), x: int): lin_stack(n + 1)

fun lin_pop {n:pos}
  (s: lin_stack(n)): @(int, lin_stack(n - 1))

fun lin_drop {n:nat}
  (s: lin_stack(n)): void

fun theorem_push_pop {n:nat}
  (s: lin_stack(n), x: int): @(int, lin_stack(n))

fun theorem_nil_length (): lin_stack(0)

dataviewtype lin_arena (cap: int)

fun arena_alloc {cap:nat}
  (a: lin_arena(cap)): @(int, lin_arena(cap))

fun arena_free {cap:nat}
  (a: lin_arena(cap)): void

dataviewtype lin_goal (ready: bool)

fun goal_spawn (pid: int): lin_goal(false)

fun goal_wake {b:bool}
  (g: lin_goal(b)): lin_goal(true)

fun goal_run (g: lin_goal(true)): void

fun linear_pipeline {n:nat}
  (s: lin_stack(n), x: int): void
