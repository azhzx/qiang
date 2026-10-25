#include <stdio.h>
#include <stdbool.h>
#include <taggedunion.h>

#define MakeResult(T, E) \
    typedef tagunion {                                              \
        T ok;                                                       \
        E err;                                                      \
    } Result_([T, E]);                                              \
                                                                    \
    bool Result_([T, E])_is_ok(Result_([T, E]) r) {                 \
        return dynamic_tag(r) == static_tag(Result_([T, E]), ok);   \
    }                                                               \


MakeResult(int, const char*);

int main() {
    auto r1 = Result_([int, const char*]) { .ok = 42};
    auto r2 = Result_([int, const char*]) { .err = "An error occurred" };

    printf("Result 1: %d\n", r1.ok);
    printf("Result 2: %s\n", r2.err);
    printf("Is Result 1 ok? %s\n", Result_([int, const char*])_is_ok(r1) ? "Yes" : "No");
    return 0;
}
