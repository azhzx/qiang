#include <stdio.h>
#include <function_pointer.h>


static int add(int x, int y) {
    return x + y;
}

int main() {
    function_pointer add_1 = add;
    function_pointer int (int x, int y) add_2 = add;
    printf("add_1(2, 3) = %d\n", add_2(2, 3));
    return 0;
}
