# F1 阶段独立复核（进行中）

2026-11-16，architect；HEAD `6f1f1bc01ce69be91e62b9474a0b95f83a752d73`，未提交。本文不是整个 UX1 完成或 owner 验收结论。

## 当前源码独立检查

- `sha256sum -c batch-2-progress-production.sha256`：34 个文件全部匹配。
- `sha256sum -c batch-2-progress-tests.sha256`：27 个文件全部匹配。
- `git diff --check` 通过；design-spec.md、openspec/specs/**、pubspec.yaml、pubspec.lock、lib/main.dart、linux/runner 零 diff。change 四件套中已有 architect 授权的 D5/D9 契约修订，不将其误报为未授权修改。
- 独立命令：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_tabs_test.dart test/app_shell/workspace_reader_state_test.dart test/app_shell/workspace_local_reader_route_test.dart test/features/reader/loading_history_test.dart --reporter expanded`。
- 日志 `/tmp/ux1-architect-current-reader-titles.log`：**4 通过、0 失败、0 skip**，10 秒。内存查询插件提示出现在日志中，最终测试成功；不冒称零日志异常。
- 独立 `fvm flutter analyze --no-pub`：日志 `/tmp/ux1-architect-current-analyze.log`，raw/unique **50/50 = 38 tool + 12 其他**。与 `/tmp/ux1-35-36-analyze.log` 逐条比较，`added=[] removed=[]`；比较记录 `/tmp/ux1-architect-current-analyze-comparison.json`。

## GUI 核查与剩余边界

基础 PID A240681 → B243366 → C245856 已由 executor 记录实际正常退出与新进程，证明 Favorites + Settings 的 restore/fresh。architect 已抽查对应设置截图。该基础组不能替代搜索、详情、Reader 或辅助页恢复。

丰富场景 harness `/tmp/ux1_f1_gui.dart` SHA `105d00d2351c2cc5ab45896ece0fe4bec52a70cbcd537bc83a1cb59f8ecb0cfe` 已读核；固定隔离 XDG、受控来源和真实图片、首次 seed、不改 workspaceStartup/Snapshot、F6 只读现场记录。helper `/tmp/ux1_f1_x11.py` SHA `7c38817b147b632f869b38effdbe0970dd0fb89ead9058baa4e003aae9ac19fd` 已读核；窗口身份、PID/exe/参数/环境/坐标边界、键盘设置并回读精确焦点均核对。生产 main/runner 不因 fixture 改动。

rich PID255580 → 新 PID266168 → 新 PID269207，executor 已记录正常关闭 exit0。architect 已 view_image 抽查 `/tmp/ux1-f1-captures/rich-a-favorites.png`、`rich-a-all-four.png`、`rich-b-restored-parent.png`、`rich-266168-4.png`。B 的详情父页明确显示辅助页恢复反馈；Reader 图显示实际第 2 页。

architect 独立读取 `/tmp/ux1-35-rich-a-before-exit.json` 和 B 的实际 F6 `/tmp/ux1-f1-captures/rich-266168-1.json`：5 个 tab 的 ID/顺序、全部 routes/views、active、recent 均一致；仅辅助页 restoreParent 标记由 true 被消费为 false。B 启动只有 book-2 详情请求一次，search/chapter 均 0。独立比较输出 `/tmp/ux1-architect-rich-initial-comparison.json`。

已独立读取 B 的 F6 现场 2/3/4：收藏 book-3/book-4 选集、159px、local-favorites-selection 焦点；Alpha/other 单次搜索、212px；Reader book-6/ux1-fixture、chapter1/page2、focus true，首次激活只请求对应 ep-1 一次。C 的再次恢复与反馈不重复由 executor 记录，最终交付还需联查。

**尚未判符合**：B 启动的 SliverGrid crossAxisCount0 断言及各次首帧 15px RenderFlex 不能因稳定帧正确而忽略。executor 正做仅 /tmp 窗口初始化时序的单变量对照；3.5 保持未勾。正常 main 最终构建、自有 fixture 清理及最终交付仍待核查。

## 最终 3.5 结论：符合

以下结论覆盖上文进行中状态，仅针对 3.5，不代表 F2、5.x/6.x 或整个 UX1 完成。

临时 harness 最终 SHA `42bd1cd8a24e937ba5493deb0f5c763c7c9a81d24817b9c6f544d4600f0d43ad`，architect 已核精确 diff：仅将既有 placement.initialize/setSize/setPosition 移到 runApp 前并记录 physicalSize，无等待、异常屏蔽或生产修改。PID275351/277155/281091 挂载前实际尺寸 1000×700；新增日志 `/tmp/ux1-35-order-startup-new-log.txt` 只有 Reader 信息，Flutter error header 0。结合 Reader 恢复、带反馈详情恢复和 fresh 启动对照，支持此前异常来自临时宿主初始化时序；原错误记录保留，不宣称原始各轮零异常。原生 DRI3/Atk 警告仍属交付局限。

architect 独立读取 D 的真实 implicitData.json 副本 `/tmp/ux1-35-order-d-before-exit.json` 内 workspaceSnapshot，并与 E 的 `/tmp/ux1-f1-captures/rich-277155-1.json` 对照：5 个 tab ID/顺序、routes/views、active/recent 一致，仅辅助页恢复标记被消费；E 仅请求当前 book-2 详情，搜索/章节均 0。独立 view_image 核对 `order-e-restored-parent.png` 为详情父页和一次明确反馈，`order-f-fresh.png` 为 All1/Favorites。独立读取 F 的 `rich-281091-1.json`：唯一 favorites route，详情/搜索/章节请求全部为空。修改 fresh 时当前 5 标签保持的证据见交付 E 的设置截图和现场 JSON；此前 B/C 验证现场与反馈不重复继续有效。

最终检查：

- `batch-2-final-35-evidence.sha256` 的工具、GUI、快照、日志全部匹配；34 生产/27 测试 manifest 全部匹配，故本轮无生产或测试实现增量。
- `tasks.md` 3.5 已勾并备注。protected 零 diff、`git diff --check`、`openspec validate --changes ux1-bookshelf-workspace` 均通过（1 passed、0 failed）。planner 三份契约不变；tasks 授权勾选导致旧 tasks SHA 改变，不误称四件套原 SHA 全匹配。
- 独立读取正常 main 构建日志 `/tmp/ux1-35-final-normal-main-build.log` 成功；正常 debug `kernel_blob.bin` SHA `62d480b6e83bf6c6c8b3dfbdc3109f79e1ee02f4320824bbdfe10234a55f5962` 与结果清单一致。main/runner 未改。
- 在审批服务额度刷新后，architect 独立升级权限执行 `DISPLAY=:1 xwininfo -root -tree` 和指定六 PID 的 ps：只有 qq/Chromium clipboard 辅助窗口，无本轮 fixture 窗口；六个 PID 均不存在。未操作其他程序。
- 当前独立标题相关回归仍为 4 通过、0 失败、0 skip；analyze raw/unique 50/50=38+12，具体集合零增减，见本文前段。GUI 场景不累加到 Flutter 测试数。

未提交、未归档、未推送；保持待 owner 验收。本轮不跨入 F2。
