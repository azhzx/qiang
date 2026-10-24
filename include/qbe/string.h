#ifndef __QPCC_QBE_STRING_H
#define __QPCC_QBE_STRING_H

#ifndef NULL
#define NULL ((void *)0)
#endif


#include <stddef.h>
void *memcpy(void *, void *, size_t);
void *memmove(void *, void *, size_t);
void *memset(void *, int, size_t);
int memcmp(void *, void *, size_t);
size_t strlen(char *);
char *strcpy(char *, char *);
char *strncpy(char *, char *, size_t);
char *strcat(char *, char *);
int strcmp(char *, char *);
int strncmp(char *, char *, size_t);
char *strchr(char *, int);
char *strrchr(char *, int);
char *strstr(char *, char *);
char *strdup(char *);
char *strerror(int);
/* The declarations below were missing, and an implicitly declared function
   returns int - so a pointer result was truncated to 32 bits. Lua's l_str2d
   calls strpbrk and crashed on any literal with a '.' in it. */
void *memchr(const void *, int, size_t);
char *strncat(char *, const char *, size_t);
char *strpbrk(const char *, const char *);
size_t strspn(const char *, const char *);
size_t strcspn(const char *, const char *);
char *strtok(char *, const char *);
int strcoll(const char *, const char *);
size_t strxfrm(char *, const char *, size_t);
int strcasecmp(const char *, const char *);
int strncasecmp(const char *, const char *, size_t);
char *strsignal(int);
void *memmem(const void *, size_t, const void *, size_t);
/* <strings.h> is not bundled; abduco calls __builtin_bzero, which maps to
   bzero, so the prototype has to be visible. */
void bzero(void *, size_t);

#endif /* __QPCC_QBE_STRING_H */
