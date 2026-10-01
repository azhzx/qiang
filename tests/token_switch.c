enum { NPubOp = 60 };
enum Token { Txxx = 0, Tloadw = NPubOp, Tloadl, Tloads, Tloadd, Talloc1, Talloc2,
  Tblit, Tcall, Tenv, Tphi, Tjmp, Tjnz, Tret, Thlt, Texport, Tthread, Textern,
  Tcommon, Tfunc, Ttype, Tdata, Tsection, Talign, Tdbgfile, Tl, Tw, Tsh, Tuh, Th,
  Tsb, Tub, Tb, Td, Ts, Tz, Tint, Tflts, Tfltd, Ttmp, Tlbl, Tglo, Ttyp, Tstr,
  Tplus, Teq, Tcomma, Tlparen, Trparen, Tlbrace, Trbrace, Tnl, Tdots, Teof, Ntok };
int parsecls(int t) {
  switch (t) {
    default: return -1;
    case Ttyp: return 0;
    case Tsb: return 1;
    case Tub: return 2;
    case Tsh: return 3;
    case Tuh: return 4;
    case Tw: return 5;
    case Tl: return 6;
    case Ts: return 7;
    case Td: return 8;
  }
}
int main() {
  if (parsecls(Ttyp) != 0) return 1;
  if (parsecls(Tsb) != 1) return 2;
  if (parsecls(Tub) != 2) return 3;
  if (parsecls(Tsh) != 3) return 4;
  if (parsecls(Tuh) != 4) return 5;
  if (parsecls(Tw) != 5) return 6;
  if (parsecls(Tl) != 6) return 7;
  if (parsecls(Ts) != 7) return 8;
  if (parsecls(Td) != 8) return 9;
  if (parsecls(0) != -1) return 10;
  if (parsecls(59) != -1) return 11;
  if (parsecls(120) != -1) return 12;
  return 0;
}
