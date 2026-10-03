#ifndef __QPCC_QBE_STDDEF_H
#define __QPCC_QBE_STDDEF_H

typedef unsigned long size_t;
typedef long ptrdiff_t;
typedef unsigned int wchar_t;
#define NULL ((void *)0)
#define offsetof(t, m) __builtin_offsetof(t, m)

#endif /* __QPCC_QBE_STDDEF_H */
