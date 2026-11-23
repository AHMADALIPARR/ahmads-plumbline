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

#ifndef RAW_GC_H
#define RAW_GC_H
#include <stddef.h>
#include <stdint.h>

typedef enum { TAG_INT, TAG_VAR, TAG_CONS } TermTag;

typedef struct Term {
    uint8_t marked;
    TermTag tag;
    struct Term *next_alloc;
    union {
        int64_t ival;
        struct Term *binding; // NULL = unbound Parlog variable
        struct { struct Term *head; struct Term *tail; } cons;
    } data;
} Term;

void gc_init(size_t threshold);
void gc_push_root(Term **slot);
void gc_pop_roots(size_t count);
Term *gc_alloc(TermTag tag);
void gc_collect(void);

// Safe field accessors (avoid fragile Storable offsets)
TermTag term_tag(const Term *t);
void    term_set_int(Term *t, int64_t v);
int64_t term_get_int(const Term *t);
void    term_bind_var(Term *var, Term *val);
Term   *term_get_binding(const Term *var);
void    term_set_cons(Term *t, Term *head, Term *tail);
Term   *term_get_head(const Term *t);
Term   *term_get_tail(const Term *t);
#endif
