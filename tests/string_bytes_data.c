// gas-asm
// A decoded C literal is a byte string. Three things must hold end to end:
//  - a backslash that came from \\ is data, not the start of another escape
//    (it used to be decoded twice on the object path);
//  - bytes above 0x7F stay single bytes on both the object and the asm route,
//    instead of being re-encoded as UTF-8;
//  - concatenation happens between decoded literals, so "\x9" "0" is two
//    bytes rather than the single byte 0x90.
int main() {
  if ("\\a"[0] != 92 || "\\a"[1] != 'a' || sizeof("\\a") != 3) return 1;
  if ("\\n"[0] != 92 || "\\n"[1] != 'n' || sizeof("\\n") != 3) return 2;
  if ("\\\\"[0] != 92 || "\\\\"[1] != 92 || sizeof("\\\\") != 3) return 3;
  if ("\\\"x"[0] != 92 || "\\\"x"[1] != '"' || "\\\"x"[2] != 'x') return 4;
  if ("\a"[0] != 7 || "\e"[0] != 27 || "\v"[0] != 11) return 5;
  if ("\b"[0] != 8 || "\f"[0] != 12) return 6;
  if ("\n"[0] != 10 || "\t"[0] != 9 || "\r"[0] != 13) return 7;
  if ("\101"[0] != 65 || "\x42"[0] != 66 || "\0x"[0] != 0) return 8;
  if ("\x41z"[0] != 'A' || "\x41z"[1] != 'z') return 9;
  if ("\1234"[0] != 83 || "\1234"[1] != '4') return 10;
  // U+00E9 in UTF-8: the two bytes must survive as two bytes
  if ((unsigned char)"é"[0] != 0xC3 || (unsigned char)"é"[1] != 0xA9) return 11;
  if (sizeof("é") != 3) return 12;
  if (sizeof("\303\251") != 3) return 13;
  if ((unsigned char)"\303\251"[0] != 0xC3) return 14;
  if ((unsigned char)"\303\251"[1] != 0xA9) return 15;
  if ("\x9" "0"[0] != 9 || "\x9" "0"[1] != '0') return 16;
  if (sizeof("\x9" "0") != 3) return 17;
  if ("\x41" "BC"[0] != 'A' || "\x41" "BC"[1] != 'B') return 18;
  if ("\1" "2"[0] != 1 || "\1" "2"[1] != '2') return 19;
  return 0;
}
