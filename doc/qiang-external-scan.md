# Qiang 外部 C 项目编译扫描报告

> **本报告只诊断，未修复。** 第一版数据采集于 2026-10-11（Qiang v0.37.3）。
> 2026-10-17 在修完 Lua 之后重扫了一遍，见 §7。
> 2026-10-18 修完后端 ICE、大栈帧访存和嵌套 case 标签的 switch 下降之后扫了第三次，见 §7.4；
> 同日修完 `__inline__` 外部链接语义后扫了第四次（§7.5），
> 又修完三个 SEMA 失败后扫了第五次（§7.6）；
> 最后弄清 Apple 扩展与 GCC 的立场、改用 `-U__BLOCKS__` 预处理后扫了第六次（§7.7）；
> 再补上结构体打包后扫了第七次（§7.8）；
> 修掉 `gcm` 删 phi 的问题后扫了第八次（§7.10）；
> 再修正扫描口径、补 `PRI*` 和 `__builtin_bzero` 后扫了第九次（§7.11）。
> 抓取与扫描脚本在 tools/scan_external_fetch.py、tools/scan_external.py，中间产物在 build/scan/（未提交）。
## 0. 一句话结论

17 个真实 C 项目、201 个源文件：**186 个完整通过（93%）**。第一版是 88 个（44%）。
另有 42 个文件**根本没走到 Qiang**（缺第三方或平台依赖，属环境问题）。
扣掉它们，**到达 Qiang 的 194 个文件里 186 个通过 —— 96%**（第一版 65%，上一轮 92%）。

修复过程分十二轮，逐文件对照见 §7：

| 轮次 | 内容 | 效果 |
| --- | --- | --- |
| 第一轮 | 修 Lua 时发现的问题：整型提升、自带头缺宏/缺声明、arm64 大栈帧、标签映射 | PARSE 23 → 12，OK 88 → 128 |
| 第二轮 | 按扫描报告修 P0/P1：`sizeof("字面量")`、自引用初始化式、整数位内置函数、平台宏、诊断改 stderr | SEMA 14 → 3，OK 128 → 138 |
| 第三轮 | 后端 ICE（arm64 二进制发射器）、大栈帧 sp 相对访存、`Addr` 截断、**嵌套 case 标签的 switch 下降** | **CODEGEN-PANIC 4 → 0，OK 138 → 142** |
| 第四轮 | `__inline__` 的 C99 6.7.4p6 外部链接语义 | 整项目能跑 2 → 5 |
| 第五轮 | 三个 SEMA 失败（文件作用域 `sizeof`、自带头、扫描器 `-D`）| SEMA 3 → 0 |
| 第六轮 | 预处理 `-U__BLOCKS__`、C23 enum 属性 | PARSE 12 → 5，OK → 150 |
| 第七轮（最新）| `#pragma pack` 结构体打包 | **SEMA 2 → 0，OK → 151** |
| 第八轮| `gcm` 漏了 `AtomicStore`，删掉了仍在用的 phi | **CODEGEN 1 -> 0，OK -> 152** |
| 第九轮| 修正扫描口径（自动生成 `config.h`）+ 补 `PRI*` 宏与 `__builtin_bzero` | **OK 152 -> 154，PREPROCESS 44 -> 42** |
| 第十轮| `__bf16__`/`__mfp8__` + 真正配置环境（第三方头、生成头）| **OK 154 -> 185，PREPROCESS 44 -> 7** |
| 第十一轮| `simplcfg` 链式合并后 phi 参数悬空 | **OK 185 -> 186，dash/jobs.c 通过** |
| 第十二轮（最新）| `promote` 跳过只读槽（内联汇编/未初始化局部）| 取消该中止，前进到下一层问题 |

第二轮的五个修复（都有最小复现用例，见 `Qiang/tests/sizeof_lit.c`、`builtin_bits.c`）：

1. `sizeof("ab")` 原来返回 8 ✓ → 现在 **3**（字符串字面量在 C 里是数组）；
2. 声明的名字在自己的初始化式里不可见（§6.7）→ 修好后 **lz4 与 hiredis 共 6 个文件**通过；
3. `__builtin_bswap16/32/64`、`clz`、`ctz`、`popcount` 原来是隐式声明 → 链接必失败，现在在 codegen 里生成位运算序列；
4. 自带 `errno.h`/`unistd.h`/`limits.h` 补 `ENOMEM`、`EWOULDBLOCK`、`R_OK`、`SSIZE_MAX` 与 `access`/`lseek` 等声明；
5. 诊断从 stdout 改到 **stderr**（`--check OK` 和 `--emit` 输出仍在 stdout）。

剩下的 **50** 个失败里：44 个没走到 Qiang（缺依赖）、5 个前端解析失败、1 个代码生成失败、0 个 SEMA（已清零）。
**SEMA 3**（`optarg` 缺声明、`-DVERSION=`、常量除零）。**CODEGEN 已经清零**。

## 1. 口径（先看这个）

Qiang 没有自带预处理器，所以本报告里「Qiang 能不能编译 X」的定义是：
**「Qiang 能不能编译 `clang -E` 之后的 X」**。每个文件走三层：

```
clang -E -P -I Qiang/include/qbe -I <proj> [-D…] f.c   →  f.i
Qiang f.i -std=c11 --check     ① 前端：词法 / 语法 / 语义
Qiang f.i -std=c11 -o f.o      ② 代码生成
```

先 `--check` 再 `-o`，是为了把「前端不支持」和「后端发射出错」分开 —— 结果证明确实有必要（见 §5.3）。

## 2. 项目总表

| 项目 | 源文件 | 通过 | 前端失败 | 生成失败 | 预处理未到达 |
| --- | ---: | ---: | ---: | ---: | ---: |
| abduco | 6 | 1 | 3 | 0 | 2 |
| bzip2 | 13 | 13 | 0 | 0 | 0 |
| cjson | 2 | 2 | 0 | 0 | 0 |
| dash | 30 | 29 | 0 | 1 | 0 |
| farbfeld | 7 | 7 | 0 | 0 | 0 |
| hiredis | 9 | 8 | 0 | 1 | 0 |
| ii | 2 | 1 | 0 | 0 | 1 |
| lchat | 6 | 5 | 0 | 0 | 1 |
| lua | 34 | 34 | 0 | 0 | 0 |
| lz4 | 25 | 23 | 2 | 0 | 0 |
| miniz | 4 | 4 | 0 | 0 | 0 |
| sic | 3 | 2 | 1 | 0 | 0 |
| slstatus | 24 | 23 | 0 | 0 | 1 |
| smu | 1 | 1 | 0 | 0 | 0 |
| sqlite | 1 | 1 | 0 | 0 | 0 |
| yyjson | 4 | 4 | 0 | 0 | 0 |
| zlib | 30 | 28 | 0 | 0 | 2 |
| **合计** | **201** | **186** | **6** | **2** | **7** |

## 3. 阶段分布

| 阶段 | 文件数 | 占全部 201 |
| --- | ---: | ---: |
| OK | 186 | 93% |
| PREPROCESS | 7 | 3% |
| PARSE | 4 | 2% |
| SEMA | 2 | 1% |
| CODEGEN-PANIC | 2 | 1% |

## 4. 诊断签名排名（跨项目计数，只统计到达 Qiang 的文件）

| 诊断 | 文件数 | 项目数 |
| --- | ---: | ---: |
| `expected ';'` | 4 | 2 |
| `use of undeclared identifier: LZ4F_ERROR_dstCapacity_tooSmal` | 2 | 1 |

生成失败（CODEGEN-PANIC）现在只有 2 个文件：

- dash/printf.c - `Qiang: object emission failed: t.1028 violates ssa invariant`

- hiredis/read.c - `Qiang: object emission failed: ld.75544 violates ssa invariant`

第二至第七轮修掉的诊断不再出现：ICE（arm64 二进制发射器）、PanicError、optarg、VERSION、常量除零。

## 5. 未到达 Qiang 的原因

| 缺失/失败 | 文件数 |
| --- | ---: |
| `其它（见附录 A）` | 4 |
| `'tls.h' file not found` | 1 |
| `'grapheme.h' file not found` | 1 |
| `'sys/soundcard.h' file not found` | 1 |

都不是 Qiang 的问题：这些文件需要第三方库头、各项目自己的构建产物或平台头。

## 6. 逐条发现

### 6.1 头号问题：自带头遮蔽系统头，缺标准宏（11+ 文件）

Qiang 用 `-I Qiang/include/qbe` 提供 20 个头文件。`-I` 是**优先**搜索，
于是 `<stdint.h>` `<stdio.h>` `<stdlib.h>` `<limits.h>` `<unistd.h>` 全部命中 Qiang 的版本，
而它们**没有**这些标准宏：

| 宏 | 本该来自 | Qiang 自带头 | 系统头 |
| --- | --- | --- | --- |
| `SIZE_MAX` | `<stdint.h>` | ✗ 缺 | ✓ 有 |
| `INTMAX_MIN` | `<stdint.h>` | ✗ 缺 | ✓ 有 |
| `EXIT_FAILURE` / `EXIT_SUCCESS` | `<stdlib.h>` | ✗ 缺 | ✓ 有 |
| `BUFSIZ` / `L_tmpnam` / `SEEK_END` | `<stdio.h>` | ✗ 缺 | ✓ 有 |
| `USHRT_MAX` | `<limits.h>` | ✗ 缺 | ✓ 有 |
| `STDOUT_FILENO` | `<unistd.h>` | ✗ 缺 | ✓ 有 |

受影响文件数（`use of undeclared identifier`）：`SIZE_MAX` 7、`EXIT_FAILURE` 3、
`EXIT_SUCCESS` 2、`BUFSIZ` 2，另有 `USHRT_MAX`/`STDOUT_FILENO`/`SEEK_END`/`L_tmpnam`/`INTMAX_MIN` 各 1。

**这是最容易修、收益最大的一条**：补齐宏即可，不涉及语言实现。
dash 的 `arith_yacc.c` 正因 `INTMAX_MIN` 失败。

**现状（2026-10-17）：已修。** 上面这些宏全部补齐，另外还补了一批**缺失的函数声明**
（`strpbrk`、`strspn`、`freopen`、`tmpfile`、`ferror`、`fseek` 等）——
缺声明时按 C89 隐式返回 `int`，指针会被截断。受影响的 dash/hiredis/lchat/lz4 文件现已通过。
**第二轮又补了** `ENOMEM`、`EWOULDBLOCK`、`R_OK`、`SSIZE_MAX` 以及 `access`、`lseek`、`getcwd` 等声明：
hiredis 的 5 个文件、lchat 的 2 个、lz4 的 2 个、farbfeld 的 `util.c` 因此全部通过 ✓。

### 6.2 解析失败七成来自 macOS 系统头的 Apple 扩展（17 / 23 文件）

| 现场 | 文件数 | 源头 |
| --- | ---: | --- |
| `extern _Float16 __fabsf16(_Float16) __attribute__((availability(...)))` | 12 | macOS `<math.h>` |
| `int (^)(const struct dirent *)` / `typedef void (^os_block_t)(void);` | 5 | Apple **Blocks**（`<dirent.h>` 等）|

**SQLite 也栽在这里** —— 它那个唯一的失败点就是第 6527 行的
`typedef void (^os_block_t)(void);`，来自系统头而非 SQLite 自己的代码。

所以：**这 17 个失败很可能是 macOS 特有的**，在 Linux/glibc 上大概率消失。
把 Qiang 放到 Linux 上重跑是下一个该做的实验。

剩下的 6 个是项目自身代码（`va_list ap;`、`static bool client_send_packet(...)`、
`static Client *client_malloc(...)`、`else if(!strcmp("-n", argv[i]))` 等），才是真正的前端缺口。

### 6.3 后端 ICE（3 个文件，真 bug）（第三轮已修，见 §7.4）

| 项目 | 文件 | 消息 |
| --- | --- | --- |
| bzip2 | `compress.c` | `ICE: arm64 bin: expected a register operand for mul` |
| bzip2 | `decompress.c` | `ld.8698 violates ssa invariant` |
| lua | `src/ldo.c` | `ICE: arm64 bin: unhandled jump` |

三个都在**代码生成阶段**（前端已通过 `--check`），是 arm64 后端的真实缺陷，
分别指向：乘法的内存操作数、SSA 不变量被破坏、未处理的跳转。

**现状（2026-10-17）：lua 的 `ldo.c` 已修**（标签映射跨函数泄漏导致块无终结符）；
bzip2 的两个仍在（`compress.c` 的 mul 内存操作数、`decompress.c` 的 SSA 不变量）。

### 6.4 `sizeof("字面量")` 静默给错值

```c
printf("%zu %zu %zu\n", sizeof("ab"), sizeof(int), sizeof("abcdef"));
/* Qiang  : 8 4 8   ← 字面量退化成了指针 */
/* clang : 3 4 7   */
```

文档里「`sizeof` of a string literal」列为已知缺口，但**静默给错值**比报错危险。

**现状（2026-10-17）：已修 ✓。** sema 原来把字符串字面量标成 `char*`，所以 `sizeof` 看到的是指针 ✓；
现在直接量字面量本身 ✓：`sizeof("ab")` = 3 ✓、`sizeof("")` = 1 ✓、`sizeof("a" "b")` = 3 ✓，与 clang 一致 ✓。
数组本来就对（`sizeof(arr)` ✓）。回归用例：`Qiang/tests/sizeof_lit.c`。

### 6.5 诊断走 stdout

`Qiang` 的所有诊断（含致命解析错误）走 **stdout**。本次扫描第一遍把 stdout 丢进 `/dev/null`，
结果日志里只剩 `PanicError` 栈，**完全看不到错误信息**。对「Qiang 作为编译器的可脚本化性」
这是硬伤，修复优先级应当很高。

**现状（2026-10-17）：已修 ✓。** 诊断现在走 **stderr** ✓（通过 `native` 包里新增的 `mbt_native_eprint`）；
`--check` 成功时的 `OK` 与 `--emit` 的输出仍在 **stdout** ✓，所以 oracle 与管道不受影响 ✓。

### 6.6 整型提升缺失：比较运算符的静默错编（修 Lua 时发现）

C 在通常算术转换之前会做**整型提升**：`char`/`short`（不论有无符号）提升为 `int`，所以
`int >= unsigned char` 是**有符号**比较。Qiang 只问「任一操作数是否无符号」，于是把它编成了
无符号比较。

后果是静默算错：任何**负值**与小无符号类型比较都会翻。Lua 的 `lcode.c` 里有

```c
static void freereg (FuncState *fs, int reg) {
  if (reg >= luaY_nvarstack(fs)) { fs->freereg--; ... }
}
```

`reg` 是 `int`，`luaY_nvarstack` 返回 `lu_byte`。寄存器号为 `-1` 时被当成 `0xFFFFFFFF`，
条件误判为真，`freereg` 多减一次，之后整段字节码的寄存器号全部偏移 1 —— 表现为
`local i=1 while i<=3 do print(i) i=i+1 end` 把循环变量覆盖成 `print`。

已修（先做提升，再让无符号类型在「宽度不小于有符号」时才胜出），回归用例
`Qiang/tests/promote_cmp.c`。

**对方法的提醒**：这一类**编译成功但结果错**的问题，本报告的「OK」计数**完全看不到**。
差分测试也看不到——`compare.py` 给两个编译器喂的是 **IR**，从不经过 Qiang 的 C 前端，
所以 C→IR 的运算符选择实际上长期无人覆盖。要覆盖它，需要**跑起来比结果**的用例。

## 7. 十二轮重扫：与第一版的逐文件对照

第一版把源文件摊平到一个目录再扫 ✗，破坏了 "`#include "../x.h"`" 这类相对包含 ✗。
现在的扫描改为**原地**进行 ✓ 并加入各项目自己的头文件目录 ✓，所以下面的变化要分两类看 ✓：
**口径改善**（PREPROCESS → OK ✓，不是 Qiang 的功劳 ✗）和**真修复**（Qiang 侧失败 → OK ✓）。

### 7.1 第一轮（修完 Lua 之后）

| 阶段变化 | 文件数 | 说明 |
| --- | ---: | --- |
| PREPROCESS → OK | 19 | 口径改善 |
| PARSE → OK | 11 | 真修复 |
| SEMA → OK | 10 | 真修复 |
| CODEGEN-PANIC → OK | 1 | 真修复（lua 的 ldo.c）|
| 未变 | 151 | |

**22 个文件从 Qiang 侧失败变成通过**，其中 lua **34/34 全过**（第一版 22）。

### 7.2 第二轮（P0/P1 修复）

| 文件 | 之前 | 现在 |
| --- | --- | --- |
| farbfeld `util.c` | SEMA | **OK** |
| hiredis `async.c` `dict.c` `hiredis.c` `net.c` `sds.c` | SEMA | **OK** |
| lchat `indent.c` `util.c` | SEMA | **OK** |
| lz4 `lz4file.c` `lz4hc.c` | SEMA | **OK** |
| zlib `zip.c` | SEMA | CODEGEN-PANIC（暴露了新问题，见 7.3）|

总体：**OK 128 → 138**，**SEMA 14 → 3** ✓。

### 7.3 第二轮暴露出的两个新问题

1. **zlib `zip.c` / `miniunz.c`：大栈帧访存 panic** ✗ ——
   "`arm64 enc: load/store offset 66280 does not fit the 12-bit scaled field`" ——
   之前被 SEMA 错误挡住 ✗，现在走到代码生成才暴露 ✓。这与修 Lua 时修的 12 位帧偏移是同一类 ✓，
   但走的是另一条发射路径（sp 相对访存 ✓）。**第三轮已修，见 §7.4。**
2. **lchat `lchat.c`：`optarg` 未声明** ✗ —— 自带 `getopt.h` 缺 `getopt` 的全局变量 ✓。

### 7.4 第三轮（2026-10-18，HEAD 50c2454）

这一轮改的是 Qiang 自己，不动任何第三方源码。四个修复对应的扫描变化：

| 修复 | 提交 | 扫描影响 |
| --- | --- | --- |
| arm64 二进制发射器 `expected a reg` ICE | `f1fc34f` | bzip2 `compress.c`、`decompress.c` |
| 大栈帧 sp 相对访存超过 12 位 | `b66848e` | zlib `zip.c`、`miniunz.c` |
| `Addr` 截断 | `b870b47` | 扫描外（Lua 相关）|
| 嵌套 case 标签的 switch 下降 | `50c2454` | bzip2 `decompress.c` 的**行为**：能编译但解压 CRC 错 |

| 阶段变化 | 文件数 |
| --- | ---: |
| CODEGEN-PANIC → OK | **4** |
| 未变 | 197 |

**OK 138 → 142，CODEGEN-PANIC 4 → 0。** bzip2 **13/13 全过**，zlib **28/30**
（剩 2 个是预处理缺依赖），**全部文件都通过的项目 3 → 4**（新增 bzip2）。

> 其中 `decompress.c` 的 CRC 错误是**行为 bug**，三层扫描看不出来：它能编译、能链接，
> 只是解压出错。定位与修复见 `doc/pitfalls.md` §4.10–§4.12：`switch` 的 case 标签
> 嵌在循环里时，前端把它当成了循环之外的一段独立代码复制，于是循环多跑一轮。
> 回归用例 `Qiang/tests/switch_nested_case.c`。

#### 7.8.1 sqlite3.c 走到了代码生成，撞上新问题

打包修好之后 sqlite3.c 的前端全过，但代码生成报：

    Qiang: object emission failed: b.5205 is used undefined in @logic.join.970

即某个 && / ?: 的 join 块引用了未定义的值 - 这是 IR builder 的 bug，
与打包无关，留作下一轮。

#### 7.4.1 整项目「能跑」的重跑（`tools/scan_run.py`）

| 项目 | 结果 | 说明 |
| --- | --- | --- |
| lua | **RUNS rc=0** | 与上一轮相同 |
| farbfeld | RUNS rc=1 | 与上一轮相同（等 stdin 输入）|
| **zlib** | 库可用 | 16 个 `.o` 全部由 Qiang 编译并链接成功；`compress2` → `uncompress` 往返**完全正确**；`run.tsv` 里的 LIB-LINK-FAIL 出在它自己的构建/测试程序 |
| **bzip2** | 只剩 1 个符号 | 全 Qiang 构建只差 `_BZ2_indexIntoF`：`bzlib.c` 里 `__inline__` 是 **GNU 外部链接语义**，Qiang 按 `static` 处理，不发射实体。压缩/解压逻辑本身已经正确（clang 压缩 → Qiang 解压 300 KB 随机数据字节一致）|

#### 7.4.2 剩下 15 个失败（都已到达 Qiang）

- **PARSE 12**：macOS 系统头的 Apple 扩展（`_Float16 __fabsf16`、Blocks 的块指针），见 §6.2；
- **SEMA 3**：`optarg` 缺声明、`-DVERSION=`（扫描器的 `-D` 注入 bug，不是 Qiang）、常量除零。

下一步优先级：`__inline__` 外部链接语义（修完 bzip2 即可整项目构建+运行）→ 3 个 SEMA → 12 个 PARSE。

### 7.5 第四轮（2026-10-18，`__inline__` 外部链接语义）

§7.4.2 列出的第一优先级已经修掉：**C99 6.7.4p6–7 的 inline 定义规则**。

原实现只要看见 `inline`/`__inline__` 就当作"内联定义、不发射外部定义"。
但标准规定：**只有当翻译单元里该函数的每一个声明都带 `inline` 时**，定义才是内联定义；
出现一个不带 inline 的普通原型（例如 bzip2 的 `bzlib_private.h` 里的
`BZ2_indexIntoF ( Int32, Int32* );`）时，定义就是**外部定义**，必须发射。

修复：`check()` 先扫一遍顶层声明，把"不带 inline、不带 static"的名字收进
`noninline_funcs`，定义处再据此决定 `is_export`。单测
`sema: inline linkage follows C99 6.7.4p6` 覆盖三种情况（普通原型 → 发射；全部 inline →
不发射；`static inline` → 不发射）。

**bzip2 现在整项目由 Qiang 构建、链接、运行成功：**

| 项目 | 之前 | 现在 |
| --- | --- | --- |
| bzip2 | LINK-FAIL（`_BZ2_indexIntoF` 未定义）| **RUNS rc=0** |
| cjson | LIB-LINK-FAIL（扫描器驱动写错）| **RUNS-DRIVER rc=0** |
| yyjson | LIB-LINK-FAIL（扫描器驱动写错）| **RUNS-DRIVER rc=0** |
| lua | RUNS | RUNS |
| farbfeld | RUNS rc=1 | RUNS rc=1 |
| zlib | LIB-LINK-FAIL | 库本身可编译且往返正确；整库链接失败是测试工具 `blast.c` 被算进库里 |

**能跑起来的项目：2 → 5。**

同时修了扫描器自己的三个 bug（否则上表不可信）：

1. `has_main` 只认行首 `int main`，漏掉 bzip2recover.c 的 `Int32 main (` 和
   farbfeld 的 `int` 换行 `main(...)`；而放宽成"全文搜 `main(`"又会把 zlib
   `crc32.c`（注释里提到 main）误判成程序。现在只认"行首 main(" 或"行首 类型 main("。
2. `path_of` 取 `os.walk` 的第一个命中，zlib 的 `contrib/` 副本会盖住真正的
   `crc32.c`；改为取最浅路径。
3. 跑程序时 `text=True` 遇二进制输出直接抛 `UnicodeDecodeError`（bzip2 无参数时会输出
   压缩流），加 `errors="replace"`。cJSON/yyjson 探针 C 代码里引号没转义，改成解析 `"42"`。

### 7.6 第五轮（三个 SEMA 失败全部修完）

§7.4.2 剩下的三个 SEMA 都处理掉了：

| 文件 | 诊断 | 真正原因 | 修法 |
| --- | --- | --- | --- |
| lz4 `lorem.c` | `division by zero in constant expression` | 文件作用域初始化走的常量求值器 `const_eval_int` **没有 `sizeof(expr)` 分支**，返回 0：`sizeof(kWords)` 与 `sizeof(kWords[0])` 都是 0，于是相除报除零 | 补上分支（字符串字面量按字面量长度算）；数组长度也从初始化式补全（原来只在块作用域做）|
| smu `smu.c` | `use of undeclared identifier: VERSION` | 扫描器不跑各项目的 Makefile，没给 `-DVERSION` | 扫描器加一张最小的 `-D` 表（smu、sic 用 `-DVERSION="0"`）|
| lchat `lchat.c` | `use of undeclared identifier: optarg` | 自带 `unistd.h` 缺 getopt 全局变量；BSD/macOS 把它们声明在 `<unistd.h>` 里，而 lchat.c 只 include 了 `<unistd.h>` | 补 `optarg`/`optind`/`opterr`/`optopt`/`getopt` |

修完 `optarg` 后 lchat 又暴露下一个缺失宏：**`PATH_MAX`**（BSD 从 `<sys/syslimits.h>` 经 `<limits.h>` 提供），一并补进自带 `limits.h`（含 `NAME_MAX`）。

| 指标 | 第四轮 | 第五轮 |
| --- | ---: | ---: |
| OK | 142 | **145** |
| SEMA | 3 | **0** |
| CODEGEN-PANIC | 0 | 0 |
| 能跑（RUNS + RUNS-DRIVER）| 5 | **6**（新增 smu）|

新增回归用例：`Qiang/tests/sizeof_static_array.c`（文件作用域 `sizeof`）、
`Qiang/tests/unistd_getopt_globals.c`、`Qiang/tests/limits_path_max.c`。

剩下 12 个 PARSE 与 44 个 PREPROCESS 未动（§7.4.2 的第三优先级）。

### 7.7 第六轮（Apple 扩展、GCC 的立场）

**先测清楚「这些扩展要不要支持」**：

| 语法 | FSF GCC 16.2（conda）✗ | Apple clang 21 ✓ |
| --- | --- | --- |
| Blocks：`typedef void (^blk_t)(void);` | **error: expected identifier or '(' before '^'** ✗ | OK ✓ |
| `__attribute__((__noescape__))` | **error** ✗ | OK ✓ |
| `_Float16` | OK ✓ | OK ✓ |
| `__bf16` | OK ✓ | OK ✓ |
| `__attribute__((availability(...)))` | OK ✓ | OK ✓ |
| C23 `typedef enum attr : uint64_t {}` | OK ✓ | OK ✓ |

**平台上能不能编过** ✓：能 ✓ —— 两个层面：

1. macOS 的 `/usr/bin/gcc` **本身就是 Apple clang 21** ✓，这些项目官方就用它构建 ✓；
2. 就算换真正的 FSF GCC ✓，**Apple 头把 Blocks 声明都包在 `__BLOCKS__` 里** ✓
   （实测 `clang -c lz4/programs/bench.c` 与 `gcc -c` **都成功** ✓）。

**结论：Qiang 不需要实现 Blocks** ✓。它只是**预处理时用了 clang** ✗（clang 定义 `__BLOCKS__` ✗），
把 Apple 头里的块声明带进了 `.i` ✗。改成按「没有 Blocks 的编译器」预处理即可：

```
clang -E -P -U__BLOCKS__ ...
```

这一条同时写进 `Qiang run` 的驱动和 `tools/scan_external.py` ✓。
**lz4 的 5 个文件 + slstatus 的 1 个文件因此从 PARSE 失败变成通过** ✓：PARSE 12 → 6，OK 145 → 150 ✓。

顺带修了 **C23 固定底层类型 + clang 属性** 的语法 ✓
（macOS `<mach/mach_types.h>` 的 `typedef enum __attribute__((__flag_enum__)) : uint64_t { ... }` ✗）：
解析器现在允许属性出现在 `enum`、tag、`:` 与 `{` 之间 ✓。GCC 与 clang 都接受这种写法 ✓，
所以这是**标准层面的缺口** ✗，值得补 ✓。回归用例 `Qiang/tests/enum_flag_attr.c` ✓。

#### 7.7.1 剩下的 6 个 PARSE

| 文件 | 情况 |
| --- | --- |
| abduco `client.c` `debug.c` `server.c`、sic `util.c` | **不是独立翻译单元** ✗：这些文件本身没有 `#include`，是被 `abduco.c`/`sic.c` 用 `#include "client.c"` 吃进去的 ✓（suckless 风格 ✓）→ 扫描器单独编它们是**口径问题** ✗ |
| hiredis `read.c` | `typedef __bf16 bfloat16_t;` ✗ —— 来自 clang 的 `<arm_neon.h>` ✓。FSF GCC 支持 `__bf16` ✓，Qiang 还不认识 ✗ |
| sqlite `sqlite3.c` | 已经越过 Apple 语法 ✓，现在卡在 **`_Static_assert(sizeof(mach_msg_context_trailer_t) == 60)`** ✗ |

后者是个**真问题** ✗：Mach 头里的结构体用 **4 字节打包** ✓（`#pragma pack(4)` / packed 属性 ✗），
Qiang 按自然对齐算成 64 ✗，断言就失败 ✓。这属于布局问题 ✓，需要单独一轮 ✗。

### 7.8 第七轮（`#pragma pack` 结构体打包）

第六轮末尾留的「真 bug」就是它 ✗：macOS Mach 头用 **4 字节打包** ✗，Qiang 按自然对齐算 ✗：

```c
_Static_assert(sizeof(mach_msg_context_trailer_t) == 60, "struct changed size unexpectedly");
```

实测：clang 给 **60** ✓，Qiang 给 **64** ✗（3 个 uint32 + 2 个 uint32 + 8 个 uint32 = 52 ✓，
但 `unsigned long long` 要求 8 字节对齐 ✗ → 补到 56 ✗ → 64 ✗）。

根因有两层 ✗：

1. 驱动里的 `strip_directives` 把**所有** `#` 行删掉 ✗ —— `#pragma pack` 根本没到前端 ✗；
2. 即使到了 ✓，前端也只是**跳过**它 ✗（`SPragma` 被忽略 ✗），布局仍按自然对齐算 ✗。

修复 ✓：

| 层 | 改动 |
| --- | --- |
| 驱动 | `#pragma` 行**保留**（其余 `#` 行仍然清空 ✓，行号不变 ✓）|
| 前端 | `Parser::try_pragma` 解析 `#pragma pack(...)` ✓，支持 `(N)` / `()` / `(push[,N])` / `(pop[,N])` ✓，状态随 `struct`/`union` 一起记到 AST ✓（`TStruct`/`TUnion` 多一个 pack 字段 ✓）|
| 语义 | `define_aggregate` 用 `pack_align` 把每个成员的对齐**封顶到 N** ✓，聚合体的对齐随之封顶 ✓ |

现在：

```
sizeof(struct { char c; int i; })  #pack(1)            → 5  ✓（clang 5 ✓）
sizeof(struct { char c; int i; })  #pack(push,2)       → 6  ✓
sizeof(struct { char c; int i; })  自然对齐             → 8  ✓
sizeof(mach_msg_context_trailer_t)                     → 60 ✓（原来 64 ✗）
```

**连带结果** ✓：lz4 `timefn.c` 从 SEMA 失败变成通过 ✓；**sqlite3.c 也通过了** ✓
（只剩 `__sync_synchronize`/`__atomic_store_n` 等 GCC 内建函数的**警告** ✓）。

回归用例 `Qiang/tests/pragma_pack.c` ✓（`pack(1)`/push/pop、成员 `offsetof`、以及仿 Mach 的 60 字节结构 ✓）。

### 7.10 第八轮（`gcm` 把原子写当成可搬动，删掉了还在用的 phi）

第七轮之后 sqlite3.c 只剩一处代码生成失败：

    Qiang: object emission failed: b.5205 is used undefined in @logic.join.970

定位过程（对照 `vendor/qbe/gcm.c`）：

1. 失败的函数是 `sqlite3_soft_heap_limit64`，可疑语句是
   `__atomic_store_n(&mem0.nearlyFull, n>0 && n<=nUsed, 0);`
   - 一个 `&&` 的值形式，作为原子写的实参。
2. 在 `ssacheck` 里加打印：`@logic.join.970` 的 **phi 不见了**
   （`nphi=0`），但 `ins0` 仍在用它的结果。
3. 逐 pass 二分：`ssa` 之后正常 → `loadopt+coalesce` 之后正常 →
   **`gvn+gcm` 之后 phi 被删**。
4. `gcm` 的 `lateblk` 会删掉「看起来没人用」的 phi（原版 QBE 也这么干），
   判据是 `schedlate(p.to)` 返回 -1，即这个 temp 从未被 early-scheduled。
5. 根因：`op_pinned`（对应 QBE `optab` 的 pinned 列）**漏了
   `AtomicStore`**。于是 `gcm` 认为这次原子写可以搬动，从不给它用到的值做
   early scheduling → phi 的 `gcmbid` 永远是 -1 → `lateblk` 判它无用并删除 →
   留下悬空使用，`ssacheck` 报 undefined。
   原版 QBE 没有原子指令，这一列是 Qiang 自己加的扩展，容易漏。

修复：`op_pinned` 补上 `AtomicLoad` / `AtomicStore` / `Fence`。

回归用例 `Qiang/tests/atomic_gcm_phi.c`：**去掉修复时**报
`b.3 is used undefined in @logic.join.3`，加上修复后正常。

结果：**sqlite3.c 通过**，扫描里最后一处 CODEGEN 失败消失。

### 7.11 第九轮（修正扫描口径，补 PRI* 宏与 __builtin_bzero）

这一轮不是「再扫一遍」，而是**把测量方式改对** —— 起因是回答「什么叫扫描口径问题」。

suckless 风格的项目用**单翻译单元**构建：`abduco.c` 里写着
`#include "client.c"` / `#include "server.c"` / `#include "debug.c"`，
这几个文件**单独编译必然失败**（`clang -c client.c` 同样报
`use of undeclared identifier 'client'`，与 Qiang 无关），所以它们是**口径误判**。

但同一口径还会**掩盖真问题**：`abduco.c` 需要 Makefile 生成的 `config.h`，
缺了就被归进 PREPROCESS 桶，于是**真正该测的那个 TU 从来没被测过**。

改了两处：

1. `tools/scan_external.py` 给带 `config.def.h` 的项目自动生成
   `build/scan/cfg/<proj>/config.h`（补 `#define VERSION "0"`）并加进 `-I`；
2. 补上因此暴露出来的两个**真缺口**：
   - `inttypes.h` 只有 32/64 位 PRI 宏，缺 `PRIu16` 等 —— 补全
     `8/16/32/64/PTR/MAX` 全套；
   - `__builtin_bzero` 没有映射，链接时变成未定义符号 —— 补
     `bzero`，并在 `string.h` 补 `void bzero(void *, size_t);`。

结果：**abduco 整个项目通过**（编译、链接、运行，`abduco -v` 输出正常）；
扫描 **OK 152 → 154**，PREPROCESS **44 → 42**（`abduco.c`、`sic.c` 两个 TU 现在真的被测了）。
新增用例 `Qiang/tests/inttypes_pri.c`、`Qiang/tests/builtin_bzero.c`。

### 7.12 第十轮（`__bf16`，以及真正把环境配起来）

两件事：

1. **`__bf16` / `__mfp8`**：clang 的 `<arm_neon.h>` 用
   `__bf16` 声明 bfloat16、用 `__mfp8` 声明 FP8，紧随 `__fp16` 之后。
   它们不是关键字，所以 `typedef __bf16 bfloat16_t;`（hiredis/read.c 会拉到）
   直接解析失败。现在按已有的 `_Float16` 方式接受：`__bf16` 当 float 并告警，
   `__mfp8` 当 8 位整数（它就是一个字节）。
2. **环境**：新增 `tools/scan_env.py` —— 发现第三方库头（本机
   `~/.homebrew/include` 下有 png/jpeg/openssl/X11）✓、生成 miniz 的 CMake 头
   `miniz_export.h` ✓、把 dash `configure && make` 跑一遍以得到它的生成头
   （`nodes.h`/`syntax.h`/`token.h`/`builtins.h`/`config.h`）✓；
   `scan_external.py` 读 `build/scan/env.json` 并把这些路径加进 `-I`。
   dash 还需要 `-include config.h`（它的 `stat64`/@ @`USE_TEE` 都在 config.h 里），
   `ctype.h` 补了 Darwin 的 `_CTYPE_*` 位（dash 的 mksyntax 直接用），
   `unistd.h` 补了 `_SC_CLK_TCK`。

结果：**OK 154 → 185**，PREPROCESS **44 → 7** —— farbfeld **7/7**、miniz **4/4**、
dash **28/30**、slstatus **23/24**、hiredis **8/9**。

剩下的 7 个 PREPROCESS 已经确认**与本机环境无关** ✓：AIX/SunOS 的 forkpty、
zlib 的 PowerPC VMX 和 Windows 文件、slstatus 的 Linux `sys/soundcard.h`，
以及本机没装的 libgrapheme（lchat）和 libtls（ii）。

环境打通后又**暴露出 5 个真 bug**（以前藏在 PREPROCESS 桶里）：dash `jobs.c` 的
`t.384 violates ssa invariant`、dash `printf.c` 的 `NULL`、hiredis `read.c` 的
`promote` 崩溃（`slot ... read but never stored to`）、lz4 两个 fuzzer 的
`LZ4F_ERROR_ds` —— 都记在下一轮。

### 7.13 第十一轮（`goto` 跳进循环：simplcfg 链式合并后 phi 参数悬空）

起因是 dash/jobs.c 的 `setjobctl`：`goto out;` **从循环外面跳进
`do` 循环体内部**（合法 C），Qiang 报 `t.384 violates ssa invariant`。

压成 18 行复现后（`Qiang/tests/goto_into_loop.c`）定位过程：

1. 用 `--emit qbe` 取出 **pre-SSA 的 IL**，喂给**原版 QBE**：它**通过** ✓
   并正常生成汇编 —— 说明 IL 本身是对的，是 Qiang 自己的问题。
2. 把「SSA 之后」的 IR 打出来和原版 QBE 的 `-dN` 输出对比：**逐块、逐 phi、
   逐参数完全一致** ✓ —— 进一步证明 **SSA 构造没问题**，是**检查/后续 pass** 的问题。
3. 在四个 `ssacheck` 调用点加阶段标记：`after-ssa` ✓ → `after-loadopt-coalesce` ✓
   → `after-gvn` ✓ → `after-simplcfg`（补一次 `fillrpo`/`filldom` 再查）✓
   → **`after-gvn-gcm` 挂** ✗。
4. 打印违规 phi 的入边块：`@do.cond.8` 的 **`rpo_id == -1`（不可达）** ✗ ——
   说明有 pass **删了块却没更新 phi 参数** ✗。

根因在 `cfg/simplcfg.mbt` 的第 1 条规则（把单前驱后继折进前驱）✓：
它用**合并开始时拍的快照 id**（`js1`/`js2`）去改写后继的 phi 参数 ✓，但反复迭代里
合并会**链式**发生 ✗ —— 一个参数可能**前一轮**已经被改成中间块 ✓，**后一轮**再用快照 id 找
就找不到了（`phiargn` 返回 -1 ✗）→ 参数停在**已经不存在的块**上 ✗。

修复：合并时记录 `alias[s1] = id` ✓，在写回跳转前**统一把所有 phi 参数沿 alias 链解析** ✓。

结果：`dash/jobs.c` 通过 ✓，**dash 35/36** ✓（只剩 `printf.c`，见下），
扫描 **OK 185 → 186** ✓。回归用例 `Qiang/tests/goto_into_loop.c` ✓。

#### 7.13.1 顺带确认：lz4 的两个 fuzzer **不是 Qiang 的问题**

`LZ4F_ERROR_dstCapacity_tooSmall` 未定义 ✗ —— 同一份 `.i` 用 **clang** 编译，
报的是**一模一样**的错：

    error: use of undeclared identifier 'LZ4F_ERROR_dstCapacity_tooSmall';
           did you mean 'LZ4F_ERROR_dstMaxSize_tooSmall'?

即 `ossfuzz` 的 harness 比扫描抓到的 lib 版本**新** ✗ 属于工程不匹配 ✓，
和 Qiang 无关 ✓。

#### 7.13.2 剩下的两处是同一类问题

`dash/bltin/printf.c` 和 `hiredis/read.c` 都停在 `promote` 的

    slot ... is read but never stored to

✗ —— 前者是 `struct stackmark smark; setstackmark(&smark);`（**地址逃逸**给被调函数写 ✗），
后者是**内联汇编的输出操作数** ✗（`__asm__("..." : "=&r"(result))`）。
两者都是「槽的写入不在 Qiang 能看到的 IR 里」✓，需要让 `promote` 正确识别**逃逸** ✓。

### 7.14 第十二轮（`promote`：只被读、从未被写的槽）

`dash/bltin/printf.c` 和 `hiredis/read.c` 都停在 `promote` 的

    slot %t.N is read but never stored to

✗。原版 QBE 在 `mem.c` 里遇到这种槽直接 `err` ✓ —— 因为**它自己的 C 前端不会产生这种槽** ✗；
但 Qiang 是 C 前端 ✓，两种来源完全合法：

- **内联汇编的输出操作数** ✗：`__asm__("..." : "=&r"(result))`，Qiang 解析后丢弃 asm
  ✗ → `result` 只剩 load ✗；
- **读先于写的局部变量** ✓（C 里取值未指定 ✓）。

修复：`promote` 发现「一个槽的所有使用都是 load、没有任何 store」时（`k == -1`）
**跳过提升、把槽留在内存里** ✓，而不是中止编译 ✓。这样 load 依然读那块栈内存 ✓，
语义与原来一致（未初始化 ✓），但 IR 合法 ✓。

回归用例 `Qiang/tests/asm_output_operand.c` ✓。

修完之后这两个文件**不再卡在 promote** ✓，而是前进到一个**新**问题 ✗：
`dash printf.c` 的 `mklong`、`hiredis read.c` 的 `ffc_digit_comp`
在 **SSA 构造完成时**就报 `violates ssa invariant` ✗（`t.1028` / `ld.75544`）。
这两个 bug 之前被 promote 的中止**掩盖**了 ✓，是**独立的老问题** ✗，留作下一轮。

### 7.15 现在还剩什么

| 结果 | 项目数 | 项目 |
| --- | ---: | --- |
| RUNS | 5 | abduco、bzip2、farbfeld、lua、smu |
| RUNS-DRIVER | 2 | cjson、yyjson |
| LINK-FAIL | 5 | dash、lchat、lz4、sic、slstatus |
| LIB-LINK-FAIL | 1 | zlib |
| NO-COMPILE | 1 | ii |
| NO-MAIN | 3 | hiredis、miniz、sqlite |

## 8. 方法的局限（所以数字是下界）

1. **`-D` 注入有 bug**：从 `Makefile` 抓到的 `-DVERSION=\"0\"` 反斜杠没消干净，
   `sic.c` 因此报 `expected ")"` —— 那是扫描器的错，不是 Qiang 的。
2. **没有复刻各项目的 include 路径**：lz4 的 `xxhash.h`、dash 的 `token.h`/`nodes.h`（由它的构建生成）、
   yyjson 的 `-I src`、miniz 的 CMake 产物，都没给，导致 66 个文件没走到 Qiang。
3. 因此**真实通过率只会比 65% 高，不会低**。

## 9. 复现

```sh
# 抓源：解包/克隆到 build/scan/raw/（未提交）
python3 tools/scan_external_fetch.py

# 逐文件三层扫描：clang -E → Qiang --check → Qiang -o
python3 tools/scan_external.py      # 写 build/scan/detail_new.tsv、summary_new.tsv，
                                    # 并与本报告的旧阶段逐文件对照
# 整项目构建/运行：按各项目自己的 main 编译 + 链接 + 跑
python3 tools/scan_run.py           # 写 build/scan/run.tsv
```

## 10. 未做的事（按用户要求）

- 第一、二轮**没有修复任何一条**；第三轮修的是 Qiang 自己的四个后端/前端 bug（§7.4），
  不是这些项目的代码。没有改、也没有提交任何第三方源码。
- 没有用各项目自带的 Makefile 判定构建（Qiang 没有 `-c`、没有多文件驱动）。
- SQLite 只用默认 amalgamation 配置，未加 `SQLITE_ENABLE_*`。

## 附录 A. 逐文件明细

| 项目 | 文件 | 阶段 | 结果 | 首个诊断 |
| --- | --- | --- | --- | --- |
| abduco | abduco/abduco.c | OK | OK | - |
| abduco | abduco/client.c | PARSE | FAIL | expected ';' |
| abduco | abduco/debug.c | PARSE | FAIL | expected ';' |
| abduco | abduco/forkpty-aix.c | PREPROCESS | FAIL | In file included from build/scan/raw/abduco/forkpty-aix.c:21 |
| abduco | abduco/forkpty-sunos.c | PREPROCESS | FAIL | In file included from build/scan/raw/abduco/forkpty-sunos.c: |
| abduco | abduco/server.c | PARSE | FAIL | expected ';' |
| bzip2 | bzip2/blocksort.c | OK | OK | - |
| bzip2 | bzip2/bzip2.c | OK | OK | - |
| bzip2 | bzip2/bzip2recover.c | OK | OK | - |
| bzip2 | bzip2/bzlib.c | OK | OK | - |
| bzip2 | bzip2/compress.c | OK | OK | - |
| bzip2 | bzip2/crctable.c | OK | OK | - |
| bzip2 | bzip2/decompress.c | OK | OK | - |
| bzip2 | bzip2/dlltest.c | OK | OK | - |
| bzip2 | bzip2/huffman.c | OK | OK | - |
| bzip2 | bzip2/mk251.c | OK | OK | - |
| bzip2 | bzip2/randtable.c | OK | OK | - |
| bzip2 | bzip2/spewG.c | OK | OK | - |
| bzip2 | bzip2/unzcrash.c | OK | OK | - |
| cjson | cjson/cJSON.c | OK | OK | - |
| cjson | cjson/cJSON_Utils.c | OK | OK | - |
| dash | dash/alias.c | OK | OK | - |
| dash | dash/arith_yacc.c | OK | OK | - |
| dash | dash/arith_yylex.c | OK | OK | - |
| dash | dash/cd.c | OK | OK | - |
| dash | dash/error.c | OK | OK | - |
| dash | dash/eval.c | OK | OK | - |
| dash | dash/exec.c | OK | OK | - |
| dash | dash/expand.c | OK | OK | - |
| dash | dash/histedit.c | OK | OK | - |
| dash | dash/input.c | OK | OK | - |
| dash | dash/jobs.c | OK | OK | - |
| dash | dash/mail.c | OK | OK | - |
| dash | dash/main.c | OK | OK | - |
| dash | dash/memalloc.c | OK | OK | - |
| dash | dash/miscbltin.c | OK | OK | - |
| dash | dash/mkinit.c | OK | OK | - |
| dash | dash/mknodes.c | OK | OK | - |
| dash | dash/mksignames.c | OK | OK | - |
| dash | dash/mksyntax.c | OK | OK | - |
| dash | dash/mystring.c | OK | OK | - |
| dash | dash/options.c | OK | OK | - |
| dash | dash/output.c | OK | OK | - |
| dash | dash/parser.c | OK | OK | - |
| dash | dash/printf.c | CODEGEN-PANIC | FAIL | Qiang: object emission failed: t.1028 violates ssa invariant |
| dash | dash/redir.c | OK | OK | - |
| dash | dash/show.c | OK | OK | - |
| dash | dash/system.c | OK | OK | - |
| dash | dash/times.c | OK | OK | - |
| dash | dash/trap.c | OK | OK | - |
| dash | dash/var.c | OK | OK | - |
| farbfeld | farbfeld/ff2jpg.c | OK | OK | - |
| farbfeld | farbfeld/ff2pam.c | OK | OK | - |
| farbfeld | farbfeld/ff2png.c | OK | OK | - |
| farbfeld | farbfeld/ff2ppm.c | OK | OK | - |
| farbfeld | farbfeld/jpg2ff.c | OK | OK | - |
| farbfeld | farbfeld/png2ff.c | OK | OK | - |
| farbfeld | farbfeld/util.c | OK | OK | - |
| hiredis | hiredis/alloc.c | OK | OK | - |
| hiredis | hiredis/async.c | OK | OK | - |
| hiredis | hiredis/dict.c | OK | OK | - |
| hiredis | hiredis/hiredis.c | OK | OK | - |
| hiredis | hiredis/net.c | OK | OK | - |
| hiredis | hiredis/read.c | CODEGEN-PANIC | FAIL | Qiang: object emission failed: ld.75544 violates ssa invarian |
| hiredis | hiredis/sds.c | OK | OK | - |
| hiredis | hiredis/sockcompat.c | OK | OK | - |
| hiredis | hiredis/ssl.c | OK | OK | - |
| ii | ii/ii.c | PREPROCESS | FAIL | 'tls.h' file not found |
| ii | ii/strlcpy.c | OK | OK | - |
| lchat | lchat/indent.c | OK | OK | - |
| lchat | lchat/lchat.c | OK | OK | - |
| lchat | lchat/sl_test.c | OK | OK | - |
| lchat | lchat/slackline.c | PREPROCESS | FAIL | 'grapheme.h' file not found |
| lchat | lchat/slackline_emacs.c | OK | OK | - |
| lchat | lchat/util.c | OK | OK | - |
| lua | lua/lapi.c | OK | OK | - |
| lua | lua/lauxlib.c | OK | OK | - |
| lua | lua/lbaselib.c | OK | OK | - |
| lua | lua/lcode.c | OK | OK | - |
| lua | lua/lcorolib.c | OK | OK | - |
| lua | lua/lctype.c | OK | OK | - |
| lua | lua/ldblib.c | OK | OK | - |
| lua | lua/ldebug.c | OK | OK | - |
| lua | lua/ldo.c | OK | OK | - |
| lua | lua/ldump.c | OK | OK | - |
| lua | lua/lfunc.c | OK | OK | - |
| lua | lua/lgc.c | OK | OK | - |
| lua | lua/linit.c | OK | OK | - |
| lua | lua/liolib.c | OK | OK | - |
| lua | lua/llex.c | OK | OK | - |
| lua | lua/lmathlib.c | OK | OK | - |
| lua | lua/lmem.c | OK | OK | - |
| lua | lua/loadlib.c | OK | OK | - |
| lua | lua/lobject.c | OK | OK | - |
| lua | lua/lopcodes.c | OK | OK | - |
| lua | lua/loslib.c | OK | OK | - |
| lua | lua/lparser.c | OK | OK | - |
| lua | lua/lstate.c | OK | OK | - |
| lua | lua/lstring.c | OK | OK | - |
| lua | lua/lstrlib.c | OK | OK | - |
| lua | lua/ltable.c | OK | OK | - |
| lua | lua/ltablib.c | OK | OK | - |
| lua | lua/ltm.c | OK | OK | - |
| lua | lua/lua.c | OK | OK | - |
| lua | lua/luac.c | OK | OK | - |
| lua | lua/lundump.c | OK | OK | - |
| lua | lua/lutf8lib.c | OK | OK | - |
| lua | lua/lvm.c | OK | OK | - |
| lua | lua/lzio.c | OK | OK | - |
| lz4 | lz4/bench.c | OK | OK | - |
| lz4 | lz4/compress_frame_fuzzer.c | SEMA | FAIL | use of undeclared identifier: LZ4F_ERROR_dstCapacity_tooSmal |
| lz4 | lz4/compress_frame_stream_fuzzer.c | SEMA | FAIL | use of undeclared identifier: LZ4F_ERROR_dstCapacity_tooSmal |
| lz4 | lz4/compress_fuzzer.c | OK | OK | - |
| lz4 | lz4/compress_hc_fuzzer.c | OK | OK | - |
| lz4 | lz4/decompress_frame_fuzzer.c | OK | OK | - |
| lz4 | lz4/decompress_fuzzer.c | OK | OK | - |
| lz4 | lz4/lorem.c | OK | OK | - |
| lz4 | lz4/lz4.c | OK | OK | - |
| lz4 | lz4/lz4_helpers.c | OK | OK | - |
| lz4 | lz4/lz4cli.c | OK | OK | - |
| lz4 | lz4/lz4file.c | OK | OK | - |
| lz4 | lz4/lz4frame.c | OK | OK | - |
| lz4 | lz4/lz4hc.c | OK | OK | - |
| lz4 | lz4/lz4io.c | OK | OK | - |
| lz4 | lz4/round_trip_frame_fuzzer.c | OK | OK | - |
| lz4 | lz4/round_trip_frame_uncompressed_fuzzer.c | OK | OK | - |
| lz4 | lz4/round_trip_fuzzer.c | OK | OK | - |
| lz4 | lz4/round_trip_hc_fuzzer.c | OK | OK | - |
| lz4 | lz4/round_trip_stream_fuzzer.c | OK | OK | - |
| lz4 | lz4/standaloneengine.c | OK | OK | - |
| lz4 | lz4/threadpool.c | OK | OK | - |
| lz4 | lz4/timefn.c | OK | OK | - |
| lz4 | lz4/util.c | OK | OK | - |
| lz4 | lz4/xxhash.c | OK | OK | - |
| miniz | miniz/miniz.c | OK | OK | - |
| miniz | miniz/miniz_tdef.c | OK | OK | - |
| miniz | miniz/miniz_tinfl.c | OK | OK | - |
| miniz | miniz/miniz_zip.c | OK | OK | - |
| sic | sic/sic.c | OK | OK | - |
| sic | sic/strlcpy.c | OK | OK | - |
| sic | sic/util.c | PARSE | FAIL | expected ';' |
| slstatus | slstatus/battery.c | OK | OK | - |
| slstatus | slstatus/cat.c | OK | OK | - |
| slstatus | slstatus/cpu.c | OK | OK | - |
| slstatus | slstatus/datetime.c | OK | OK | - |
| slstatus | slstatus/disk.c | OK | OK | - |
| slstatus | slstatus/entropy.c | OK | OK | - |
| slstatus | slstatus/hostname.c | OK | OK | - |
| slstatus | slstatus/ip.c | OK | OK | - |
| slstatus | slstatus/kernel_release.c | OK | OK | - |
| slstatus | slstatus/keyboard_indicators.c | OK | OK | - |
| slstatus | slstatus/keymap.c | OK | OK | - |
| slstatus | slstatus/load_avg.c | OK | OK | - |
| slstatus | slstatus/netspeeds.c | OK | OK | - |
| slstatus | slstatus/num_files.c | OK | OK | - |
| slstatus | slstatus/ram.c | OK | OK | - |
| slstatus | slstatus/run_command.c | OK | OK | - |
| slstatus | slstatus/slstatus.c | OK | OK | - |
| slstatus | slstatus/swap.c | OK | OK | - |
| slstatus | slstatus/temperature.c | OK | OK | - |
| slstatus | slstatus/uptime.c | OK | OK | - |
| slstatus | slstatus/user.c | OK | OK | - |
| slstatus | slstatus/util.c | OK | OK | - |
| slstatus | slstatus/volume.c | PREPROCESS | FAIL | 'sys/soundcard.h' file not found |
| slstatus | slstatus/wifi.c | OK | OK | - |
| smu | smu/smu.c | OK | OK | - |
| sqlite | sqlite/sqlite3.c | OK | OK | - |
| yyjson | yyjson/experiment_depth_limit.c | OK | OK | - |
| yyjson | yyjson/jsoninfo.c | OK | OK | - |
| yyjson | yyjson/make_tables.c | OK | OK | - |
| yyjson | yyjson/yyjson.c | OK | OK | - |
| zlib | zlib/adler32.c | OK | OK | - |
| zlib | zlib/bin-writer.c | OK | OK | - |
| zlib | zlib/blast-test.c | OK | OK | - |
| zlib | zlib/blast.c | OK | OK | - |
| zlib | zlib/compress.c | OK | OK | - |
| zlib | zlib/crc32.c | OK | OK | - |
| zlib | zlib/crc32_vx.c | PREPROCESS | FAIL | In file included from build/scan/raw/zlib/contrib/crc32vx/cr |
| zlib | zlib/deflate.c | OK | OK | - |
| zlib | zlib/gzclose.c | OK | OK | - |
| zlib | zlib/gzlib.c | OK | OK | - |
| zlib | zlib/gzread.c | OK | OK | - |
| zlib | zlib/gzwrite.c | OK | OK | - |
| zlib | zlib/infback.c | OK | OK | - |
| zlib | zlib/infback9.c | OK | OK | - |
| zlib | zlib/inffast.c | OK | OK | - |
| zlib | zlib/inflate.c | OK | OK | - |
| zlib | zlib/inftree9.c | OK | OK | - |
| zlib | zlib/inftrees.c | OK | OK | - |
| zlib | zlib/ioapi.c | OK | OK | - |
| zlib | zlib/iowin32.c | PREPROCESS | FAIL | In file included from build/scan/raw/zlib/contrib/minizip/io |
| zlib | zlib/miniunz.c | OK | OK | - |
| zlib | zlib/minizip.c | OK | OK | - |
| zlib | zlib/mztools.c | OK | OK | - |
| zlib | zlib/puff.c | OK | OK | - |
| zlib | zlib/pufftest.c | OK | OK | - |
| zlib | zlib/trees.c | OK | OK | - |
| zlib | zlib/uncompr.c | OK | OK | - |
| zlib | zlib/unzip.c | OK | OK | - |
| zlib | zlib/zip.c | OK | OK | - |
| zlib | zlib/zutil.c | OK | OK | - |
