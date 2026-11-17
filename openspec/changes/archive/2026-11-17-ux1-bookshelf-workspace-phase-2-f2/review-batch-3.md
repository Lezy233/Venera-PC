# 1.3＋F2 独立复核（owner已验收）

**最终状态，2026-11-17：owner验收通过，授权本批阶段归档提交，未授权此次推送。** 后文待修复/待验收为诊断历史，首帧修复及实际显示路由恢复后已由owner确认通过。各测试集合分列不累加；活动5.x–7.x仍未完成。归档说明以本阶段README为准。

归档时再核：19生产/31测试仍全部MATCH，保护文件零非授权diff。139证据清单中bundle kernel在后续正常flutter run之后已被重写（当前51202f80…，独立复核时4100dcba…仍保留于正常main缓存app.dill）；其余138项匹配。该清单冻结的是复核当时产物，不更新旧hash冒称重新验证，也不宣称当前139项仍全MATCH；源码与测试未因此变化，未重跑已通过矩阵。

architect，2026-11-17；实施基准 HEAD `5548f5fedf1d40c28e1bcaefb41653a65106bd78`。本记录不代表完整 F2 或整个 UX1 验收通过，未授权提交。

## 独立自动化

命令前环境 `https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib`。

- 独立 `fvm flutter test --no-pub test/app_shell test/features/comic_widgets/comic_preview_test.dart test/features/search/result_preview_test.dart test/features/settings/preview_motion_setting_test.dart test/features/favorites/bookshelf_hit_target_test.dart test/features/favorites/favorite_hit_target_test.dart test/features/comic_widgets/comic_hit_target_test.dart --reporter expanded`：`/tmp/ux1-b3-architect-regression.log` **225 通过、1 失败、0 skip，78 秒**。
- 唯一失败为 `bookshelf_favorites_continuity_test.dart`：旧“长按＋主体点选”建场在新语义下打开详情，触发未初始化本地管理器和等待超时。executor 仅迁移为真实 hover/checkbox 选择，并选顶部可命中的卡片；原两实体、420px、页面/控制器和精确原 FocusNode 保持断言不删。卡片选择焦点替代原页级选择焦点，标签名断言对应调整。
- architect 审查上述精确 diff 后独立执行 `fvm flutter test --no-pub test/app_shell/bookshelf_favorites_continuity_test.dart --reporter expanded`：`/tmp/ux1-b3-architect-continuity-recheck.log` **1 通过、0 失败、0 skip，4 秒**，实际 entities book-8/book-9、420px。该失败已闭合；不把两次运行包装为一次 226 全绿。
- 独立 `fvm flutter analyze --no-pub`：`/tmp/ux1-b3-architect-analyze.log` raw/unique **50/50=38 tool＋12 其他**。与阶段记录的 50 条 baseline 逐项比较，`added=[] removed=[]`；比较记录 `/tmp/ux1-b3-architect-analyze-comparison.json`。
- 独立复核时 `batch-3-progress-production.sha256` 15 项、`batch-3-progress-tests.sha256` 26 项全部匹配；此后新增 continuity 及其他迁移须纳入最终 manifest，当前清单不是最终冻结。

## 1.3 后续阶段诊断重放

architect 独立运行 `fvm flutter test --no-pub /tmp/ux1_b3_click_baseline_test.dart /tmp/ux1_b3_reader_baseline_test.dart --reporter expanded`，日志 `/tmp/ux1-b3-architect-baseline-diagnostics.log`：**1 通过、4 预期失败、0 skip，2 秒**。这组是诊断现状，不计为常规 F2 通过集合或产品新增回归。

实际失败断言：单源及聚合在 read 偏好下仍打开 ComicPage 而非 ReaderWithLoading；隐藏工具时可命中 Slider 为 0 而非 1；漫画下部真实单击未打开工具。独立亮度按钮不冒泡为绿。初始化和作品/来源请求先决断言均通过。可重放源码/命令见 `batch-3-baseline-diagnostics.md`，本轮不实现 5.x/6.x，不把未来预期失败放入常规 test suite 或加 skip。

## GUI 与待定边界

已核准 `/tmp/ux1_f2_gui.dart` SHA `8b9a04d2fbe7a5a35c4fd359317d1a593ed9fc8e3fb09a1f1bdf96761f512911`；`/tmp/ux1_f2_x11.py` SHA `fa9ee5fc037cd08b0bb56a9c7739e8b527e40ed968850177ba7cd65196cc883a`。固定 F2 title/marker/exe/参数/四 XDG、DISPLAY=:1/GDK=x11、窗口/root 坐标和输入焦点检查；harness 复用生产启动与挂载前窗口初始化，F6 只读现场。正常 main/runner 不改。

实际隔离 PID487144；architect 已 view_image 核对 `/tmp/ux1-f2-captures/preview-dark-medium.png`、`drag-cancel-live.png`，并读 F6 rich-487144-1/2/3：预览有真实封面/概览/目录与常驻关闭；原选择焦点 identity 1012199551 在关闭后恢复，scroll 164.325030078125px 保持。预览实际文字缩放 1.0、systemReduceMotion=false；不将其称作 150% 或减少动画 GUI 证据。取消图为 Selected2/All1，后续完成拖放次数与请求仍待联查。

作者栏手势冲突已转 owner 选择，尚未获得答案；不据超时默认批准。普通网格可独立继续，作者栏原长按排序保持，4.4/4.5 不因局部绿勾整项。手动减少动画入口为 D10/4.5 已批准最小依赖，详见 `dispatch-batch-3.md`。

当前 protected（design-spec、正式 spec、pubspec yaml/lock、main/runner）零 diff，`git diff --check` 通过。最终 GUI/作者栏选择、剩余保护回归、正常 main 构建恢复和自有 fixture 清理仍待；待 executor 交付后继续独立复核。

## 后续独立增量与 4.3 必要依赖

architect 已独立复跑最终新增四文件（workspace_preview、comic_preview、result_preview、preview_motion_setting）：`/tmp/ux1-b3-architect-final-increment.log` **42 通过、0 失败、0 skip，13 秒**。另独立 F10 原拖动/独立排序/UI 与 F11 sidebar 四文件：`/tmp/ux1-b3-architect-author-sidebar-protection.log` **57 通过、0 失败、0 skip，7 秒**。与前段重叠的运行不相加。

当时 15 生产/29 测试/65 工具 GUI 清单全部 MATCH。独立抽查 `preview-compact-cn150-scrolled.png` 和 rich-801876 现场：实际文字缩放 1.5、受控 system disableAnimations=true，600×700 下正文可滚动、关闭及操作区保持可见。系统参数由临时外围 MediaQuery 注入，未宣称实际 OS 设置操作。手动对照见 executor 的 PID809100/磁盘记录。

独立联查 rich-487144-1/4/5：取消后仍 1 标签、drop 后恰 3 标签；原 active/recent 不变，新增 book-3/book-4 各为 ux1-fixture，details 列表没有因 drop 增加。独立升级权限 ps 三 PID 均不存在；:1 X11 树无 F2 窗口。正常 main kernel 含 lib/main.dart、不含 ux1_f2_gui.dart；构建日志与产物清单匹配。最后一次独立分析 `/tmp/ux1-b3-architect-final-analyze.log` raw/unique50=38+12，added/removed 空。

**上述仍非 4.3 最终通过。** 最终任务复核发现其“主体仍遵循全局点击设置”与现存单源/聚合 read 偏好失配，故 architect 要求撤回 4.3 勾选；executor 已撤回。2026-11-17 已批准仅沿用既有偏好的最小默认主体绑定，具体范围见 dispatch-batch-3.md。此后默认主体生产行为会变化，以上 SHA 和 GUI 仅为改前局部证据；必须按实际影响复验 read/viewDetail、实体/一次/返回/选集/hero、分析、正常构建与有界 GUI。不扩展 5.1 默认布局或设置重命名，不抹原 1.3 红灯历史。

当前 1.3/4.1/4.2 已完成；4.3 等必要绑定复核，4.4/4.5 仍依赖 owner 作者栏手势选择。未授权提交/归档/push。

## 4.3 必要绑定的独立复核结果

architect 独立执行 `fvm flutter test --no-pub test/features/search/card_body_preference_test.dart test/features/search/result_preview_test.dart test/app_shell/workspace_preview_test.dart test/app_shell/workspace_search_results_test.dart test/app_shell/workspace_aggregate_state_test.dart test/app_shell/workspace_local_reader_route_test.dart test/app_shell/workspace_reader_tabs_test.dart test/features/comic_widgets/comic_hit_target_test.dart test/features/favorites/bookshelf_hit_target_test.dart test/features/favorites/favorite_hit_target_test.dart --reporter expanded`：`/tmp/ux1-b3-architect-body-dependency.log` **123 通过、0 失败、0 skip，20 秒**。覆盖新默认主体、显式详情优先级、预览提升、返回及相关 B4/F1 保护；与前述重叠测试不相加。

最新独立分析 `/tmp/ux1-b3-architect-body-analyze.log` raw/unique **50/50=38 tool＋12 其他**，按完整诊断与 baseline 比较，added/removed 均空。18 生产文件及 30 测试文件 progress SHA 全部 MATCH；protected（含正常 main/runner）零 diff，`git diff --check` 通过。

已 view_image 核对 body-before-read/body-reader-real/body-read-return 三图，并逐项读取 rich-836728-1/2/3 JSON：结果 book-0 复选框已选；真实 Reader 为 book-0 / ux1-fixture / chapter1 / page1，显示已解码受控 PNG；返回后原焦点 identity323739778、全部原 scrollState/offset 和 checked 状态保持。标签数3、active/recent 不变；搜索 Alpha 一次，详情 book-0 一次，章节 ep-1 一次，返回不重发。完整 Flutter 帧与右侧被宿主裁截的 X11 图分列；本次 GUI 仅证明单源 read/返回，聚合和键盘由生产控件测试覆盖，不冒称外部站点验证。

独立升级权限核对 PID836728 已不存在，DISPLAY=:1 X11 树无本轮 fixture。`/tmp/ux1-b3-body-main-build.log` 构建成功；bundle kernel 与正常入口缓存 f9bb3e…/app.dill 同为 `7d0b8074e134f720d030c7c96a97ba00b77d7dcebc2f216f8d1c0e7de35585b4`。恢复正常 main 构建及 fixture 清理已闭合。

4.3 必要绑定符合派工边界，允许 executor 按真实证据完成该项勾选；作者栏手势仍待 owner 选择，4.4/4.5 整项继续保留未完成。此结论不是整个 F2/UX1 验收或提交授权。

最终交付已核：4.3 已勾，当前 progress 清单 18 生产／30 测试／87 GUI 项经 architect 独立计算全部 MATCH，diffcheck 通过；旧 65 项明确降为历史，不再声明其被覆盖的两项缓存产物匹配。executor 已停止等待作者栏手势裁定，未提交、归档或 push。

## owner 确认独立手柄后的续验（进行中）

owner 已明确采纳“独立拖动手柄，保留原长按排序”；architect 已更新 design D4、delta spec 两个场景与 dispatch，OpenSpec 校验通过。原等待设计决定状态已解除，不要求 owner 再确认任务内权限。

architect 独立执行 `fvm flutter test --no-pub test/app_shell/workspace_author_handle_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/author_shelf_independence_test.dart test/features/favorites/author_shelf_ui_test.dart test/features/favorites/sidebar_sections_test.dart --reporter expanded`：`/tmp/ux1-b3-architect-author-handle.log` **60 通过、0 失败、0 skip，19 秒**。新增三态分别覆盖600深色繁体150%、1000浅色简体150%、1400浅色英文；真实手柄空选集禁拖、取消零新增、跨作者同实体与同ID不同来源、每实体后台一次、原页/焦点/滚动、收藏身份及原长按本栏独立排序断言保留。与早先运行重叠，不合并计数。

最新独立分析 `/tmp/ux1-b3-architect-author-handle-analyze.log` raw/unique50=38 tool＋12其他，对照完整 baseline added/removed 均空。当前 4.4 已勾；4.5 等待新源码作者栏 GUI、正常 main 构建恢复与清理。GUI 继续复用原核准工具，不修改正常 main/runner。

### 最终独立结论：本批 1.3＋F2 符合，待 owner 人工验收

**后续 owner 验收阻断，覆盖本节通过状态：** owner 正常 `fvm flutter run -d linux` 报两条右侧15px和一条底部15px RenderFlex overflow。此前测试/隔离GUI事实保留，但不能证明该启动场景通过；已回派 executor 建立真实生产布局反馈循环并修复，修复后重新独立复核，当前未获 owner 验收，不提交/归档/push。VM Service/DevTools地址及dynamic_color日志不作为布局故障根因。

architect 已 view_image 核对 author-cancel-stable-1102014.png、author-drop-stable-1102014.png，并联查 rich-1102014-1/2/3.json：真实复选框选中 book-0/book-1；标题区手柄拖动 Escape 取消后仍3标签，成功 drop 后恰5标签，仅新增对应 ux1-fixture 两实体。当前 active/recent、原焦点 identity668761396、各 scrollState/offset 与两项选集均保持，详情及章节请求列表均空。截图为实际1000×700 X11窗口；GUI仅补本轮作者栏手柄，三态/跨来源及原长按排序由上述真实控件测试覆盖。受控来源、本地PNG的局限保持，不宣称外部站点验证。

正常 main 构建日志 `/tmp/ux1-b3-author-handle-main-build.log` 成功；独立核对 bundle kernel 与正常入口 f9bb3e…/app.dill 同为 `1f2eeebdb7ec768a0b1766056d04fb2a8b09a48295b238a6fc3762bfaa11518a`，depfile含lib/main.dart。升级权限精确 ps 无PID1102014，DISPLAY=:1 X11树无本轮fixture；未关闭其他程序。

最终当前 progress 清单 **18生产／31测试／119证据项全部独立 MATCH**，diffcheck 通过。design-spec、正式spec、pubspec yaml/lock、正常main/runner零diff；本轮design与delta spec变动为architect记录owner已明确选择的手柄契约，不是executor擅改。1.3及4.1–4.5全部勾选，5.x/6.x/7.x仍未完成。此次独立结论仅为该实施批次符合；保持未提交、不归档、不push，等待owner人工验收。

## owner 正常启动阻断的独立复核（修复中）

owner 澄清为“正常 fvm flutter run -d linux 无任何窗口弹出”。executor 在未包装正常 main、新鲜隔离数据复现两条 right15/一条 bottom15，继以 native OpenGL 900×600/have1×1 超时；进程存活、窗口对象已映射不等于内容实际可用。获准只观察的 StartupTraceBinding 捕获三条溢出全部发生于1×1首帧，此后尺寸900×600仍发生原生绘制超时。此前F2 harness提前placement初始化绕过正常入口，是验收覆盖缺口；旧正常main“构建成功”不足以证明启动可用。

architect 明确批准必要生产入口修复：lib/main.dart 仅将既有 `await placement?.initialize()` 移到 `runApp(MyApp(host: host))` 之前。已独立审查精确diff，只有该语句顺序变化；这是正常启动修复授权例外，**不再声明main零diff**，runner及其他受保护文件仍不可擅改。不增新抽象、不改几何/主题/渲染后端或owner数据。

architect 已view_image核对 `/tmp/ux1-b3-normal-startup-order-green.png`：未包装正常main实际900×600窗口显示收藏空页；其正常run日志无原三条15px及原生1×1超时。原样trace对照 `/tmp/ux1-b3-startup-trace-order-green.log` 首帧即900×600且后续保持。只读诊断工具及trace/capture均逐份全文、SHA和固定进程/隔离身份核准，不操作owner同名窗口。

独立 `fvm flutter test --no-pub test/app_runtime/window_placement_host_test.dart test/app_runtime/interactive_window_placement_test.dart test/app_runtime/application_host_test.dart test/app_runtime/application_host_integration_test.dart --reporter expanded`：`/tmp/ux1-b3-architect-startup-protection.log` **32通过、0失败、2既有skip**，不冒称0skip。独立 `/tmp/ux1-b3-architect-startup-analyze.log` raw/unique50=38+12，与完整baseline added/removed均空。最终默认新鲜目录正常启动对照、当前产物/SHA及精确清理仍待末次核验，随后覆盖本节进行中状态。

### 启动修复最终独立结论：符合，恢复待 owner 验收

**二次 owner 验收仍阻断：** PID1414688 正常run日志已无原15px和1×1帧超时，但owner仍看不到窗口。此前“无窗口已修复”的整体结论撤回；仅首帧问题红绿事实保留。已回派executor核对该实际进程的白名单显示环境/窗口所属显示会话及几何，不操作owner窗口，不以:1隔离程序截图替代owner桌面可见性。匹配现场证据及复核完成前继续待修复，不提交归档push。

已补新鲜四XDG空目录、当前正常main bundle直接冷启动：`/tmp/ux1-b3-normal-startup-fresh-green.log` 无原三条15px或原生1×1超时；architect view_image核对同名前缀png，实际900×600生产收藏页显示，与复用红灯目录的正常fvm run绿色证据分列。保留既有MESA/Atk环境提示，不冒称日志绝对无警告。

独立精确ps确认诊断PID1383929/1391810/1395945/1400269/1403769均已退出。:1仅残余同名窗口0xa00002属另一个PID1377349，未操作，不要求清理owner进程。当前bundle kernel与正常入口app.dill同为 `4100dcba44f44167d5b4559eff7c65443fff003627248eba1a83067829cc9acd`，正常main产物已恢复，不是trace包装。

独立计算当前SHA清单 **19生产／31测试／139证据项全部MATCH**，diffcheck通过；design-spec/正式spec/pubspec yaml与lock/runner零diff。main仅授权的初始化顺序两行diff，SHA `433fff080a42c3f22301e5269f19074a5fc0b21b1219611e2df5198435210cf0`。两项skip经源文件核实均为既有`skip: !Platform.isWindows`，Linux不执行，未新增skip。此次不新增镜像源码测试，真实正常入口冷启动和原样首帧trace为该顺序缺陷的红绿反馈循环，原F2/窗口生命周期回归事实分列。

owner本次阻断已按相同生产启动路径修复并独立复核通过；恢复待owner人工验收，之前1.3/F2完成状态保留。仍未提交、归档、push，不启动5.x/6.x其他生产功能。

## 第二次无可见窗口：实际显示环境差异已查明，待 owner 恢复后验收

只读固定PID1414688证据 `/tmp/ux1-owner-1414688-display-probe.json` 显示该正常入口继承DISPLAY=:1/GDK_BACKEND=x11及旧测试XDG `/tmp/ux1-f1-run/xdg/*`，同时会话为wayland/wayland-1；其窗口0xa00002实际900×600+10+10且IsViewable，位于1080×760的:1、无_NET_SUPPORTING_WM_CHECK。此为显示路由差异，不是已消除的15px首帧问题重现。

architect独立只读核实进程1871程序Xwayland、显示参数`:2`；:2 root为5120×1600/24bit，_NET_SUPPORTING_WM_CHECK=0x200002，_NET_WM_NAME=xwayland-satellite。owner当前进程被旧export送往:1，而实际桌面Xwayland在:2，足以解释桌面上看不到已映射窗口。未截图/输入/移动/关闭owner窗口，未改owner配置或新增产品修复，pubspec yaml/lock零diff。

给owner一次性恢复命令：`env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_CACHE_HOME -u XDG_STATE_HOME DISPLAY=:2 GDK_BACKEND=x11 fvm flutter run -d linux --no-pub`。先自行在旧flutter run终端按q结束旧进程；不删任何数据，不永久修改shell。仍待owner在实际桌面确认可见并继续F2验收，不宣称该命令已由owner执行或验收通过；不提交归档push。
