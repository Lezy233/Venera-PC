# Owner 正常启动无画面：诊断与最小修复

本记录覆盖此前“本批符合”的正常启动结论。owner 的真实现象是启动后没有可用应用窗口，伴随两条 right15、一条 bottom15/null；不是已显示页面内的普通溢出。旧 F2 控件/GUI证据保留，不替代正常入口证据。HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78，授权脏改全部保留。

## Tight loop 与精确红灯

未经包装的生产入口，四 XDG 为全新隔离目录，未读取或修改 owner 业务配置：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 \
DISPLAY=:1 GDK_BACKEND=x11 \
XDG_CONFIG_HOME=/tmp/ux1-startup-diagnostic-config \
XDG_DATA_HOME=/tmp/ux1-startup-diagnostic-data \
XDG_CACHE_HOME=/tmp/ux1-startup-diagnostic-cache \
XDG_STATE_HOME=/tmp/ux1-startup-diagnostic-state \
RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu \
fvm flutter run -d linux --no-pub
```

修前 `/tmp/ux1-b3-normal-startup-red.log`，PID1383929：right15×2、bottom15×1，随后 `Timed out waiting for OpenGL frame of size 900x600 (have 1x1)`。进程仍活；自身 X11 窗口0xc00002最终900×600+10+10且IsViewable。映射状态并不等于 Flutter 画面可用，不能据此否定 owner 无画面。另一个同名窗口0xa00002属于PID1377349，从未向它输入、关闭或改数据。VM Service/DevTools端口、dynamic_color正常提示不是根因。

获准只读 VM 脚本取得停滞后树 `/tmp/ux1-startup-normal-render-diagnostics.json`（派生render/widget树亦在/tmp）：RenderView当时已900×600、无持续OVERFLOWING，不能代替出错首帧。原无TTY命令stdin关闭，尝试内建dump未执行；未因此重启或放宽工具。随后核准 trace 只观察 drawFrame，原样调用production.main，不提前placement/show/设尺寸，继续原FlutterError而不吞错。

修前 trace `/tmp/ux1-b3-startup-trace-red.log`，PID1391810，frame1物理Size(1,1)、DPR1：

| 实际错误控件 | 约束/尺寸 | 精确症状 |
|---|---|---|
| window_manager-0.5.2/.../drag_to_resize_area.dart:80 Row | 最大宽1，size1×8；左右边缘共16 | right15 |
| 同文件127 Row | 最大宽1，size1×8；左右边缘共16 | right15 |
| 同文件78 Column | 最大宽高1，size1×1；上下边缘共16 | bottom15 |

完整creator链/constraints保留原始trace日志；未改pub-cache/依赖。后续Dart帧已900×600，原生仍等待该尺寸但持有1×1帧，证实不能只看最终RenderView。trace自身因提前创建binding而有一条Zone mismatch：两次对照均存在，属临时观察入口局限，不能算产品红灯或宣称该wrapper零异常；未经包装正常main无此异常。trace输出完整details后再转交原handler，所以原三条错误在trace文本中重复出现，规范计数取未包装日志2+1或trace的三个UX1_STARTUP_ERROR。

## 假设、单变量及排除

开始对照前已在delivery和进度列出四个有排名假设：

1. runApp早于native初始化，1×1首帧与随后show/restore产生绘制握手停滞。预测仅交换现有await与runApp应消除同组错误及超时。
2. Linux/Impeller独立尺寸切换故障。预测交换顺序后同后端仍卡1×1；实际同后端转绿，故不需要更换renderer/display/SDK。
3. owner恢复几何损坏。预测fresh有效默认几何不复现；实际fresh修前即红，排除owner配置作为必要条件；修后同目录和全新目录均绿。
4. 主题/字体缩放导致溢出、无画面另有原因。实际失败点是原生resize边缘在1×1约束下的固定16px，并非文字/漫画内容；同主题/缩放不变，初始化顺序单变量转绿。不缩字、裁剪或吞异常。

仅改 `lib/main.dart`：把现有 `await placement?.initialize()` 移到 `runApp(MyApp(host: host))` 前。architect已明确批准此受保护文件必要例外；其余main/runner不改，无新抽象/服务/等待/异常绕过，不改变WindowPlacementHost原几何恢复、Linux show顺序或失败抛出语义。HEAD原入口本来也是先runApp，故不能声称是F2卡片引入该排序；未另构建完整HEAD二进制，不冒称HEAD已运行对照。

## 同输入与全新目录的实际绿灯

- 同上述正常main命令、同四XDG/数据/后端/默认900×600几何，PID1395945：`/tmp/ux1-b3-normal-startup-order-green.log`三项错误/原生超时/Zone mismatch均0。核准固定PID窗口截图 `/tmp/ux1-b3-normal-startup-order-green.png` 实际绘出完整应用，900×600无裁截，已view_image并获architect独立核对。此为真正normal入口，不是fixture能开。TTY内建`t`只读dump进一步保留实际900×600渲染树；`q`退出Application finished，exit0。
- 原样已核准trace同四XDG对照，PID1400269：`/tmp/ux1-b3-startup-trace-order-green.log`，frame1即900×600，前三/前六帧均该尺寸，三个UX1_STARTUP_ERROR为0、原生超时0；观察包装的Zone mismatch仍1，严格分列。完成后退出wrapper，最终证明仍来自正常main。
- 为排除同目录混杂，最终正常main bundle直接在全新四XDG `/tmp/ux1-startup-fresh-{config,data,cache,state}` 冷启动，PID1403769，参数仅身份标记--ux1-startup-fresh，未包装/未种业务。`/tmp/ux1-b3-normal-startup-fresh-green.log`同组三项错误/超时/Zone mismatch均0；`/tmp/ux1-b3-normal-startup-fresh-green.png`实际900×600完整正常收藏首页，已view_image。空data路径启动前确认不存在，未修改owner配置。
- 自动只读日志比较 `/tmp/ux1-b3-startup-order-comparison.json` assert上述原始计数和首帧对照通过；不是把模型或内存重建当作正常启动。

正常入口对应的真实UI布局/首帧就是本次必要回归。按architect要求未添加搬语句抽象、源码镜像测试或人工skip；复用现有窗口初始化/生命周期真实测试，独立 `/tmp/ux1-b3-architect-startup-protection.log` **32通过0失败2既有skip**。两个skip均 `!Platform.isWindows`：interactive_window_placement_test的真实窗口等待placement再准备服务，以及application_host_integration_test的实际Windows DLL/核心存储最终关闭；Linux本次未运行它们，未改skip。原F2独立60/0/0为此前无变动生产组件保护历史，不与此组相加，不冒称本轮全量重跑。

## 工具边界、产物与清理

所有工具先全文/SHA核准，只有固定本轮PID、完整exe、四XDG/:1/x11和本地VM白名单的读取；截图前后校验PID/title/命令/实际窗口与root，拒绝覆盖，不向窗口输入。工具SHA及日志/图/派生树已入当前证据manifest；不将owner同名窗口放宽纳入helper。

红灯normal PID1383929在即时完整exe/命令/四XDG验证后仅SIGINT自身；trace1391810、1400269和直接fresh1403769由各自PTY CtrlC退出（诊断停止，exit1，不冒称正常UI关闭）。normal绿色1395945经自身flutter run的q退出exit0。最后升级权限ps精确核五PID均无记录、owner1377349仍存在，X11仅保留owner 0xa00002及qq/clipboard；未杀其他程序/显示服务。

最终正常main构建 `/tmp/ux1-b3-startup-final-main-build.log` 成功，kernel和正常main app.dill同为4100dcba44f44167d5b4559eff7c65443fff003627248eba1a83067829cc9acd，正常depfile含lib/main.dart、不含ux1_startup_trace.dart或ux1_f2_gui.dart。fresh绿色即运行此最终bundle。main SHA433fff080a42c3f22301e5269f19074a5fc0b21b1219611e2df5198435210cf0。

当前独立analyze `/tmp/ux1-b3-architect-startup-analyze.log` raw/unique50=38tool+12其他，完整集合added=[]removed=[]，comparison current_log已更新。当前生产19/测试31/证据139全部MATCH。原18/31/119保存pre-startup仅历史，可变构建产物不再宣称旧SHA匹配。除本次main两行顺序及此前planner design/browse-spec授权外，固定protected零diff，diffcheck/OpenSpec见最终delivery。

此前漏检原因：控件测试从有效viewport挂载，F2 GUI harness又提前初始化placement；正常main只build恢复而没有冷启动验收，故绕开了实际首帧。预防措施是把未包装normal入口fresh冷启动/实际帧纳入本批交付证据；不靠扩展无关矩阵或修改视觉契约。本次单变量循环已闭合，仍待architect独立复核及owner人工重试，不自行提交/归档/push。
