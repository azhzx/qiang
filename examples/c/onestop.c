// std=cqe
#include <stdio.h>
#include <time.h>

#define PRINT_TIME \
    do { \
        clock_t end = clock(); \
        double elapsed = (double)(end - start) / CLOCKS_PER_SEC; \
        printf("Elapsed time: %.6f seconds\n", elapsed); \
    } while (0)

typedef _Tagged_union {
  int as_int;
  float as_float;
} Value;

static int 
tag_of(Value v) { 
  return (int)_Dynamic_tag(v); 
}

static int 
fib(int n) {
    return n < 2 ? n : fib(n - 1) + fib(n - 2);
}

int 
main()
{
    auto v = (Value){ .as_int = 100 };
    printf("tag %d int %d\n", tag_of(v), v.as_int);

    v = (Value){ .as_float = 1.5f };
    auto is_float = (_Dynamic_tag(v) == _Static_tag(Value, as_float));
    auto same = (v.as_float == 1.5f);
    printf("tag %d float %d same %d\n", tag_of(v), is_float, same);

    printf("sizeof %d\n", (int)sizeof(Value));

    {
        clock_t start = clock();
        _Defer {
            PRINT_TIME;
        };
        printf("fib(%d) = %d\n", 30, fib(30));
    }

    auto txt = ({
        printf("A\n");
        printf("B\n");
        "hello from Qiang\n";
    });
    printf("%s", txt);

    return 0;
}