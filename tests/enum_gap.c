enum { NPubOp = 88 };
enum Token { Txxx = 0, Tloadw = NPubOp, Tloadl, Tloads, Tloadd, Talloc1, Talloc2,
  Tblit, Tcall, Tenv, Tphi, Tjmp, Tjnz, Tret, Thlt, Texport, Tthread, Textern,
  Tcommon, Tfunc, Ttype, Tdata, Tsection, Talign, Tdbgfile, Tl, Tw, Tsh, Tuh, Th,
  Tsb, Tub, Tb, Td, Ts, Tz, Tint, Tflts, Tfltd, Ttmp, Tlbl, Tglo, Ttyp, Tstr,
  Tplus, Teq, Tcomma, Tlparen, Trparen, Tlbrace, Trbrace, Tnl, Tdots, Teof, Ntok };
char *m[200] = { [Tloadw] = "a", [Texport] = "b", [Tw] = "c", [Tint] = "d" };
int main() {
  if (Tw - Tloadw != 25) return 1;
  if (Tint - Tloadw != 35) return 2;
  if (m[Tw] == 0 || m[Tw][0] != 99) return 3;
  if (m[Tint] == 0 || m[Tint][0] != 100) return 4;
  if (m[Tloadw] == 0 || m[Tloadw][0] != 97) return 5;
  if (m[Texport] == 0 || m[Texport][0] != 98) return 6;
  return 0;
}
