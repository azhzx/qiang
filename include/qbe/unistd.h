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

// sysconf() names; the values are the Darwin ones (the bundled headers
// shadow the system <unistd.h>, so callers would otherwise see these as
// undeclared identifiers - sqlite3.c uses _SC_PAGESIZE).
#define _SC_ARG_MAX 1
#define _SC_OPEN_MAX 5
#define _SC_PAGESIZE 29
#define _SC_NPROCESSORS_ONLN 58
#define _SC_PHYS_PAGES 200
#define _SC_CLK_TCK 3

// BSD and macOS declare the getopt globals in <unistd.h>; lchat.c relies on
// that and never includes <getopt.h>, so without these it sees `optarg` as
// an undeclared identifier.
extern char *optarg;
extern int optind;
extern int opterr;
extern int optopt;
int getopt(int, char **, char *);

#endif /* __QPCC_QBE_UNISTD_H */
