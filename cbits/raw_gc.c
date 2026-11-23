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

#include "raw_gc.h"
#include <stdlib.h>

#define MAX_ROOTS 4096
static Term **root_stack[MAX_ROOTS];
static size_t root_top = 0;
static Term *alloc_head = NULL;
static size_t live_count = 0, gc_threshold = 1024;

void gc_init(size_t threshold) { gc_threshold = threshold; }

void gc_push_root(Term **slot) {
    if (root_top < MAX_ROOTS) root_stack[root_top++] = slot;
}

void gc_pop_roots(size_t count) {
    root_top = (count <= root_top) ? (root_top - count) : 0;
}

static void mark(Term *t) {
    while (t && !t->marked) {
        t->marked = 1;
        if (t->tag == TAG_VAR) {
            t = t->data.binding;
        } else if (t->tag == TAG_CONS) {
            mark(t->data.cons.head);
            t = t->data.cons.tail; // tail-call optimize spine
        } else {
            break;
        }
    }
}

void gc_collect(void) {
    for (size_t i = 0; i < root_top; i++) mark(*root_stack[i]);

    Term **curr = &alloc_head;
    while (*curr) {
        Term *entry = *curr;
        if (!entry->marked) {
            *curr = entry->next_alloc;
            free(entry);
            live_count--;
        } else {
            entry->marked = 0;
            curr = &entry->next_alloc;
        }
    }
    gc_threshold = (live_count < 512) ? 1024 : live_count * 2;
}

Term *gc_alloc(TermTag tag) {
    if (live_count >= gc_threshold) gc_collect();
    Term *t = calloc(1, sizeof(Term));
    t->tag = tag;
    t->next_alloc = alloc_head;
    alloc_head = t;
    live_count++;
    return t;
}
