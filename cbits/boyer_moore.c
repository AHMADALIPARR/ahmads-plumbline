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

// cbits/boyer_moore.c
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>

ptrdiff_t bm_search_raw(const uint8_t *hay, size_t n,
                        const uint8_t *pat, size_t m) {
    if (m == 0) return 0;
    if (n < m)  return -1;

    // 1. Bad-character table
    size_t bad[256];
    for (size_t i = 0; i < 256; i++) bad[i] = m;
    for (size_t i = 0; i < m - 1; i++) bad[pat[i]] = m - 1 - i;

    // 2. Good-suffix table
    size_t *good   = malloc(m * sizeof(size_t));
    size_t *suffix = malloc(m * sizeof(size_t));
    if (!good || !suffix) { free(good); free(suffix); return -1; }

    suffix[m - 1] = m;
    ptrdiff_t g = (ptrdiff_t)m - 1, f = 0;
    for (ptrdiff_t i = (ptrdiff_t)m - 2; i >= 0; i--) {
        if (i > g && suffix[(size_t)(i + (ptrdiff_t)m - 1 - f)] < (size_t)(i - g)) {
            suffix[i] = suffix[(size_t)(i + (ptrdiff_t)m - 1 - f)];
        } else {
            if (i < g) g = i;
            f = i;
            while (g >= 0 && pat[g] == pat[g + (ptrdiff_t)m - 1 - f]) g--;
            suffix[i] = (size_t)(f - g);
        }
    }

    for (size_t i = 0; i < m; i++) good[i] = m;
    size_t j = 0;
    for (ptrdiff_t i = (ptrdiff_t)m - 1; i >= 0; i--) {
        if (suffix[i] == (size_t)(i + 1)) {
            for (; j < m - 1 - (size_t)i; j++) {
                if (good[j] == m) good[j] = m - 1 - (size_t)i;
            }
        }
    }
    for (size_t i = 0; i <= m - 2; i++) {
        good[m - 1 - suffix[i]] = m - 1 - i;
    }

    // 3. Scan haystack
    size_t s = 0;
    ptrdiff_t found = -1;
    while (s <= n - m) {
        ptrdiff_t k = (ptrdiff_t)m - 1;
        while (k >= 0 && pat[k] == hay[s + (size_t)k]) k--;
        if (k < 0) {
            found = (ptrdiff_t)s;
            break;
        }
        size_t bc = bad[hay[s + (size_t)k]];
        size_t gs = good[k];
        size_t shift_bc = (bc > m - 1 - (size_t)k) ? (bc - (m - 1 - (size_t)k)) : 1;
        s += (shift_bc > gs) ? shift_bc : gs;
    }

    free(good);
    free(suffix);
    return found;
}
