#ifndef __QPCC_QBE_ERRNO_H
#define __QPCC_QBE_ERRNO_H

// Values are macOS/BSD (from the SDK sys/errno.h). The bundled headers shadow
// the system ones through -I, so anything missing here is invisible to every
// file qpcc compiles.
// A declaration, not a definition: every translation unit includes this, and
// a definition here makes each object file define the symbol.
extern int errno;

#define EPERM 1
#define ENOENT 2
#define ESRCH 3
#define EINTR 4
#define EIO 5
#define ENXIO 6
#define E2BIG 7
#define ENOEXEC 8
#define EBADF 9
#define ECHILD 10
#define EDEADLK 11
#define ENOMEM 12
#define EACCES 13
#define EFAULT 14
#define ENOTBLK 15
#define EBUSY 16
#define EEXIST 17
#define EXDEV 18
#define ENODEV 19
#define ENOTDIR 20
#define EISDIR 21
#define EINVAL 22
#define ENFILE 23
#define EMFILE 24
#define ENOTTY 25
#define ETXTBSY 26
#define EFBIG 27
#define ENOSPC 28
#define ESPIPE 29
#define EROFS 30
#define EMLINK 31
#define EPIPE 32
#define EDOM 33
#define ERANGE 34
#define EAGAIN 35
#define EWOULDBLOCK EAGAIN
#define EINPROGRESS 36
#define EALREADY 37
#define ENOTSOCK 38
#define EDESTADDRREQ 39
#define EMSGSIZE 40
#define EPROTOTYPE 41
#define ENOPROTOOPT 42
#define EPROTONOSUPPORT 43
#define ENOTSUP 45
#define EOPNOTSUPP ENOTSUP
#define EAFNOSUPPORT 47
#define EADDRINUSE 48
#define EADDRNOTAVAIL 49
#define ENETDOWN 50
#define ENETUNREACH 51
#define ENETRESET 52
#define ECONNABORTED 53
#define ECONNRESET 54
#define ENOBUFS 55
#define EISCONN 56
#define ENOTCONN 57
#define ETIMEDOUT 60
#define ECONNREFUSED 61
#define EHOSTUNREACH 65
#define ENAMETOOLONG 63
#define EOVERFLOW 84
#define ECANCELED 89
#define EILSEQ 92

#endif /* __QPCC_QBE_ERRNO_H */
