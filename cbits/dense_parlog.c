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

// cbits/dense_parlog.c — optimized bit-parallel scheduling + dense Steane decoder
#include <stdint.h>
#include <stddef.h>

#define MAX_TERMS 65536
#define MAX_GOALS 64

typedef enum { D_INT = 0, D_VAR = 1, D_UNBOUND = 2 } DTag;

typedef uint64_t DWord;
static inline DWord mk_word(DTag t, int64_t val) {
    return ((uint64_t)val << 3) | (uint64_t)(t & 7);
}
static inline DTag    word_tag(DWord w) { return (DTag)(w & 7); }
static inline int64_t word_val(DWord w) { return (int64_t)w >> 3; }

typedef struct {
    uint32_t pred_id;
    uint32_t args[4];
    uint8_t  arity;
    uint64_t wait_mask;
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

void dense_bind(uint32_t var_idx, uint32_t val_idx) {
    term_arena[var_idx] = mk_word(D_VAR, (int64_t)val_idx);
    if (var_idx >= 64) return;

    uint64_t clear_bit = ~(1ULL << var_idx);
    uint64_t waiting = active_mask & ~ready_mask;

    while (waiting) {
        int g = __builtin_ctzll(waiting);
        waiting &= waiting - 1;
        uint64_t m = goals[g].wait_mask & clear_bit;
        goals[g].wait_mask = m;
        ready_mask |= (uint64_t)(m == 0) << g;
    }
}

int dense_next_ready(void) {
    uint64_t m = ready_mask;
    if (!m) return -1;
    int g = __builtin_ctzll(m);
    uint64_t bit = 1ULL << g;
    ready_mask  = m & ~bit;
    active_mask &= ~bit;
    return g;
}

int dense_drain_ready(int *out, int max) {
    int n = 0;
    while (n < max && ready_mask) {
        out[n++] = dense_next_ready();
    }
    return n;
}

// Dense Steane syndrome decoder (O(1))
uint64_t dense_steane_decode(uint64_t syn6) {
    uint32_t syn_x = (uint32_t)(syn6 & 7);
    uint32_t syn_z = (uint32_t)((syn6 >> 3) & 7);
    uint32_t err_x = syn_x ? syn_x : 0;
    uint32_t err_z = syn_z ? syn_z : 0;
    return ((uint64_t)err_x << 32) | err_z;
}

void dense_steane_correct(uint32_t base, uint64_t decoded) {
    uint32_t err_x = (uint32_t)(decoded >> 32);
    uint32_t err_z = (uint32_t)(decoded & 0xffffffff);
    if (err_x > 0 && err_x <= 7) { /* X correction on base+err_x-1 */ }
    if (err_z > 0 && err_z <= 7) { /* Z correction on base+err_z-1 */ }
}
