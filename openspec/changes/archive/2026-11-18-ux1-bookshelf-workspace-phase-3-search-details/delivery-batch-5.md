# UX1 5.6/5.7 delivery

基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`，分支 `redesign-2026`。本批未提交、未归档、未 push；5.5 GUI 仍未勾，6.x/7.x 未启动。既有工作区脏改和 architect 授权的契约文件变更均保留。

## 5.6 cover ratio

红灯来自真实 `ComicTile` 生产控件，使用两个受控 `MemoryImage`（2×1 与 1×2）并在 gallery tile 中读取实际 `AnimatedImage` 配置。旧行为中 `ComicTile` 平铺传 `BoxFit.cover`，且 `AnimatedImage` 的 `RawImage` 固定 `BoxFit.cover`，导致显式完整比例意图被覆盖；红灯命令见 `/tmp/ux1-5x-567-red-final.log`，比例断言失败。

最小修复：`AnimatedImage` 的 `RawImage` 使用 `widget.fit ?? BoxFit.cover`；`ComicTile` gallery/brief 封面改为 `BoxFit.contain`。未改变列数、网格密度、标题、Hero、主体点击或复选框/菜单命中区。

## 5.7 single-card drag

红灯来自真实 `ComicTile` 到 `WorkspaceTabStrip` 的指针拖动坐标。无选择时旧 `ComicSelectionDrag` routes 为空，拖动未产生后台标签；日志 `/tmp/ux1-5x-567-red.log` 保留该失败。

最小修复：只要存在 workspace 且未禁用选择拖动，单卡主体也建立一个 `WorkspaceComicDrag`；有选择时继续使用 `selectedGroup`。标签栏真实接收后只新增一个 comic route，并保留 `id`、`sourceKey`，未冒泡主体点击。Escape、菜单、Ctrl/Meta+Enter、checkbox 和作者手柄语义未改。

## Red/green evidence

```text
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 \
  LD_LIBRARY_PATH=$PWD/build/linux/x64/debug/bundle/lib \
  fvm flutter test --no-pub test/features/search/search_cover_ratio_and_single_drag_test.dart --reporter expanded
```

- Red replay: 5.6 比例断言失败、5.7 单卡拖动无标签，初始化无异常产品红灯。
- Green: `search_cover_ratio_and_single_drag_test.dart` 2 通过、0 失败、0 skip，日志 `/tmp/ux1-5x-567-green-final.log`。
- 相关保护合跑 `workspace_background_test.dart`、新测试、`card_body_preference_test.dart`、`favorite_hit_target_test.dart`：16 通过、0 失败、0 skip，日志 `/tmp/ux1-5x-567-protection.log`。与历史集合不相加。

测试覆盖两个受控纵横比和真实指针拖放坐标；本批未取得 owner 桌面 GUI，因此没有把旧 `:1` fixture 或自动化测试冒称 GUI。expanded/medium/compact、150% 和主题完整截图仍受 5.5 GUI 阻塞限制。

## Files and validation

生产改动：`lib/components/image.dart`、`lib/features/comic_widgets/comic_tile.dart`。新增测试：`test/features/search/search_cover_ratio_and_single_drag_test.dart`。生产/测试 SHA 分别见 `batch-5-production.sha256`、`batch-5-tests.sha256`。

当前源码 `fvm flutter analyze --no-pub`：`/tmp/ux1-5x-567-analyze.log`，raw/unique 50/50；与前阶段 50 项基线逐条比较见 `/tmp/ux1-5x-567-analyze-comparison.json`，`added=[]`、`removed=[]`。正常生产 bundle 以 `fvm flutter build linux --debug --no-pub` 构建成功，日志 `/tmp/ux1-5x-567-main-build.log`。本批未改 pubspec、lock、正式 spec 或设计契约。GUI 仍是未完成项；精确 fixture 清理按 architect 独立复核路径处理。
