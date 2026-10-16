#ifndef __QPCC_QBE_UNISTD_H
#define __QPCC_QBE_UNISTD_H
#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

#include <stddef.h>
typedef long ssize_t;
ssize_t read(int, void *, size_t);
ssize_t write(int, void *, size_t);
int close(int);
int unlink(char *);

#endif /* __QPCC_QBE_UNISTD_H */
