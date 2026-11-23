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

// cbits/dense_parlog.c
#include <stdint.h>
#include <stddef.h>

#define MAX_TERMS 65536
#define MAX_GOALS 64

typedef enum { D_INT = 0, D_VAR = 1, D_UNBOUND = 2 } DTag;

// Dense 64-bit tagged word: [payload: 61 bits | tag: 3 bits]
typedef uint64_t DWord;
static inline DWord mk_word(DTag t, int64_t val) {
    return ((uint64_t)val << 3) | (uint64_t)(t & 7);
}
static inline DTag    word_tag(DWord w) { return (DTag)(w & 7); }
static inline int64_t word_val(DWord w) { return (int64_t)w >> 3; }

typedef struct {
    uint32_t pred_id;
    uint32_t args[4];   // indices into term_arena
    uint8_t  arity;
    uint64_t wait_mask; // bit v = 1 => suspended on var v
} GoalSlot;

static DWord    term_arena[MAX_TERMS];
static uint32_t arena_top = 0;

static GoalSlot goals[MAX_GOALS];
static uint64_t active_mask = 0;
static uint64_t ready_mask  = 0;

uint32_t dense_alloc_var(void) {
    uint32_t idx = arena_top++;
    term_arena[idx] = mk_word(D_UNBOUND, 0);
    return idx;
}

uint32_t dense_alloc_int(int64_t v) {
    uint32_t idx = arena_top++;
    term_arena[idx] = mk_word(D_INT, v);
    return idx;
}

uint32_t dense_deref(uint32_t idx) {
    while (word_tag(term_arena[idx]) == D_VAR) {
        idx = (uint32_t)word_val(term_arena[idx]);
    }
    return idx;
}

void dense_spawn(uint32_t slot, uint32_t pred_id,
                 const uint32_t *args, uint8_t arity, uint64_t in_mask) {
    goals[slot].pred_id   = pred_id;
    goals[slot].arity     = arity;
    goals[slot].wait_mask = 0;
    for (uint8_t i = 0; i < arity; i++) {
        goals[slot].args[i] = args[i];
        if ((in_mask >> i) & 1ULL) {
            uint32_t d = dense_deref(args[i]);
            if (word_tag(term_arena[d]) == D_UNBOUND && d < 64) {
                goals[slot].wait_mask |= (1ULL << d);
            }
        }
    }
    active_mask |= (1ULL << slot);
    if (goals[slot].wait_mask == 0) ready_mask |= (1ULL << slot);
}

// Bind variable `var_idx` -> `val_idx` and wake all goals in O(active_goals) bitwise ops
void dense_bind(uint32_t var_idx, uint32_t val_idx) {
    term_arena[var_idx] = mk_word(D_VAR, (int64_t)val_idx);
    if (var_idx >= 64) return;
    uint64_t clear_bit = ~(1ULL << var_idx);
    uint64_t m = active_mask & ~ready_mask;
    while (m) {
        int g = __builtin_ctzll(m);
        m &= (m - 1);
        goals[g].wait_mask &= clear_bit;
        if (goals[g].wait_mask == 0) ready_mask |= (1ULL << g);
    }
}

// Pop next ready goal slot in O(1), or -1 if none ready
int dense_next_ready(void) {
    if (!ready_mask) return -1;
    int g = __builtin_ctzll(ready_mask);
    ready_mask  &= ~(1ULL << g);
    active_mask &= ~(1ULL << g);
    return g;
}
