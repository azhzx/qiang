// std=c2y
#include <stdio.h>
#include <time.h>

static int fib(int n) {
    return n < 2 ? n : fib(n - 1) + fib(n - 2);
}

#define PRINT_TIME \
    do { \
        clock_t end = clock(); \
        double elapsed = (double)(end - start) / CLOCKS_PER_SEC; \
        printf("Elapsed time: %.6f seconds\n", elapsed); \
    } while (0)

int main(void) {


    {
        clock_t start = clock();
        _Defer {
            PRINT_TIME;
        };
        printf("fib(%d) = %d\n", 30, fib(30));
    }

    return 0;
}

