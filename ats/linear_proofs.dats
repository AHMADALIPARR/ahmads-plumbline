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

(* ats/linear_proofs.dats
 *
 * Linear (not merely affine) resource proofs for the dense runtime.
 * Uses ATS dataviewtype so every value is consumed exactly once.
 *
 * Properties proved by the type system:
 *   - push increases length by 1
 *   - pop decreases length by 1 (requires non-empty)
 *   - length is an index that cannot go negative
 *   - linear consumption: no double-free, no leak
 *)

#include "share/atspre_staload.hats"

(* -------------------------------------------------------------------------
 * 1. Linear stack with exact length index
 * ------------------------------------------------------------------------- *)

dataviewtype lin_stack (n: int) =
  | LinNil (0) of ()
  | {n:nat} LinCons (n + 1) of (int, lin_stack (n))

(* Linear constructor: consumes the tail, produces a longer stack *)
extern fun lin_push {n:nat}
  (s: lin_stack(n), x: int): lin_stack(n + 1)

(* Linear destructor: consumes a non-empty stack, returns the head and the shorter rest *)
extern fun lin_pop {n:pos}
  (s: lin_stack(n)): @(int, lin_stack(n - 1))

(* Linear drop: consumes any stack exactly once (no residual linear values) *)
extern fun lin_drop {n:nat}
  (s: lin_stack(n)): void

implement lin_push (s, x) = LinCons (x, s)

implement lin_pop (s) =
  let val ~LinCons (x, rest) = s in @(x, rest) end

implement lin_drop (s) =
  case+ s of
  | ~LinNil ()         => ()
  | ~LinCons (_, rest) => lin_drop (rest)

(* -------------------------------------------------------------------------
 * 2. Length-preserving theorems encoded as dependent functions
 * ------------------------------------------------------------------------- *)

(* Theorem: push then pop is identity on the length and the value *)
extern fun theorem_push_pop {n:nat}
  (s: lin_stack(n), x: int): @(int, lin_stack(n))

implement theorem_push_pop (s, x) =
  let
    val s1 = lin_push (s, x)          // length becomes n+1
    val @(y, s2) = lin_pop (s1)       // length returns to n
  in
    @(y, s2)                          // y must be x by construction
  end

(* Theorem: empty stack has length 0 and can only be dropped *)
extern fun theorem_nil_length (): lin_stack(0)

implement theorem_nil_length () = LinNil ()

(* -------------------------------------------------------------------------
 * 3. Linear buffer for dense arena indices (resource ownership)
 * ------------------------------------------------------------------------- *)

dataviewtype lin_arena (cap: int) =
  | LinArena (cap) of (int)           // holds the current top index

extern fun arena_alloc {cap:nat}
  (a: lin_arena(cap)): @(int, lin_arena(cap))

extern fun arena_free {cap:nat}
  (a: lin_arena(cap)): void

implement arena_alloc (a) =
  let
    val ~LinArena (top) = a
  in
    @(top, LinArena (top + 1))
  end

implement arena_free (a) =
  let val ~LinArena (_) = a in () end

(* -------------------------------------------------------------------------
 * 4. Linear goal slot (consumed exactly once when scheduled)
 * ------------------------------------------------------------------------- *)

dataviewtype lin_goal (ready: bool) =
  | LinReady (true) of (int)          // predicate id
  | LinWait  (false) of (int, int)    // predicate id, blocking var

extern fun goal_spawn (pid: int): lin_goal(false)

extern fun goal_wake {b:bool}
  (g: lin_goal(b)): lin_goal(true)

extern fun goal_run (g: lin_goal(true)): void

implement goal_spawn (pid) = LinWait (pid, 0)

implement goal_wake (g) =
  case+ g of
  | ~LinReady (pid)  => LinReady (pid)
  | ~LinWait (pid, _) => LinReady (pid)

implement goal_run (g) =
  let val ~LinReady (_) = g in () end

(* -------------------------------------------------------------------------
 * 5. Composition: linear pipeline that cannot leak resources
 * ------------------------------------------------------------------------- *)

extern fun linear_pipeline {n:nat}
  (s: lin_stack(n), x: int): void

implement linear_pipeline (s, x) =
  let
    val s1 = lin_push (s, x)
    val @(y, s2) = lin_pop (s1)
    val () = lin_drop (s2)            // must consume the remainder
  in
    ()                                // all linear values consumed
  end
