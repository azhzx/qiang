typedef unsigned long size_t;
typedef long ptrdiff_t;
typedef unsigned int wchar_t;
typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long int64_t;
typedef unsigned long uint64_t;
typedef long intptr_t;
typedef unsigned long uintptr_t;
typedef long intmax_t;
typedef unsigned long uintmax_t;
int system(char *);
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
void bzero(void *, size_t);

int LLVMFuzzerTestOneInput(const uint8_t *src, size_t size);
 __attribute__((__const__)) unsigned XXH_versionNumber (void);
typedef enum {
    XXH_OK = 0,
    XXH_ERROR
} XXH_errorcode;
    typedef uint32_t XXH32_hash_t;
               __attribute__((__pure__)) XXH32_hash_t XXH32 (const void* input, size_t length, XXH32_hash_t seed);
typedef struct XXH32_state_s XXH32_state_t;
               __attribute__((__malloc__)) XXH32_state_t* XXH32_createState(void);
               XXH_errorcode XXH32_freeState(XXH32_state_t* statePtr);
               void XXH32_copyState(XXH32_state_t* dst_state, const XXH32_state_t* src_state);
               XXH_errorcode XXH32_reset (XXH32_state_t* statePtr, XXH32_hash_t seed);
               XXH_errorcode XXH32_update (XXH32_state_t* statePtr, const void* input, size_t length);
               __attribute__((__pure__)) XXH32_hash_t XXH32_digest (const XXH32_state_t* statePtr);
typedef struct {
    unsigned char digest[4];
} XXH32_canonical_t;
               void XXH32_canonicalFromHash(XXH32_canonical_t* dst, XXH32_hash_t hash);
               __attribute__((__pure__)) XXH32_hash_t XXH32_hashFromCanonical(const XXH32_canonical_t* src);
   typedef uint64_t XXH64_hash_t;
               __attribute__((__pure__)) XXH64_hash_t XXH64(__attribute__((__noescape__)) const void* input, size_t length, XXH64_hash_t seed);
typedef struct XXH64_state_s XXH64_state_t;
               __attribute__((__malloc__)) XXH64_state_t* XXH64_createState(void);
               XXH_errorcode XXH64_freeState(XXH64_state_t* statePtr);
               void XXH64_copyState(__attribute__((__noescape__)) XXH64_state_t* dst_state, const XXH64_state_t* src_state);
               XXH_errorcode XXH64_reset (__attribute__((__noescape__)) XXH64_state_t* statePtr, XXH64_hash_t seed);
               XXH_errorcode XXH64_update (__attribute__((__noescape__)) XXH64_state_t* statePtr, __attribute__((__noescape__)) const void* input, size_t length);
               __attribute__((__pure__)) XXH64_hash_t XXH64_digest (__attribute__((__noescape__)) const XXH64_state_t* statePtr);
typedef struct { unsigned char digest[sizeof(XXH64_hash_t)]; } XXH64_canonical_t;
               void XXH64_canonicalFromHash(__attribute__((__noescape__)) XXH64_canonical_t* dst, XXH64_hash_t hash);
               __attribute__((__pure__)) XXH64_hash_t XXH64_hashFromCanonical(__attribute__((__noescape__)) const XXH64_canonical_t* src);
               __attribute__((__pure__)) XXH64_hash_t XXH3_64bits(__attribute__((__noescape__)) const void* input, size_t length);
               __attribute__((__pure__)) XXH64_hash_t XXH3_64bits_withSeed(__attribute__((__noescape__)) const void* input, size_t length, XXH64_hash_t seed);
               __attribute__((__pure__)) XXH64_hash_t XXH3_64bits_withSecret(__attribute__((__noescape__)) const void* data, size_t len, __attribute__((__noescape__)) const void* secret, size_t secretSize);
typedef struct XXH3_state_s XXH3_state_t;
               __attribute__((__malloc__)) XXH3_state_t* XXH3_createState(void);
               XXH_errorcode XXH3_freeState(XXH3_state_t* statePtr);
               void XXH3_copyState(__attribute__((__noescape__)) XXH3_state_t* dst_state, __attribute__((__noescape__)) const XXH3_state_t* src_state);
               XXH_errorcode XXH3_64bits_reset(__attribute__((__noescape__)) XXH3_state_t* statePtr);
               XXH_errorcode XXH3_64bits_reset_withSeed(__attribute__((__noescape__)) XXH3_state_t* statePtr, XXH64_hash_t seed);
               XXH_errorcode XXH3_64bits_reset_withSecret(__attribute__((__noescape__)) XXH3_state_t* statePtr, __attribute__((__noescape__)) const void* secret, size_t secretSize);
               XXH_errorcode XXH3_64bits_update (__attribute__((__noescape__)) XXH3_state_t* statePtr, __attribute__((__noescape__)) const void* input, size_t length);
               __attribute__((__pure__)) XXH64_hash_t XXH3_64bits_digest (__attribute__((__noescape__)) const XXH3_state_t* statePtr);
typedef struct {
    XXH64_hash_t low64;
    XXH64_hash_t high64;
} XXH128_hash_t;
               __attribute__((__pure__)) XXH128_hash_t XXH3_128bits(__attribute__((__noescape__)) const void* data, size_t len);
               __attribute__((__pure__)) XXH128_hash_t XXH3_128bits_withSeed(__attribute__((__noescape__)) const void* data, size_t len, XXH64_hash_t seed);
               __attribute__((__pure__)) XXH128_hash_t XXH3_128bits_withSecret(__attribute__((__noescape__)) const void* data, size_t len, __attribute__((__noescape__)) const void* secret, size_t secretSize);
               XXH_errorcode XXH3_128bits_reset(__attribute__((__noescape__)) XXH3_state_t* statePtr);
               XXH_errorcode XXH3_128bits_reset_withSeed(__attribute__((__noescape__)) XXH3_state_t* statePtr, XXH64_hash_t seed);
               XXH_errorcode XXH3_128bits_reset_withSecret(__attribute__((__noescape__)) XXH3_state_t* statePtr, __attribute__((__noescape__)) const void* secret, size_t secretSize);
               XXH_errorcode XXH3_128bits_update (__attribute__((__noescape__)) XXH3_state_t* statePtr, __attribute__((__noescape__)) const void* input, size_t length);
               __attribute__((__pure__)) XXH128_hash_t XXH3_128bits_digest (__attribute__((__noescape__)) const XXH3_state_t* statePtr);
               __attribute__((__pure__)) int XXH128_isEqual(XXH128_hash_t h1, XXH128_hash_t h2);
               __attribute__((__pure__)) int XXH128_cmp(__attribute__((__noescape__)) const void* h128_1, __attribute__((__noescape__)) const void* h128_2);
typedef struct { unsigned char digest[sizeof(XXH128_hash_t)]; } XXH128_canonical_t;
               void XXH128_canonicalFromHash(__attribute__((__noescape__)) XXH128_canonical_t* dst, XXH128_hash_t hash);
               __attribute__((__pure__)) XXH128_hash_t XXH128_hashFromCanonical(__attribute__((__noescape__)) const XXH128_canonical_t* src);

typedef struct _IO_FILE FILE;
extern FILE *__stdinp;
extern FILE *__stdoutp;
extern FILE *__stderrp;
int printf(char *, ...);
int fprintf(FILE *, char *, ...);
int sprintf(char *, char *, ...);
int snprintf(char *, size_t, char *, ...);
int vfprintf(FILE *, char *, __builtin_va_list);
int vprintf(char *, __builtin_va_list);
int vsnprintf(char *, size_t, char *, __builtin_va_list);
int vsprintf(char *, char *, __builtin_va_list);
int puts(char *);
int fputs(char *, FILE *);
int fputc(int, FILE *);
int putchar(int);
int fgetc(FILE *);
int getc(FILE *);
int ungetc(int, FILE *);
int fscanf(FILE *, char *, ...);
int sscanf(char *, char *, ...);
int scanf(char *, ...);
int fputc(int, FILE *);
int putc(int, FILE *);
char *fgets(char *, int, FILE *);
FILE *fopen(char *, char *);
int fclose(FILE *);
int fflush(FILE *);
size_t fread(void *, size_t, size_t, FILE *);
size_t fwrite(void *, size_t, size_t, FILE *);
int remove(char *);
int rename(char *, char *);
int fseek(FILE *, long, int);
long ftell(FILE *);
int feof(FILE *);
int ferror(FILE *);
void clearerr(FILE *);
int setvbuf(FILE *, char *, int, size_t);
FILE *freopen(char *, char *, FILE *);
FILE *tmpfile(void);
char *tmpnam(char *);
__attribute__ ((visibility ("default"))) int LZ4_versionNumber (void);
__attribute__ ((visibility ("default"))) const char* LZ4_versionString (void);
__attribute__ ((visibility ("default"))) int LZ4_compress_default(const char* src, char* dst, int srcSize, int dstCapacity);
__attribute__ ((visibility ("default"))) int LZ4_decompress_safe (const char* src, char* dst, int compressedSize, int dstCapacity);
__attribute__ ((visibility ("default"))) int LZ4_compressBound(int inputSize);
__attribute__ ((visibility ("default"))) int LZ4_compress_fast (const char* src, char* dst, int srcSize, int dstCapacity, int acceleration);
__attribute__ ((visibility ("default"))) int LZ4_sizeofState(void);
__attribute__ ((visibility ("default"))) int LZ4_compress_fast_extState (void* state, const char* src, char* dst, int srcSize, int dstCapacity, int acceleration);
__attribute__ ((visibility ("default"))) int LZ4_compress_destSize(const char* src, char* dst, int* srcSizePtr, int targetDstSize);
__attribute__ ((visibility ("default"))) int LZ4_decompress_safe_partial (const char* src, char* dst, int srcSize, int targetOutputSize, int dstCapacity);
typedef union LZ4_stream_u LZ4_stream_t;
__attribute__ ((visibility ("default"))) LZ4_stream_t* LZ4_createStream(void);
__attribute__ ((visibility ("default"))) int LZ4_freeStream (LZ4_stream_t* streamPtr);
__attribute__ ((visibility ("default"))) void LZ4_resetStream_fast (LZ4_stream_t* streamPtr);
__attribute__ ((visibility ("default"))) int LZ4_loadDict (LZ4_stream_t* streamPtr, const char* dictionary, int dictSize);
__attribute__ ((visibility ("default"))) int LZ4_loadDictSlow(LZ4_stream_t* streamPtr, const char* dictionary, int dictSize);
__attribute__ ((visibility ("default"))) void
LZ4_attach_dictionary(LZ4_stream_t* workingStream,
                const LZ4_stream_t* dictionaryStream);
__attribute__ ((visibility ("default"))) int LZ4_compress_fast_continue (LZ4_stream_t* streamPtr, const char* src, char* dst, int srcSize, int dstCapacity, int acceleration);
__attribute__ ((visibility ("default"))) int LZ4_saveDict (LZ4_stream_t* streamPtr, char* safeBuffer, int maxDictSize);
typedef union LZ4_streamDecode_u LZ4_streamDecode_t;
__attribute__ ((visibility ("default"))) LZ4_streamDecode_t* LZ4_createStreamDecode(void);
__attribute__ ((visibility ("default"))) int LZ4_freeStreamDecode (LZ4_streamDecode_t* LZ4_stream);
__attribute__ ((visibility ("default"))) int LZ4_setStreamDecode (LZ4_streamDecode_t* LZ4_streamDecode, const char* dictionary, int dictSize);
__attribute__ ((visibility ("default"))) int LZ4_decoderRingBufferSize(int maxBlockSize);
__attribute__ ((visibility ("default"))) int
LZ4_decompress_safe_continue (LZ4_streamDecode_t* LZ4_streamDecode,
                        const char* src, char* dst,
                        int srcSize, int dstCapacity);
__attribute__ ((visibility ("default"))) int
LZ4_decompress_safe_usingDict(const char* src, char* dst,
                              int srcSize, int dstCapacity,
                              const char* dictStart, int dictSize);
__attribute__ ((visibility ("default"))) int
LZ4_decompress_safe_partial_usingDict(const char* src, char* dst,
                                      int compressedSize,
                                      int targetOutputSize, int maxOutputSize,
                                      const char* dictStart, int dictSize);
                  int LZ4_compress_fast_extState_fastReset (void* state, const char* src, char* dst, int srcSize, int dstCapacity, int acceleration);
int LZ4_compress_destSize_extState(void* state, const char* src, char* dst, int* srcSizePtr, int targetDstSize, int acceleration);
  typedef int8_t LZ4_i8;
  typedef unsigned char LZ4_byte;
  typedef uint16_t LZ4_u16;
  typedef uint32_t LZ4_u32;
typedef struct LZ4_stream_t_internal LZ4_stream_t_internal;
struct LZ4_stream_t_internal {
    LZ4_u32 hashTable[(1 << (14 -2))];
    const LZ4_byte* dictionary;
    const LZ4_stream_t_internal* dictCtx;
    LZ4_u32 currentOffset;
    LZ4_u32 tableType;
    LZ4_u32 dictSize;
};
union LZ4_stream_u {
    char minStateSize[((1UL << (14)) + 32)];
    LZ4_stream_t_internal internal_donotuse;
};
__attribute__ ((visibility ("default"))) LZ4_stream_t* LZ4_initStream (void* stateBuffer, size_t size);
typedef struct {
    const LZ4_byte* externalDict;
    const LZ4_byte* prefixEnd;
    size_t extDictSize;
    size_t prefixSize;
} LZ4_streamDecode_t_internal;
union LZ4_streamDecode_u {
    char minStateSize[32];
    LZ4_streamDecode_t_internal internal_donotuse;
} ;
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress (const char* src, char* dest, int srcSize);
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress_limitedOutput (const char* src, char* dest, int srcSize, int maxOutputSize);
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress_withState (void* state, const char* source, char* dest, int inputSize);
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress_limitedOutput_withState (void* state, const char* source, char* dest, int inputSize, int maxOutputSize);
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress_continue (LZ4_stream_t* LZ4_streamPtr, const char* source, char* dest, int inputSize);
                                                           __attribute__ ((visibility ("default"))) int LZ4_compress_limitedOutput_continue (LZ4_stream_t* LZ4_streamPtr, const char* source, char* dest, int inputSize, int maxOutputSize);
                                                    __attribute__ ((visibility ("default"))) int LZ4_uncompress (const char* source, char* dest, int outputSize);
                                                    __attribute__ ((visibility ("default"))) int LZ4_uncompress_unknownOutputSize (const char* source, char* dest, int isize, int maxOutputSize);
                                                 __attribute__ ((visibility ("default"))) void* LZ4_create (char* inputBuffer);
                                                 __attribute__ ((visibility ("default"))) int LZ4_sizeofStreamState(void);
                                                 __attribute__ ((visibility ("default"))) int LZ4_resetStreamState(void* state, char* inputBuffer);
                                                 __attribute__ ((visibility ("default"))) char* LZ4_slideInputBuffer (void* state);
                                                              __attribute__ ((visibility ("default"))) int LZ4_decompress_safe_withPrefix64k (const char* src, char* dst, int compressedSize, int maxDstSize);
                                                              __attribute__ ((visibility ("default"))) int LZ4_decompress_fast_withPrefix64k (const char* src, char* dst, int originalSize);
__attribute__ ((visibility ("default"))) int LZ4_decompress_fast (const char* src, char* dst, int originalSize);
__attribute__ ((visibility ("default"))) int LZ4_decompress_fast_continue (LZ4_streamDecode_t* LZ4_streamDecode, const char* src, char* dst, int originalSize);
__attribute__ ((visibility ("default"))) int LZ4_decompress_fast_usingDict (const char* src, char* dst, int originalSize, const char* dictStart, int dictSize);
__attribute__ ((visibility ("default"))) void LZ4_resetStream (LZ4_stream_t* streamPtr);
static const int LZ4_minLength = (12 +1);
static int LZ4_isAligned(const void* ptr, size_t alignment)
{
    return ((size_t)ptr & (alignment -1)) == 0;
}
 typedef unsigned char BYTE;
  typedef uint16_t U16;
  typedef uint32_t U32;
  typedef int32_t S32;
  typedef uint64_t U64;
  typedef uintptr_t uptrval;
  typedef size_t reg_t;
typedef enum {
    notLimited = 0,
    limitedOutput = 1,
    fillOutput = 2
} limitedOutput_directive;
static unsigned LZ4_isLittleEndian(void)
{
    const union { U32 u; BYTE c[4]; } one = { 1 };
    return one.c[0];
}
typedef struct { U16 u16; } __attribute__((__packed__)) LZ4_unalign16;
typedef struct { U32 u32; } __attribute__((__packed__)) LZ4_unalign32;
typedef struct { reg_t uArch; } __attribute__((__packed__)) LZ4_unalignST;
static U16 LZ4_read16(const void* ptr) { return ((const LZ4_unalign16*)ptr)->u16; }
static U32 LZ4_read32(const void* ptr) { return ((const LZ4_unalign32*)ptr)->u32; }
static reg_t LZ4_read_ARCH(const void* ptr) { return ((const LZ4_unalignST*)ptr)->uArch; }
static void LZ4_write16(void* memPtr, U16 value) { ((LZ4_unalign16*)memPtr)->u16 = value; }
static void LZ4_write32(void* memPtr, U32 value) { ((LZ4_unalign32*)memPtr)->u32 = value; }
static U16 LZ4_readLE16(const void* memPtr)
{
    if (LZ4_isLittleEndian()) {
        return LZ4_read16(memPtr);
    } else {
        const BYTE* p = (const BYTE*)memPtr;
        return (U16)((U16)p[0] | (p[1]<<8));
    }
}
static void LZ4_writeLE16(void* memPtr, U16 value)
{
    if (LZ4_isLittleEndian()) {
        LZ4_write16(memPtr, value);
    } else {
        BYTE* p = (BYTE*)memPtr;
        p[0] = (BYTE) value;
        p[1] = (BYTE)(value>>8);
    }
}
static inline __attribute__((always_inline))
void LZ4_wildCopy8(void* dstPtr, const void* srcPtr, void* dstEnd)
{
    BYTE* d = (BYTE*)dstPtr;
    const BYTE* s = (const BYTE*)srcPtr;
    BYTE* const e = (BYTE*)dstEnd;
    do { __builtin_memcpy(d, s, 8); d+=8; s+=8; } while (d<e);
}
static const unsigned inc32table[8] = {0, 1, 2, 1, 0, 4, 4, 4};
static const int dec64table[8] = {0, 0, 0, -1, -4, 1, 2, 3};
static inline __attribute__((always_inline)) void
LZ4_memcpy_using_offset_base(BYTE* dstPtr, const BYTE* srcPtr, BYTE* dstEnd, const size_t offset)
{
    ((void)0);
    if (offset < 8) {
        LZ4_write32(dstPtr, 0);
        ((void)0);
        __builtin_memcpy(dstPtr, srcPtr, 2);
        __builtin_memcpy(dstPtr + 2, srcPtr + 2, 2);
        srcPtr += inc32table[offset];
        __builtin_memcpy(dstPtr+4, srcPtr, 4);
        srcPtr -= dec64table[offset];
        dstPtr += 8;
    } else {
        __builtin_memcpy(dstPtr, srcPtr, 8);
        dstPtr += 8;
        srcPtr += 8;
    }
    LZ4_wildCopy8(dstPtr, srcPtr, dstEnd);
}
static inline __attribute__((always_inline)) void
LZ4_wildCopy64(void* dstPtr, const void* srcPtr, void* dstEnd)
{
    BYTE* d = (BYTE*)dstPtr;
    const BYTE* s = (const BYTE*)srcPtr;
    BYTE* const e = (BYTE*)dstEnd;
    do { __builtin_memcpy(d, s, 64); d+=64; s+=64; } while (d<e);
}
static inline __attribute__((always_inline)) void
LZ4_wildCopy32(void* dstPtr, const void* srcPtr, void* dstEnd)
{
    BYTE* d = (BYTE*)dstPtr;
    const BYTE* s = (const BYTE*)srcPtr;
    BYTE* const e = (BYTE*)dstEnd;
    do { __builtin_memcpy(d, s, 16); __builtin_memcpy(d+16, s+16, 16); d+=32; s+=32; } while (d<e);
}
static inline __attribute__((always_inline)) void
LZ4_memcpy_using_offset(BYTE* dstPtr, const BYTE* srcPtr, BYTE* dstEnd, const size_t offset)
{
    BYTE v[8];
    ((void)0);
    switch(offset) {
    case 1:
        memset(((v)),((*srcPtr)),((8)));
        break;
    case 2:
        __builtin_memcpy(v, srcPtr, 2);
        __builtin_memcpy(&v[2], srcPtr, 2);
        __builtin_memcpy(&v[4], v, 4);
        break;
    case 4:
        __builtin_memcpy(v, srcPtr, 4);
        __builtin_memcpy(&v[4], srcPtr, 4);
        break;
    default:
        LZ4_memcpy_using_offset_base(dstPtr, srcPtr, dstEnd, offset);
        return;
    }
    __builtin_memcpy(dstPtr, v, 8);
    dstPtr += 8;
    while (dstPtr < dstEnd) {
        __builtin_memcpy(dstPtr, v, 8);
        dstPtr += 8;
    }
}
static unsigned LZ4_NbCommonBytes (reg_t val)
{
    ((void)0);
    if (LZ4_isLittleEndian()) {
        if (sizeof(val) == 8) {
            return (unsigned)__builtin_ctzll((U64)val) >> 3;
        } else {
            return (unsigned)__builtin_ctz((U32)val) >> 3;
        }
    } else {
        if (sizeof(val)==8) {
            return (unsigned)__builtin_clzll((U64)val) >> 3;
        } else {
            return (unsigned)__builtin_clz((U32)val) >> 3;
        }
    }
}
static inline __attribute__((always_inline))
unsigned LZ4_count(const BYTE* pIn, const BYTE* pMatch, const BYTE* pInLimit)
{
    const BYTE* const pStart = pIn;
    if ((__builtin_expect (((pIn < pInLimit-(sizeof(reg_t)-1)) != 0),(1)) )) {
        reg_t const diff = LZ4_read_ARCH(pMatch) ^ LZ4_read_ARCH(pIn);
        if (!diff) {
            pIn+=sizeof(reg_t); pMatch+=sizeof(reg_t);
        } else {
            return LZ4_NbCommonBytes(diff);
    } }
    while ((__builtin_expect (((pIn < pInLimit-(sizeof(reg_t)-1)) != 0),(1)) )) {
        reg_t const diff = LZ4_read_ARCH(pMatch) ^ LZ4_read_ARCH(pIn);
        if (!diff) { pIn+=sizeof(reg_t); pMatch+=sizeof(reg_t); continue; }
        pIn += LZ4_NbCommonBytes(diff);
        return (unsigned)(pIn - pStart);
    }
    if ((sizeof(reg_t)==8) && (pIn<(pInLimit-3)) && (LZ4_read32(pMatch) == LZ4_read32(pIn))) { pIn+=4; pMatch+=4; }
    if ((pIn<(pInLimit-1)) && (LZ4_read16(pMatch) == LZ4_read16(pIn))) { pIn+=2; pMatch+=2; }
    if ((pIn<pInLimit) && (*pMatch == *pIn)) pIn++;
    return (unsigned)(pIn - pStart);
}
static __inline __attribute__((unused)) uint32_t FUZZ_seed(uint8_t const **src, size_t* size) {
    uint8_t const *data = *src;
    size_t const toHash = ( (4) < (*size) ? (4) : (*size) );
    *size -= toHash;
    *src += toHash;
    return XXH32(data, toHash, 0);
}
static __inline __attribute__((unused)) uint32_t FUZZ_rand(uint32_t *state) {
    static const uint32_t prime1 = 2654435761U;
    static const uint32_t prime2 = 2246822519U;
    uint32_t rand32 = *state;
    rand32 *= prime1;
    rand32 += prime2;
    rand32 = (((rand32) << (13)) | ((rand32) >> (32 - (13))));
    *state = rand32;
    return rand32 >> 5;
}
static __inline __attribute__((unused)) uint32_t FUZZ_rand32(uint32_t *state, uint32_t min, uint32_t max) {
    uint32_t random = FUZZ_rand(state);
    return min + (random % (max - min + 1));
}
typedef size_t LZ4F_errorCode_t;
__attribute__ ((visibility ("default"))) unsigned LZ4F_isError(LZ4F_errorCode_t code);
__attribute__ ((visibility ("default"))) const char* LZ4F_getErrorName(LZ4F_errorCode_t code);
typedef enum {
    LZ4F_default=0,
    LZ4F_max64KB=4,
    LZ4F_max256KB=5,
    LZ4F_max1MB=6,
    LZ4F_max4MB=7
} LZ4F_blockSizeID_t;
typedef enum {
    LZ4F_blockLinked=0,
    LZ4F_blockIndependent
} LZ4F_blockMode_t;
typedef enum {
    LZ4F_noContentChecksum=0,
    LZ4F_contentChecksumEnabled
} LZ4F_contentChecksum_t;
typedef enum {
    LZ4F_noBlockChecksum=0,
    LZ4F_blockChecksumEnabled
} LZ4F_blockChecksum_t;
typedef enum {
    LZ4F_frame=0,
    LZ4F_skippableFrame
} LZ4F_frameType_t;
typedef struct {
  LZ4F_blockSizeID_t blockSizeID;
  LZ4F_blockMode_t blockMode;
  LZ4F_contentChecksum_t contentChecksumFlag;
  LZ4F_frameType_t frameType;
  unsigned long long contentSize;
  unsigned dictID;
  LZ4F_blockChecksum_t blockChecksumFlag;
} LZ4F_frameInfo_t;
typedef struct {
  LZ4F_frameInfo_t frameInfo;
  int compressionLevel;
  unsigned autoFlush;
  unsigned favorDecSpeed;
  unsigned reserved[3];
} LZ4F_preferences_t;
__attribute__ ((visibility ("default"))) size_t LZ4F_compressFrame(void* dstBuffer, size_t dstCapacity,
                                const void* srcBuffer, size_t srcSize,
                                const LZ4F_preferences_t* preferencesPtr);
__attribute__ ((visibility ("default"))) size_t LZ4F_compressFrameBound(size_t srcSize, const LZ4F_preferences_t* preferencesPtr);
__attribute__ ((visibility ("default"))) int LZ4F_compressionLevel_max(void);
typedef struct LZ4F_cctx_s LZ4F_cctx;
typedef LZ4F_cctx* LZ4F_compressionContext_t;
typedef struct {
  unsigned stableSrc;
  unsigned reserved[3];
} LZ4F_compressOptions_t;
__attribute__ ((visibility ("default"))) unsigned LZ4F_getVersion(void);
__attribute__ ((visibility ("default"))) LZ4F_errorCode_t LZ4F_createCompressionContext(LZ4F_cctx** cctxPtr, unsigned version);
__attribute__ ((visibility ("default"))) LZ4F_errorCode_t LZ4F_freeCompressionContext(LZ4F_cctx* cctx);
__attribute__ ((visibility ("default"))) size_t LZ4F_compressBegin(LZ4F_cctx* cctx,
                                      void* dstBuffer, size_t dstCapacity,
                                      const LZ4F_preferences_t* prefsPtr);
__attribute__ ((visibility ("default"))) size_t LZ4F_compressBound(size_t srcSize, const LZ4F_preferences_t* prefsPtr);
__attribute__ ((visibility ("default"))) size_t LZ4F_compressUpdate(LZ4F_cctx* cctx,
                                       void* dstBuffer, size_t dstCapacity,
                                 const void* srcBuffer, size_t srcSize,
                                 const LZ4F_compressOptions_t* cOptPtr);
__attribute__ ((visibility ("default"))) size_t LZ4F_flush(LZ4F_cctx* cctx,
                              void* dstBuffer, size_t dstCapacity,
                        const LZ4F_compressOptions_t* cOptPtr);
__attribute__ ((visibility ("default"))) size_t LZ4F_compressEnd(LZ4F_cctx* cctx,
                                    void* dstBuffer, size_t dstCapacity,
                              const LZ4F_compressOptions_t* cOptPtr);
typedef struct LZ4F_dctx_s LZ4F_dctx;
typedef LZ4F_dctx* LZ4F_decompressionContext_t;
typedef struct {
  unsigned stableDst;
  unsigned skipChecksums;
  unsigned reserved1;
  unsigned reserved0;
} LZ4F_decompressOptions_t;
__attribute__ ((visibility ("default"))) LZ4F_errorCode_t LZ4F_createDecompressionContext(LZ4F_dctx** dctxPtr, unsigned version);
__attribute__ ((visibility ("default"))) LZ4F_errorCode_t LZ4F_freeDecompressionContext(LZ4F_dctx* dctx);
__attribute__ ((visibility ("default"))) size_t LZ4F_headerSize(const void* src, size_t srcSize);
__attribute__ ((visibility ("default"))) size_t
LZ4F_getFrameInfo(LZ4F_dctx* dctx,
                  LZ4F_frameInfo_t* frameInfoPtr,
            const void* srcBuffer, size_t* srcSizePtr);
__attribute__ ((visibility ("default"))) size_t
LZ4F_decompress(LZ4F_dctx* dctx,
                void* dstBuffer, size_t* dstSizePtr,
          const void* srcBuffer, size_t* srcSizePtr,
          const LZ4F_decompressOptions_t* dOptPtr);
__attribute__ ((visibility ("default"))) void LZ4F_resetDecompressionContext(LZ4F_dctx* dctx);
__attribute__ ((visibility ("default"))) size_t
LZ4F_compressBegin_usingDict(LZ4F_cctx* cctx,
                            void* dstBuffer, size_t dstCapacity,
                      const void* dictBuffer, size_t dictSize,
                      const LZ4F_preferences_t* prefsPtr);
__attribute__ ((visibility ("default"))) size_t
LZ4F_decompress_usingDict(LZ4F_dctx* dctxPtr,
                          void* dstBuffer, size_t* dstSizePtr,
                    const void* srcBuffer, size_t* srcSizePtr,
                    const void* dict, size_t dictSize,
                    const LZ4F_decompressOptions_t* decompressOptionsPtr);
typedef struct LZ4F_CDict_s LZ4F_CDict;
__attribute__ ((visibility ("default"))) LZ4F_CDict* LZ4F_createCDict(const void* dictBuffer, size_t dictSize);
__attribute__ ((visibility ("default"))) void LZ4F_freeCDict(LZ4F_CDict* CDict);
__attribute__ ((visibility ("default"))) size_t
LZ4F_compressFrame_usingCDict(LZ4F_cctx* cctx,
                              void* dst, size_t dstCapacity,
                        const void* src, size_t srcSize,
                        const LZ4F_CDict* cdict,
                        const LZ4F_preferences_t* preferencesPtr);
__attribute__ ((visibility ("default"))) size_t
LZ4F_compressBegin_usingCDict(LZ4F_cctx* cctx,
                              void* dstBuffer, size_t dstCapacity,
                        const LZ4F_CDict* cdict,
                        const LZ4F_preferences_t* prefsPtr);

LZ4F_frameInfo_t FUZZ_randomFrameInfo(uint32_t* seed);
LZ4F_preferences_t FUZZ_randomPreferences(uint32_t* seed);
size_t FUZZ_decompressFrame(void* dst, const size_t dstCapacity,
                            const void* src, const size_t srcSize,
                            int skipChecksums);
typedef enum { LZ4F_OK_NoError, LZ4F_ERROR_GENERIC, LZ4F_ERROR_maxBlockSize_invalid, LZ4F_ERROR_blockMode_invalid, LZ4F_ERROR_parameter_invalid, LZ4F_ERROR_compressionLevel_invalid, LZ4F_ERROR_headerVersion_wrong, LZ4F_ERROR_blockChecksum_invalid, LZ4F_ERROR_reservedFlag_set, LZ4F_ERROR_allocation_failed, LZ4F_ERROR_srcSize_tooLarge, LZ4F_ERROR_dstMaxSize_tooSmall, LZ4F_ERROR_frameHeader_incomplete, LZ4F_ERROR_frameType_unknown, LZ4F_ERROR_frameSize_wrong, LZ4F_ERROR_srcPtr_wrong, LZ4F_ERROR_decompressionFailed, LZ4F_ERROR_headerChecksum_invalid, LZ4F_ERROR_contentChecksum_invalid, LZ4F_ERROR_frameDecoding_alreadyStarted, LZ4F_ERROR_compressionState_uninitialized, LZ4F_ERROR_parameter_null, LZ4F_ERROR_io_write, LZ4F_ERROR_io_read, LZ4F_ERROR_maxCode,
              _LZ4F_dummy_error_enum_for_c89_never_used } LZ4F_errorCodes;
                   LZ4F_errorCodes LZ4F_getErrorCode(size_t functionResult);
                   size_t LZ4F_getBlockSize(LZ4F_blockSizeID_t blockSizeID);
                   size_t
LZ4F_uncompressedUpdate(LZ4F_cctx* cctx,
                        void* dstBuffer, size_t dstCapacity,
                  const void* srcBuffer, size_t srcSize,
                  const LZ4F_compressOptions_t* cOptPtr);
typedef void* (*LZ4F_AllocFunction) (void* opaqueState, size_t size);
typedef void* (*LZ4F_CallocFunction) (void* opaqueState, size_t size);
typedef void (*LZ4F_FreeFunction) (void* opaqueState, void* address);
typedef struct {
    LZ4F_AllocFunction customAlloc;
    LZ4F_CallocFunction customCalloc;
    LZ4F_FreeFunction customFree;
    void* opaqueState;
} LZ4F_CustomMem;
static
__attribute__((__unused__))
LZ4F_CustomMem const LZ4F_defaultCMem = { ((void *)0), ((void *)0), ((void *)0), ((void *)0) };
                   LZ4F_cctx* LZ4F_createCompressionContext_advanced(LZ4F_CustomMem customMem, unsigned version);
                   LZ4F_dctx* LZ4F_createDecompressionContext_advanced(LZ4F_CustomMem customMem, unsigned version);
                   LZ4F_CDict* LZ4F_createCDict_advanced(LZ4F_CustomMem customMem, const void* dictBuffer, size_t dictSize);
typedef enum { op_begin, op_update, op_uncompressedUpdate, op_flush, op_end } opType_e;
typedef struct {
    LZ4F_cctx* refCtx;
    LZ4F_cctx* cctx;
    const LZ4F_preferences_t* prefs;
    const LZ4F_compressOptions_t* cOpts;
    char* refOut;
    size_t refOutCapacity;
    char* frame;
    size_t frameCapacity;
    size_t frameSize;
} state_t;
static size_t runOp(const state_t* s, LZ4F_cctx* cctx, opType_e type,
                    void* dst, size_t dstCapacity,
                    const uint8_t* src, size_t srcSize)
{
    switch (type) {
    case op_begin:
        return LZ4F_compressBegin(cctx, dst, dstCapacity, s->prefs);
    case op_update:
        return LZ4F_compressUpdate(cctx, dst, dstCapacity, src, srcSize, s->cOpts);
    case op_uncompressedUpdate:
        return LZ4F_uncompressedUpdate(cctx, dst, dstCapacity, src, srcSize, s->cOpts);
    case op_flush:
        return LZ4F_flush(cctx, dst, dstCapacity, s->cOpts);
    case op_end:
        return LZ4F_compressEnd(cctx, dst, dstCapacity, s->cOpts);
    }
    return (size_t)-1;
}
static size_t opBound(const state_t* s, opType_e type, size_t srcSize)
{
    switch (type) {
    case op_begin:
        return 19;
    case op_update:
    case op_uncompressedUpdate:
        return LZ4F_compressBound(srcSize, s->prefs);
    case op_flush:
    case op_end:
        return LZ4F_compressBound(0, s->prefs);
    }
    return 0;
}
static void freshContexts(state_t* s)
{
    LZ4F_freeCompressionContext(s->refCtx);
    LZ4F_freeCompressionContext(s->cctx);
    (((!LZ4F_isError(LZ4F_createCompressionContext(&s->refCtx, 100)))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 77, "(!LZ4F_isError(LZ4F_createCompressionContext(&s->refCtx, 100)))", ("")), abort()));
    (((!LZ4F_isError(LZ4F_createCompressionContext(&s->cctx, 100)))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 78, "(!LZ4F_isError(LZ4F_createCompressionContext(&s->cctx, 100)))", ("")), abort()));
}
static void checkInvalidated(LZ4F_cctx* cctx)
{
    char dst[19];
    size_t const r = LZ4F_compressEnd(cctx, dst, sizeof(dst), ((void *)0));
    ((LZ4F_getErrorCode(r) == LZ4F_ERROR_compressionState_uninitialized) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 86, "LZ4F_getErrorCode(r) == LZ4F_ERROR_compressionState_uninitialized", ("A failed operation must invalidate the frame")), abort()));
}
static int runBoth(state_t* s, opType_e type, const uint8_t* src, size_t srcSize, uint32_t* seed)
{
    size_t const bound = opBound(s, type, srcSize);
    size_t capacity;
    (((bound <= s->refOutCapacity)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 95, "(bound <= s->refOutCapacity)", ("")), abort()));
    size_t const refSize = runOp(s, s->refCtx, type, s->refOut, bound, src, srcSize);
    ((!LZ4F_isError(refSize)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 98, "!LZ4F_isError(refSize)", ("Operation must succeed with a bound-sized buffer")), abort()));
    (((refSize <= bound)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 99, "(refSize <= bound)", ("")), abort()));
    switch (FUZZ_rand32(seed, 0, 7)) {
    case 0:
    case 1: capacity = refSize; break;
    case 2:
    case 3: capacity = FUZZ_rand32(seed, (uint32_t)refSize, (uint32_t)bound); break;
    case 4: capacity = refSize ? refSize - 1 : 0; break;
    case 5: capacity = FUZZ_rand32(seed, 0, (uint32_t)refSize); break;
    default: capacity = FUZZ_rand32(seed, 0, (uint32_t)bound); break;
    }
    char* const dst = (char*)malloc(capacity ? capacity : 1);
    (((dst != ((void *)0))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 113, "(dst != ((void *)0))", ("")), abort()));
    size_t const r = runOp(s, s->cctx, type, dst, capacity, src, srcSize);
    if (capacity < refSize) {
        ((LZ4F_getErrorCode(r) == LZ4F_ERROR_dstCapacity_tooSmall) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 117, "LZ4F_getErrorCode(r) == LZ4F_ERROR_dstCapacity_tooSmall", ("Operation must fail when its output doesn't fit")), abort()));
        free(dst);
        checkInvalidated(s->cctx);
        freshContexts(s);
        return 0;
    }
    ((r == refSize) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 123, "r == refSize", ("Operation must succeed when its output fits")), abort()));
    ((!memcmp(dst, s->refOut, refSize)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 124, "!memcmp(dst, s->refOut, refSize)", ("Output must not depend on capacity")), abort()));
    (((s->frameSize + refSize <= s->frameCapacity)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 125, "(s->frameSize + refSize <= s->frameCapacity)", ("")), abort()));
    memcpy(s->frame + s->frameSize, dst, refSize);
    s->frameSize += refSize;
    free(dst);
    return 1;
}
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    uint32_t seed = FUZZ_seed(&data, &size);
    LZ4F_preferences_t const prefs = FUZZ_randomPreferences(&seed);
    int const allowUncompressed = prefs.frameInfo.blockMode == LZ4F_blockIndependent;
    size_t const blockSize = LZ4F_getBlockSize(prefs.frameInfo.blockSizeID);
    LZ4F_compressOptions_t cOpts;
    state_t s;
    size_t pos = 0, frameStart = 0;
    int inFrame = 0;
    unsigned nbOps;
    memset(&cOpts, 0, sizeof(cOpts));
    cOpts.stableSrc = FUZZ_rand32(&seed, 0, 1);
    memset(&s, 0, sizeof(s));
    s.prefs = &prefs;
    s.cOpts = &cOpts;
    s.refOutCapacity = ( (LZ4F_compressBound(size, &prefs)) > (19) ? (LZ4F_compressBound(size, &prefs)) : (19) );
    s.refOut = (char*)malloc(s.refOutCapacity);
    s.frameCapacity = LZ4F_compressFrameBound(size, &prefs)
                    + 2 * 64 * (4 + 4);
    s.frame = (char*)malloc(s.frameCapacity);
    char* const rt = (char*)malloc(size ? size : 1);
    (((s.refOut != ((void *)0))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 157, "(s.refOut != ((void *)0))", ("")), abort()));
    (((s.frame != ((void *)0))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 158, "(s.frame != ((void *)0))", ("")), abort()));
    (((rt != ((void *)0))) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 159, "(rt != ((void *)0))", ("")), abort()));
    freshContexts(&s);
    for (nbOps = 0; nbOps < 64; nbOps++) {
        if (!inFrame) {
            frameStart = pos;
            s.frameSize = 0;
            inFrame = runBoth(&s, op_begin, ((void *)0), 0, &seed);
            continue;
        }
        if (pos == size || FUZZ_rand32(&seed, 0, 15) == 0) {
            if (runBoth(&s, op_end, ((void *)0), 0, &seed)) {
                size_t const rtSize = FUZZ_decompressFrame(rt, size, s.frame, s.frameSize,
                                                           FUZZ_rand32(&seed, 0, 7) == 0 );
                ((rtSize == pos - frameStart) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 173, "rtSize == pos - frameStart", ("Incorrect regenerated size")), abort()));
                ((!memcmp(data + frameStart, rt, rtSize)) ? (void)0 : (fprintf(__stderrp, "%s: %u: Assertion: `%s' failed. %s\n", "/Users/Admin/Desktop/Qiang/build/scan/raw/lz4/ossfuzz/compress_frame_stream_fuzzer.c", 174, "!memcmp(data + frameStart, rt, rtSize)", ("Corruption!")), abort()));
            }
            inFrame = 0;
            if (pos == size) break;
            continue;
        }
        { uint32_t const t = FUZZ_rand32(&seed, 0, 7);
            opType_e const type = (t == 0) ? op_flush
                                : ((t == 1) && allowUncompressed) ? op_uncompressedUpdate
                                : op_update;
            size_t const remaining = size - pos;
            size_t srcSize = 0;
            if (type != op_flush) {
                switch (FUZZ_rand32(&seed, 0, 3)) {
                case 0: srcSize = FUZZ_rand32(&seed, 0, 16); break;
                case 1: srcSize = blockSize - 1 + FUZZ_rand32(&seed, 0, 2); break;
                default: srcSize = FUZZ_rand32(&seed, 0, (uint32_t)( (remaining) < (2 * blockSize) ? (remaining) : (2 * blockSize) )); break;
                }
                srcSize = ( (srcSize) < (remaining) ? (srcSize) : (remaining) );
            }
            inFrame = runBoth(&s, type, data + pos, srcSize, &seed);
            pos += srcSize;
        }
    }
    free(s.refOut);
    free(s.frame);
    free(rt);
    LZ4F_freeCompressionContext(s.refCtx);
    LZ4F_freeCompressionContext(s.cctx);
    return 0;
}
