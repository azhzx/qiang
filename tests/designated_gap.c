enum { NPubOp = 88 };
enum T { Txxx = 0, Tloadw = NPubOp, Tloadl, Tloads, Talloc2, Tblit, Tcall, Tenv, Tphi, Tjmp, Tjnz, Tret, Thlt, Texport, Tthread, Textern, Tcommon, Tfunc, Ttype, Tdata, Tsection, Talign, Tdbgfile, Tl, Tw, Tsh, Tuh, Th, Tsb, Tub, Tb, Td, Ts, Tz, Ntok };
char *kwmap[128] = { [Tloadw] = "loadw", [Texport] = "export", [Tfunc] = "function", [Tdbgfile] = "dbgfile", [Tsb] = "sb", [Th] = "h", [Tw] = "w", [Tl] = "l", [Td] = "d", [Tz] = "z" };
int main() {
  if (kwmap[Tloadw] == 0 || kwmap[Tloadw][0] != 108) return 1;
  if (kwmap[Texport] == 0 || kwmap[Texport][0] != 101) return 2;
  if (kwmap[Tfunc] == 0 || kwmap[Tfunc][0] != 102) return 3;
  if (kwmap[Tw] == 0 || kwmap[Tw][0] != 119) return 4;
  if (kwmap[Tl] == 0 || kwmap[Tl][0] != 108) return 5;
  if (kwmap[Td] == 0 || kwmap[Td][0] != 100) return 6;
  if (kwmap[Tz] == 0 || kwmap[Tz][0] != 122) return 7;
  if (kwmap[Tsb] == 0 || kwmap[Tsb][0] != 115) return 8;
  if (kwmap[Txxx] != 0) return 9;
  return 0;
}
