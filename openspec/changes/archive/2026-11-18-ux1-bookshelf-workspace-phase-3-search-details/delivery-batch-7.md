# UX1 5.9/5.10 delivery

基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`，分支 `redesign-2026`。本批未提交、未归档、未 push；5.5 GUI 仍未勾，6.x/7.x 未启动。既有 5.6–5.8 改动保留。

## 5.9 长按选择移除

根因是收藏页把 `ComicList`/`SliverGridComics` 的 `onLongPressed` 绑定到进入多选和范围选择。已移除：

- `lib/features/favorites/local_favorites_page.dart`
- `lib/features/local_comics/local_comics_page.dart`

普通 `ComicTile` 长按恢复默认上下文菜单；4.3 checkbox、菜单、键盘选择、多选拖放和 Escape 不变。`author_shelf.dart` 的主体长按仍是 `_ShelfDrag` 作者内排序，独立作者手柄仍负责选集拖出；没有改 quickFavorite。

真实生产网格测试 `favorites_long_press_selection_test.dart`：1/0/0，长按未选卡片后所有 `ComicTile.selected` 仍为 false。B4 hit-target 迁移到 checkbox-only 语义：4/0/0，见 `/tmp/ux1-5x-59-hit-target.log`。旧 ownership fixtures 的直接长按选择调用迁移到选择回调，以保留其业务事务断言：transfer 34/34，confirmation 目标用例 1/1。

## 5.10 首页自动保存反馈

`SettingsSaveState.withSettingsSaveFeedback` 同时渲染 pending spinner、失败 Retry 和成功 Saved。首页自动快照保存不应显示前两者之外的成功/进行中浮层，因此新增 `withSettingsSaveFailureFeedback`，只在失败时保留现有 `settingsSaveStatus`/Retry。

以下首页壳层改用失败专用包装：

- `lib/app_shell/bookshelf_workspace.dart`
- `lib/app_shell/workspace/desktop_workspace.dart`
- `lib/components/settings_save_state.dart` 新增包装方法

真实 `BookshelfWorkspace` toggle + AppDataOperations 阻塞/释放回归：1/0/0，`/tmp/ux1-5x-510-green.log`；旧包装回放红灯 `/tmp/ux1-5x-510-red.log` 明确出现 `CircularProgressIndicator`。自动保存逻辑、磁盘写入、失败提示与 Retry 未吞掉；设置页仍使用完整保存反馈。

## 保护与局限

本批相关测试：

- 有界合跑（上述 6 个文件）：129/0/0，`/tmp/ux1-5x-59-510-combined-final.log`
- `favorites_long_press_selection_test.dart`：1/0/0
- `bookshelf_save_feedback_test.dart`：1/0/0
- `settings_save_feedback_test.dart`：既有保存失败/Retry保护保留
- `favorite_hit_target_test.dart`：4/0/0
- `favorite_transfer_ownership_test.dart`：34/0/0
- confirmation 目标用例：1/0/0

GUI 当前仍受 Wayland/X11 输入访问限制，未启动旧 `:1` fixture，未冒称 owner 桌面 GUI 证据。自动化未替代 5.5 GUI 验收。

本批未改 proposal/design/spec/design-spec、正式 specs、pubspec 或 lock。最终长按 fixture 不再注入 `onLongPressed` 选择回调，只挂载真实生产网格并执行真实长按。`fvm flutter analyze --no-pub` raw/unique 50/50，逐条比较 `/tmp/ux1-5x-59-510-analyze-comparison.json` 为 `added=[]`、`removed=[]`；正常 Linux bundle 构建成功，日志 `/tmp/ux1-5x-59-510-main-build.log`。生产/测试 SHA 见 `batch-7-production.sha256` 与 `batch-7-tests.sha256`；`git diff --check` 与 OpenSpec validate 已通过。
