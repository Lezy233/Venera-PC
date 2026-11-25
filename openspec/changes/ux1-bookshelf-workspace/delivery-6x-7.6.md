# UX1 6.6 → 7.6 执行交付（2026-11-25）

- 分支：`ux1-reader-6x`，基于 `fix/ci-quality-gates @ ecaa99f`；本地提交，**未 push、未建 PR、未 archive**。
- 范围：UX1 6.6 → 6.7 → 6.1 → 6.2 → 6.3 → 6.4 → 6.5，最后 7.6 全量归零；逐项更新 `tasks.md` 并写命令/计数/证据。
- 角色：本轮为 executor 实施；architect 独立复核前不推送。发现契约冲突时按 owner 当次裁定执行（见「契约裁定」）。

## 1. 7.6 全量测试归零

基线（`full-suite-baseline.md`，HEAD `cec0762` worktree）：**5719 通过 / 64 失败 / 150 skip**；64 项与 HEAD 逐条一致。

最终（CI 等价）：**5791 通过 / 0 失败 / 150 skip**，`exit 0`（`All tests passed!`）；无覆盖率 `--concurrency=4` 全量通过，覆盖率报告用同套测试 `--concurrency=2` 取得：`coverage/lcov.info` **49496/60037 行 = 82.44%**（538 个文件）。

- 全量无覆盖率、`--concurrency=4`：`/tmp/ux1-7x-interim.log` **5719+72=5791 通过 / 0 失败 / 150 skip**，`exit 0`。
- 带覆盖率、`--concurrency=2`：`/tmp/ux1-76-cov2.log` **5791 通过 / 0 失败 / 150 skip**，`exit 0`，生成 `coverage/lcov.info`（82.44%）。
- ⚠ 本地环境限制：`flutter test --coverage --concurrency=4` 在本机连续 3 次尝试均在收尾阶段出现工具级故障（`Failed to load ...: Shell subprocess cleanly reported an error` / 2 个 flutter_tester 挂起在加载阶段，**无任何测试断言失败**；本机 15GB 内存被浏览器/IDE 占用约 12GB，coverage 模式下 4 并发峰值不足以稳定启动测试 shell）。为取得覆盖率报告改用同套测试 `--concurrency=2` 完整通过；测试结果本身已由 `--concurrency=4` 无覆盖率全量 run 证明为 0 失败。CI 机器内存充足时应可直接用 `flutter test --coverage` 复现；如需本地强制 4 并发覆盖率，建议先释放内存/加 swap。

按文件逐条状态（`full-suite-baseline.md` §B 的 64 项，28 个文件；全部在本轮全量跑中通过）：

| 文件 | 基线失败 | 状态 |
|---|---|---|
| `app_shell/bookshelf_favorites_continuity_test.dart` | 1 | 全部通过 |
| `app_shell/bookshelf_workspace_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_aggregate_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_author_handle_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_auxiliary_route_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_background_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_details_state_test.dart` | 2 | 全部通过 |
| `app_shell/workspace_focus_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_history_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_keyboard_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_local_reader_route_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_preview_test.dart` | 3 | 全部通过 |
| `app_shell/workspace_reader_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_reader_tabs_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_route_lifecycle_test.dart` | 3 | 全部通过 |
| `app_shell/workspace_search_results_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_search_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_tab_input_test.dart` | 2 | 全部通过 |
| `features/favorites/bookshelf_hit_target_test.dart` | 4 | 全部通过 |
| `features/favorites/favorites_reorder_test.dart` | 4 | 全部通过 |
| `features/favorites/folder_creation_presentation_test.dart` | 2 | 全部通过 |
| `features/reader/auto_reading_viewport_test.dart` | 2 | 全部通过 |
| `features/reader/gallery_viewport_rendering_test.dart` | 2 | 全部通过 |
| `features/reader/information_overlay_test.dart` | 6 | 全部通过 |
| `features/reader/reader_exit_integration_test.dart` | 15 | 全部通过 |
| `features/reader/shell_presentation_test.dart` | 3 | 全部通过 |
| `features/search/search_profile_flow_test.dart` | 1 | 全部通过 |
| `features/settings/settings_inplace_editing_test.dart` | 1 | 全部通过 |
差值 +72 = 64 项基线失败全部转绿 + 8 项本轮新增测试；无新增 skip、无删除断言、无放宽 finder。

分组归零对照（64/64）：

| 分组 | 基线失败 | 归零方式 | 证据 |
|---|---|---|---|
| reader-shell 6.x（reader_exit_integration 15、information_overlay 6、shell_presentation 3、auto_reading_viewport 2、gallery_viewport_rendering 2） | 28 | 生产修复：`compactBody` cross-axis stretch（内容宽度塌陷，information_overlay 6）、`compactHeight` 常量与布局槽（viewport 8px 差 4）、移除 fullscreen 的 `kDebugMode` 提前返回（窗口生命周期 8）、工具隐藏时不再保留旧工具树（progress 7、shell 3）、测试迁移 15 项 reader_exit 旧断言到 6.x 契约 | `/tmp/ux1-r-exit2.log` 157/0/23、`/tmp/ux1-61-63-final.log` 203/0/23（含 6 文件）、`/tmp/ux1-67-final.log` 4/0/0 |
| workspace/bookshelf app_shell（24 项中 22 项由 app-shell 并行执行器完成，reader 2 项由本轮完成） | 24 | 生产修复：`refreshWorkspaceTabs` build 期 post-frame 通知、WindowFrame/根导航 focus 边界 parentScope、合并顶栏「全部 N」root navigator 菜单、标签条 `FocusTraversalGroup`、150% 溢出收敛、滚动恢复兜底、`_syncChrome` 先发布 readerActions 再决定标签行可见；其余为测试迁移到合并顶栏/侧栏搜索入口 | `/tmp/ux1-final-app_shell-dir.log`（+98/0 其余目标文件 29 例全绿，唯一红为下述已裁定的 density 保护，已在本次迁移）。`/tmp/ux1-61-63-final.log`（workspace_reader_state 含 reader 2 项） |
| favorites/search/settings（12） | 12 | 产品修复：排序编辑器复用收藏 bookshelf 卡片（`comic_reorder_page` + `ComicTile.delegate` 的 density 钉定，见契约裁定）；其余 4 文件为测试迁移（长按选集→复选框、Series 菜单定位、聚合卡 `ComicTile`、720px 右栏滚动可见） | `/tmp/ux1-fav-all5.log` 61/0/0、`/tmp/ux1-reorder-final.log` 8/0/0 |

非本轮新增红已全部处理：唯一曾因并行产品改动新红的是 `bookshelf_density_isolation_test`（见契约裁定，已迁移并通过）。

复跑命令（最终）：

```sh
cd /home/_Le/Code/Projects/Venera-Next
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 \
  LD_LIBRARY_PATH=$PWD/build/test-native/lib \
  fvm flutter test --coverage --concurrency=4
```

**最终 CI 等价计数**：`5791 通过 / 0 失败 / 150 skip`（`exit 0`，`All tests passed!`）。覆盖率：`coverage/lcov.info` **49496/60037 行 = 82.44%**（538 个文件）。

- 全量无覆盖率、`--concurrency=4`：`/tmp/ux1-7x-interim.log` **5719+72=5791 通过 / 0 失败 / 150 skip**，`exit 0`。
- 带覆盖率、`--concurrency=2`：`/tmp/ux1-76-cov2.log` **5791 通过 / 0 失败 / 150 skip**，`exit 0`，生成 `coverage/lcov.info`（82.44%）。
- ⚠ 本地环境限制：`flutter test --coverage --concurrency=4` 在本机连续 3 次尝试均在收尾阶段出现工具级故障（`Failed to load ...: Shell subprocess cleanly reported an error` / 2 个 flutter_tester 挂起在加载阶段，**无任何测试断言失败**；本机 15GB 内存被浏览器/IDE 占用约 12GB，coverage 模式下 4 并发峰值不足以稳定启动测试 shell）。为取得覆盖率报告改用同套测试 `--concurrency=2` 完整通过；测试结果本身已由 `--concurrency=4` 无覆盖率全量 run 证明为 0 失败。CI 机器内存充足时应可直接用 `flutter test --coverage` 复现；如需本地强制 4 并发覆盖率，建议先释放内存/加 swap。

按文件逐条状态（`full-suite-baseline.md` §B 的 64 项，28 个文件；全部在本轮全量跑中通过）：

| 文件 | 基线失败 | 状态 |
|---|---|---|
| `app_shell/bookshelf_favorites_continuity_test.dart` | 1 | 全部通过 |
| `app_shell/bookshelf_workspace_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_aggregate_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_author_handle_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_auxiliary_route_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_background_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_details_state_test.dart` | 2 | 全部通过 |
| `app_shell/workspace_focus_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_history_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_keyboard_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_local_reader_route_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_preview_test.dart` | 3 | 全部通过 |
| `app_shell/workspace_reader_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_reader_tabs_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_route_lifecycle_test.dart` | 3 | 全部通过 |
| `app_shell/workspace_search_results_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_search_state_test.dart` | 1 | 全部通过 |
| `app_shell/workspace_tab_input_test.dart` | 2 | 全部通过 |
| `features/favorites/bookshelf_hit_target_test.dart` | 4 | 全部通过 |
| `features/favorites/favorites_reorder_test.dart` | 4 | 全部通过 |
| `features/favorites/folder_creation_presentation_test.dart` | 2 | 全部通过 |
| `features/reader/auto_reading_viewport_test.dart` | 2 | 全部通过 |
| `features/reader/gallery_viewport_rendering_test.dart` | 2 | 全部通过 |
| `features/reader/information_overlay_test.dart` | 6 | 全部通过 |
| `features/reader/reader_exit_integration_test.dart` | 15 | 全部通过 |
| `features/reader/shell_presentation_test.dart` | 3 | 全部通过 |
| `features/search/search_profile_flow_test.dart` | 1 | 全部通过 |
| `features/settings/settings_inplace_editing_test.dart` | 1 | 全部通过 |


## 2. 契约裁定（owner 本次会话拍板）

`favorites_reorder_test`（在 7.6 的 64 项内，要求排序编辑器卡片尺寸 == 收藏页卡片尺寸）与 `bookshelf_density_isolation_test`（2026-11-16 F1 归档保护，要求排序编辑器保持 HEAD 七列几何且不随收藏密度变化）在 UX1 5A 把收藏页改 bookshelf 高卡后数学上互斥。owner 选择 **A 合成方案**：

- 排序编辑器改用收藏 bookshelf 卡片渲染（`comic_reorder_page.dart`：`bookshelf: gallery`），但**钉定舒适密度**（`ComicTile.compactDensityOverride` / `SliverGridDelegateWithComics.densityOverride` 传 `false`），因此收藏密度设置不能改变其尺寸；
- `bookshelf_density_isolation_test` 的两处实现 pin 迁移：`bookshelf == reorder`、删除「HEAD 七列宽度」pin（几何一致性由 `favorites_reorder_test` 负责），保留「切 comfortable/compact 尺寸不变」的隔离实质断言；
- 探针证据：未钉密度时排序页随密度 158.7×289.1 ↔ 134.9×254.1（违反隔离），钉定后两密度同尺寸；两文件合跑 `/tmp/ux1-reorder-final.log` 8/0/0。

## 3. 逐项实施与证据

### 6.6 快捷设置方案选择持久化
见 `tasks.md` 6.6 备注。**结论：未能复现「选择后无法持久化」的产品红灯**；此前 WIP 记录的约 33 秒「保存等待超时」根因是等待了错误的 save owner（面板 `ReaderQuickSettingsPanel` 而非其内层 `ReaderPresetSelector` 的 `SettingsSaveState`）。本轮新增真实控件测试并全绿：

- `test/features/reader/quick_settings_panel_test.dart` 新增 3 项：选择方案→关闭/重开面板仍选中且 `readerPresetSelections`/`readerPresetBindings` 落盘；清除为 None 持久化；写盘阻断→Retry 只完成恢复、**不自动重放失败 apply**（与 B3 spec `重试只保存恢复后的最新有效状态，不自动重放失败编辑` 一致），随后显式再选才保存。文件合跑 **9/0/0**，日志 `/tmp/ux1-66-all.log`。
- `test/features/reader/reader_exit_integration_test.dart` 新增真实 Reader 级 1 项：真实 `ReaderSettingsPanel` 预设下拉选择→阅读模式生效、comic 层启用、属性 `readerMode` 更新→Escape 关闭面板仍保持→卸载后重进 Reader 从存储恢复同一方案与下拉 `initialValue`。日志 `/tmp/ux1-66-reader.log` 1/0/0。
- B3/F9 保护：`reader_presets_test` + `reader_preset_ordering_test` + `reader_settings_persistence_test` **39/0/0**。
- 生产代码零改动；未新增文案。**局限**：本地漫画 fixture 未单列「切换章节」维度（重进 Reader 已覆盖同一 `active` 作用域读取路径），如 architect 要求可在复核中提出。

### 6.7 精简进度线（owner 复验否决项，重建真实红）
- 重建红：把生产临时改回被否决的 Stack overlay 版本，新布局契约测试 `/tmp/ux1-reader-67-layout-red.log` 失败（`content.bottom=600 > bar.top=592`，漫画被 8px 条覆盖），恢复生产后 `/tmp/ux1-67-final.log` **4/0/0**。
- 新测试 `test/features/reader/compact_progress_layout_test.dart`：隐藏工具时 `ReaderBottomBar` 高 = `ReaderBottomBar.compactHeight`(8)、内容 bottom == 条 top、`overlaps==false`、`shell.height == content+bar`、无 `BlurEffect`/first_page/last_page；展开后恰一个 `ReaderProgressSlider`、完整进度与章节按钮、底边对齐；dark+150%+system reduce motion；manual `reduceMotion` 单帧定位。
- 保护：`bottom_actions_test` 19/0/0；`gesture_lifecycle`+`slider_navigation` 等 45/0/0。

### 6.1 / 6.2 / 6.3
真实 MainPage 证据（`/tmp/ux1-61-63-final.log` **203/0/23**，23 为既有 Windows skip）：工具显示两行（合并工作区行+阅读器工具行，后者 top≥前者 bottom，无第三行）、恰一个进度组件；沉浸隐藏标签/书架 chrome 且同一 Reader/标签/章节页码/请求保持、Escape 恢复；中心/边缘单击只切工具（页码不变）、3 秒不自动隐藏、关闭后旧章节按钮不存在；章节浮层不改漫画 rect（像素测量见 §4）、按钮不冒泡、两次 Escape 逐级（浮层→沉浸）；普通模式 Escape 找回工具。生产修复：`desktop_workspace._syncChrome` 先发布 readerActions 再决定标签行可见性（退出沉浸时标签行恢复）。

### 6.4
深色例外 grep 检查（reader chrome 无 `Colors.black`/`Brightness.dark`，全部 `Theme.colorScheme`）；`shell_presentation_test` 3/0/0（light/dark×scale 1/2/3.2、系统减少动画即时定位）；`information_overlay_test` 8/0/0（AT 文本仅一次、点击不拦截）；`compact_progress_layout_test`（dark/150%/system+manual reduce motion）；键盘/焦点语义由 `workspace_reader_state`、`workspace_focus/keyboard/tab_input`（app_shell 组）覆盖。

### 6.5 真实坐标 GUI
隔离虚拟显示 `Xvfb :7 1500x950x24`，命令级 `-u WAYLAND_DISPLAY GDK_BACKEND=x11 XDG_SESSION_TYPE=x11` + 独立 `XDG_DATA_HOME/CONFIG/CACHE`，运行本分支 `flutter build linux --debug` 生产 bundle（1440×900 窗口）；隔离目录内真实本地漫画（`local_path` + `local.db` + 真实 PNG 页）从 Home→Local→漫画进入真实 Reader；X11 XTest 注入输入，`import -window` 截图，全部截图仅留 `/tmp/ux1-gui6/`（不入库）。逐图像素测量：

| 状态 | 截图 | 顶部行 | 底部进度 |
|---|---|---|---|
| 普通阅读·工具隐藏 | `shotC-hidden.png` | 仅合并工作区行（shell y=4..39，content 自 41） | rail y=888..895 恰 8px（dark surfaceContainerHighest `51,53,57`），其下 4px 为 Linux virtual frame 内边距；漫画止于 887 |
| 普通阅读·工具显示 | `shotD-tools.png` | 工作区行 y=4..39 + 阅读器工具行 y=41..94，content 自 96；共两行 | 仅一条完整进度（E1:P1+slider+章节+动作） |
| 沉浸 | `shotF2-immersive.png` | 工作区行/侧栏/标签隐藏，只剩单行阅读器工具（y=4..59） | 单条进度 |
| 章节浮层 | `shotG-chapters.png` | — | 漫画像素范围 x=411..1028 / y=60..789 与打开前完全相同 |
| Escape 第一次/第二次 | `shotH-esc1.png` / `shotI-esc2.png` | 第一次只关浮层且仍沉浸；第二次恢复工作区行（工具行仍开=两行） | — |

普通/沉浸标签保留与隐藏、重进 Reader（`shotP-reader-again.png`）已核对；无第三行独立标题栏、无 overflow。**局限**：虚拟显示无窗口管理器，合成输入下「第二标签后台休眠 / 跨重启页码恢复」GUI 未取得；该两项由真实 MainPage 控件测试 `workspace_reader_state_test`/`workspace_reader_tabs_test` 断言覆盖，未把 GUI 缺失冒称通过。

## 4. 生产改动（相对 `ecaa99f`）

本轮直接改动：

- `lib/features/reader/scaffold.dart`：`compactBody` 增加 `crossAxisAlignment: CrossAxisAlignment.stretch`（原默认 center 使阅读内容宽度塌陷为 0——真实缺陷）；使用 `ReaderBottomBar.compactHeight`。
- `lib/features/reader/progress_bar.dart`：新增 `ReaderBottomBar.compactHeight = 8.0` 并统一紧凑尺寸。
- `lib/features/reader/reader_page.dart`：移除 `fullscreen()` 中的 `kDebugMode` 提前返回（该未记录的保护使 debug 构建完全不驱动窗口生命周期，导致 8 项窗口/退出契约测试失败；恢复为 release/debug 同语义，仍保留 post-frame 延迟）。
- `lib/app_shell/workspace/desktop_workspace.dart`：`_syncChrome` 先发布路由 `readerActions`，再计算 `setWorkspaceTabs(visible: ...)`（退出沉浸时标签行恢复）。
- `lib/components/layout.dart` + `lib/features/comic_widgets/comic_tile.dart`：新增 density override（仅排序编辑器使用，钉定舒适密度）。
- `lib/features/favorites/comic_reorder_page.dart`：排序编辑器使用收藏 bookshelf 卡片 + 钉定舒适密度。
- app-shell 并行执行器修复（同批合入、已由本轮复跑验证）：`lib/components/desktop_chrome.dart`、`window_frame.dart`、`desktop_top_bar.dart`、`scroll.dart`、`lib/app_shell/workspace/workspace_tab_strip.dart`（见其交付日志 `/tmp/ux1-final-app_shell-dir.log` 与 `ux1-regress-*.log`）。

新增文件：`test/features/reader/compact_progress_layout_test.dart`。

## 5. 受保护边界

- `pubspec.lock` 未重新生成（`git diff -- pubspec.lock` 为空；全程 `--no-pub`）。
- `packages/webdav_client/` 等 vendored 逐字节未变。
- `openspec/changes/ci-quality-gate-recovery/` 的 proposal/design/specs 未改；`design-spec.md`、`openspec/specs/` 未改；仅更新 `ux1-bookshelf-workspace/tasks.md` 与本交付文件。
- 未新增 UI 文案（无需 `.tl`/translation.json 词条）。
- 未新增 skip、未删除断言、未放宽 finder；迁移项均保留原断言强度（逐项理由见 §1 表与各测试文件注释）。
- 图片截图不入库（全部在 `/tmp`）。

## 6. 最终校验（执行后粘贴）

- `fvm flutter analyze --no-pub --fatal-infos --fatal-warnings` → **No issues found!**（0，AGENTS 7.2 新基线）
- `fvm dart format --output=none --set-exit-if-changed`（全部改动的 32 个 dart 文件）→ 0 changed
- `git diff --check` → 通过
- `openspec validate --changes` → **4 passed, 0 failed**（含 `ux1-bookshelf-workspace`）
- `git diff --stat`：33 文件 +841/−187（另 2 个新文件：`compact_progress_layout_test.dart`、本交付文件），不含 `pubspec.lock`/vendored/`openspec/specs`/`design-spec.md`
- `pubspec.lock` 未变（`git diff -- pubspec.lock` 为空）；全程 `--no-pub`
- GUI 构建：`fvm flutter build linux --debug --no-pub` → `✓ Built build/linux/x64/debug/bundle/venera-pc`
- 测试计数复验：格式化后再跑 `workspace_reader_state`+`quick_settings_panel`+`reader_exit`+`compact_progress_layout` → **172/0/23**
- 环境清理：GUI 进程与 Xvfb :7 已停止；无 fixture/进程残留（`pgrep venera-pc`/`pgrep flutter_tester` 为空）

## 7. 待 architect 独立复核的点

1. 6.6「无法复现产品红灯」的结论与新增真实控件证据是否足以勾选（若要求章节维度再补测）。
2. 契约裁定 A 的实现（排序编辑器 bookshelf 卡 + 舒适密度钉定，density 保护两处 pin 迁移）是否符合 F1/5A 契约意图。
3. `fullscreen()` 移除 `kDebugMode` 提前返回：恢复 debug 下原生全屏窗口生命周期（测试契约），macOS 调试体验可能回到「切换全屏时调试连接可能断开」的旧行为；若 architect 认为需保留 macOS debug 例外，请给出平台级方案（不得再影响 Linux/CI 契约）。
4. `lib/components/scroll.dart` 的通用「被裁剪恢复偏移待内容足够后补跳」兜底（app-shell 执行器为 workspace aggregate 滚动恢复所做）；如认为应收敛到 features/search 页面内实现，可另行返工。
5. Linux 虚拟窗口 frame 的 8px resize edge 与底边 8px 精简进度线重叠约 4px：生产环境可点击区域为轨道上半部；本轮测试以 `hitTestable(at: Alignment(0,-0.5))` 记录（`workspace_reader_state` 注释）。若 owner 认为体验不足，另立 UI 修正（例如 rail 增加底部安全 inset）。
6. GUI 局限：无窗口管理器/合成输入下未取得「后台休眠/跨重启恢复」GUI，仅真实控件测试覆盖；若必须 GUI 实拍，需要可控窗口管理器或真机环境。
