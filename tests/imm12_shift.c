/* Immediates that need the AArch64 `lsl #12` form were emitted without the
   shift, so `cmp w0, #0x10` was assembled where `cmp w0, #0x10, lsl #12`
   was meant: comparing against 65536 behaved like comparing against 16 and
   against 32768 like 8.

   arm64_bin_imm12 encodes the shift in bit 12 of the value it returns, but
   enc_cmp_imm_sf, enc_cmn_imm_sf, enc_add_imm_sf and enc_sub_imm_sf all
   passed sh = 0 to dpr_addsub_imm, and dpr_addsub_imm masks imm12 with
   0xFFF, so the flag was dropped.  They now take sh from imm12 >> 12.

   The bad bits are returned as the exit status so the test needs no libc. */

static int lt65536(int y) { return y < 65536; }
static int lt32768(int y) { return y < 32768; }
static int lt100000(int y) { return y < 100000; }
static int lt65535(int y) { return y < 65535; }
static int lt4096(int y) { return y < 4096; }
static int lt4097(int y) { return y < 4097; }

int main(void) {
  int bad = 0;
  int y;
  for (y = 0; y < 200000; y++) {
    if (lt65536(y) != (y < 65536)) bad |= 1;
    if (lt32768(y) != (y < 32768)) bad |= 2;
    if (lt100000(y) != (y < 100000)) bad |= 4;
    if (lt65535(y) != (y < 65535)) bad |= 8;
    if (lt4096(y) != (y < 4096)) bad |= 16;
    if (lt4097(y) != (y < 4097)) bad |= 32;
    if (bad) break;
  }
  return bad;
}
