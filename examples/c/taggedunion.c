#include <stdio.h>
#include <taggedunion.h>

typedef tagunion {
    int i;
    float f;
    char* txt;
} Value;

void print_value(Value v) {
    switch (dynamic_tag(v)) {
        case static_tag(Value, i): printf("Integer: %d\n", v.i); break;
        case static_tag(Value, f): printf("Float: %f\n", v.f); break;
        case static_tag(Value, txt): printf("String: %s\n", v.txt); break;
    }
}

int main() {

    Value v1 = { .i = 42 };
    Value v2 = { .f = 3.14f };
    Value v3 = { .txt = "Hello, World!" };

    print_value(v1);
    print_value(v2);
    print_value(v3);
    

    return 0;
}
