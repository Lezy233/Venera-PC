# UX1 5.8 delivery

基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`，分支 `redesign-2026`。本批未提交、未归档、未 push；5.5 GUI 仍未勾，6.x/7.x 未启动。5.8 复用了本工作区已有的 5.7 单卡拖动修复，未新增生产源码差异；新增真实收藏生产控件回归。

## 红灯与根因

真实 `SliverGridComics` 收藏网格以两张不同 sourceKey 的漫画、实际卡片坐标拖至生产 `WorkspaceTabStrip`。回放旧行为时，`ComicTile` 仅在 `selected == true` 时给 `ComicSelectionDrag` routes，未选择单卡没有拖动源，标签栏后台路由数为 0；日志 `/tmp/ux1-5x-58-red.log`，失败断言为期望恰好一个后台路由、实际 0。

根因排序核对：

1. `author_shelf.dart` 的 `enableSelectionDrag=false` 是有意的作者栏排序边界，不是主收藏网格根因。
2. `DesktopWorkspace` 在生产路径提供 `WorkspaceNavigationScope`；主收藏和网络收藏都经 `SliverGridComics → ComicTile`。
3. `WorkspaceTabStrip` 已有真实 `DragTarget<WorkspaceComicDrag>`，不是缺失注册。
4. 作者栏主体仍由 `_ShelfDrag` 长按排序控制；独立选择手柄保留选集拖出。没有改动该竞争关系。

## 绿灯与保护

```text
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 \
  LD_LIBRARY_PATH=$PWD/build/linux/x64/debug/bundle/lib \
  fvm flutter test --no-pub test/features/favorites/favorites_single_drag_test.dart --reporter expanded
```

`favorites_single_drag_test.dart`：1 通过、0 失败、0 skip。测试命中生产 `SliverGridComics`/`ComicTile`/`WorkspaceTabStrip`，拖动未选择的 `favorite-1`，断言恰好一次 comic route、`id=favorite-1`、`sourceKey=network-a`、`title`/`cover`，选择仍为 false，且无初始化异常。该共用路径同时覆盖本地收藏主网格与网络收藏卡片身份。

受影响保护合跑 `/tmp/ux1-5x-58-protection.log`：33 通过、0 失败、0 skip，包含 5.7 单卡、workspace 后台请求、作者栏长按排序与独立手柄/F10/F11 UI。与旧集合不相加。

作者栏单张主体拖动明确不作为标签拖出入口：其主体长按只用于同作者排序，`enableSelectionDrag=false`；选集拖出通过独立手柄，既有作者栏测试保留并在保护合跑中通过。没有删除或弱化作者排序、复选框、菜单或多选语义。

当前 Wayland/X11 环境仍不能提供 owner 桌面的安全键鼠 GUI；未使用旧 `:1` fixture 冒称 GUI。5.5 继续未勾。

## 交付清单

新增测试：`test/features/favorites/favorites_single_drag_test.dart`，SHA 见 `batch-6-tests.sha256`。本批无新增生产源码，5.7 修复文件 SHA 仍见 `batch-5-production.sha256`。`fvm flutter analyze --no-pub` raw/unique `50/50`，具体集合比较 `/tmp/ux1-5x-58-analyze-comparison.json` 为 `added=[]`、`removed=[]`；正常 bundle 构建成功，日志 `/tmp/ux1-5x-58-main-build.log`。`git diff --check`、OpenSpec validate 待本批收口执行；未改 protected 文件、pubspec 或 lock。
