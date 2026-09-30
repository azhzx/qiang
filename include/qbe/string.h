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
