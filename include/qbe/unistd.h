#ifndef __QPCC_QBE_UNISTD_H
#define __QPCC_QBE_UNISTD_H
#define STDIN_FILENO 0
#define STDOUT_FILENO 1
#define STDERR_FILENO 2

// access() modes; the bundled headers shadow the system ones, so these and the
// declarations below have to be here or callers see them as implicit.
#define F_OK 0
#define X_OK 1
#define W_OK 2
#define R_OK 4

#include <stddef.h>
typedef long ssize_t;
typedef long off_t;
typedef int pid_t;

ssize_t read(int, void *, size_t);
ssize_t write(int, void *, size_t);
ssize_t pread(int, void *, size_t, off_t);
ssize_t pwrite(int, void *, size_t, off_t);
int close(int);
int unlink(char *);
int rmdir(char *);
int access(char *, int);
off_t lseek(int, off_t, int);
int isatty(int);
int dup(int);
int dup2(int, int);
int pipe(int *);
int chdir(char *);
char *getcwd(char *, size_t);
ssize_t readlink(char *, char *, size_t);
int symlink(char *, char *);
int link(char *, char *);
int getpid(void);
int getppid(void);
unsigned int getuid(void);
unsigned int getgid(void);
int gethostname(char *, size_t);
unsigned int sleep(unsigned int);
int usleep(unsigned int);
long sysconf(int);
void _exit(int);
int fsync(int);
int ftruncate(int, off_t);

#endif /* __QPCC_QBE_UNISTD_H */
