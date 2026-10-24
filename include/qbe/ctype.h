#ifndef __QPCC_QBE_CTYPE_H
#define __QPCC_QBE_CTYPE_H

int isdigit(int);
int isalpha(int);
int isalnum(int);
int isspace(int);
int isprint(int);
int isupper(int);
int islower(int);
int ispunct(int);
int isxdigit(int);
int tolower(int);
int toupper(int);
int iscntrl(int);
int isgraph(int);
int isblank(int);
int isascii(int);
int toascii(int);

/* Character class bits from Darwin's <ctype.h>. dash's mksyntax helper uses
   them directly to build its syntax table, and the bundled header shadows the
   system one, so they have to be visible here. */
#define _CTYPE_A 0x00000100L /* Alpha */
#define _CTYPE_C 0x00000200L /* Control */
#define _CTYPE_D 0x00000400L /* Digit */
#define _CTYPE_G 0x00000800L /* Graph */
#define _CTYPE_L 0x00001000L /* Lower */
#define _CTYPE_P 0x00002000L /* Punct */
#define _CTYPE_S 0x00004000L /* Space */
#define _CTYPE_U 0x00008000L /* Upper */
#define _CTYPE_X 0x00010000L /* X digit */
#define _CTYPE_B 0x00020000L /* Blank */
#define _CTYPE_R 0x00040000L /* Print */
#define _CTYPE_I 0x00080000L /* Ideogram */
#define _CTYPE_T 0x00100000L /* Special */
#define _CTYPE_Q 0x00200000L /* Phonogram */
#define _CTYPE_N 0x00400000L /* _Numeric */

#endif /* __QPCC_QBE_CTYPE_H */
