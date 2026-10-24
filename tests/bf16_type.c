// std=cqe
// clang's <arm_neon.h> spells its 16-bit float types __bf16 (bfloat16),
// __fp16 and __mfp8 (8-bit FP8); a typedef of one of them used to be a parse
// error (hiredis/read.c stops there). The port has no 16-bit float type, so
// they are accepted as placeholders - enough for the typedefs and prototypes
// that system headers declare.
typedef __bf16 bfloat16_t;
typedef __fp16 float16_t;
typedef __mfp8 mfloat8_t;

bfloat16_t make_bfloat(void);
float16_t make_half(void);
mfloat8_t make_fp8(void);

int main(void) {
  // Only the declarations matter: the typedefs have to parse and name types.
  bfloat16_t *b = 0;
  float16_t *h = 0;
  mfloat8_t *m = 0;
  if (b != 0 && h != 0 && m != 0) {
    return 1;
  }
  return 0;
}
