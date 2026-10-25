#include <stdio.h>
#include <lambda.h>


int main()
{
    auto a = 100;
    auto b = 20;

    lambda int (int, int) f = lambda (a, &b) int (int x, int y) {
        return a + (*b) + x + y;
    };

    printf("%d\n", f(1, 2));
    printf("%d\n", closure_environment(f)->a);
    printf("%d\n", *closure_environment(f)->b);

    return 0;
}