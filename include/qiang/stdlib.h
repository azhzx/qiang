#ifndef __QPCC_QBE_STDLIB_H
#define __QPCC_QBE_STDLIB_H

#ifndef NULL
#define NULL ((void *)0)
#endif

#define EXIT_SUCCESS 0
#define EXIT_FAILURE 1
#define RAND_MAX 2147483647
#define MB_CUR_MAX 6
int system(char *);

#include <stddef.h>
void *malloc(size_t);
void *calloc(size_t, size_t);
void *realloc(void *, size_t);
void free(void *);
void exit(int);
void abort(void);
int abs(int);
int atoi(char *);
long atol(char *);
long strtol(char *, char **, int);
unsigned long strtoul(char *, char **, int);
double strtod(char *, char **);
void qsort(void *, size_t, size_t, int (*)(void *, void *));
char *getenv(char *);
int atexit(void (*)(void));

#endif /* __QPCC_QBE_STDLIB_H */
