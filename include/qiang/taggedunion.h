#ifndef __QPCC_QBE_TAGGEDUNION_H
#define __QPCC_QBE_TAGGEDUNION_H

/*
 * QPCC -f_tagged_union: friendly spellings for the three tagged-union
 * keywords.  The keywords themselves stay opt-in, so this header is only
 * useful together with -f_tagged_union; without the flag the macros expand
 * to ordinary identifiers and the compiler reports a syntax error.
 */
#define tagunion _Tagged_union
#define static_tag _Static_tag
#define dynamic_tag _Dynamic_tag

#endif /* __QPCC_QBE_TAGGEDUNION_H */
