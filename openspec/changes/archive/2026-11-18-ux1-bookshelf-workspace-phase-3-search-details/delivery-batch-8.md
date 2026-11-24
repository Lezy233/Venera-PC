# UX1 5.11 delivery

基准工作区仍为 `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c` / `redesign-2026`，本批未提交、未归档、未 push；保留此前 5.x 脏改。5.5 GUI 仍因当前 Wayland/X11 输入访问阻塞，未冒称 GUI 通过。

## 根因与修复

真实 `ComicTile` 生产网格长按红灯：Linux 桌面主体长按触发旧默认 `Details` ContextMenu；同卡 secondary mouse 仍能触发该菜单。排序假设核对结果：

1. `ComicTile._onLongPressed` 在无自定义回调时直接调用默认 `showMenu`，确认是主因。
2. `onSecondaryTapDown` 已单独调用相同 `showMenu`，确认可保留右键菜单。
3. 收藏、网络/本地漫画、搜索、历史的主体均复用 `ComicTile` 默认路径；作者 shelf 显式关闭主体长按，使用独立作者手柄和栏内排序；ComicPage 的 `quickFavorite` 是自定义长按回调。
4. 未发现需要删除菜单或改动作者排序/手柄的其他路径。

最小修复仅改 `lib/features/comic_widgets/comic_tile.dart`：无自定义 `onLongPressed` 时，桌面平台主体长按直接返回；移动端仍显示原菜单，secondary pointer/button 仍调用同一 `showMenu`，自定义 `ComicPage.quickFavorite` 不受影响。

## 红绿与保护

- 红灯：`/tmp/ux1-5x-511-red.log`，修复前真实主体长按可见 `Details`，secondary 同菜单。
- 绿灯：`/tmp/ux1-5x-511-green.log`，1/0/0；主体长按无菜单，secondary 仍可见 `Details`。
- 有界 F2/F5/F8/F10/F11/B4/5.10 保护：`/tmp/ux1-5x-511-protection.log`，91/0/0。
- 测试使用真实 `ComicTile`/`SliverGridComics`、真实长按和 secondary mouse pointer；未调用回调替代输入。作者栏排序/独立手柄、ComicPage quickFavorite、checkbox/menu/拖放/Escape/保存失败 Retry 保护均保留。

## 校验

- analyze：`/tmp/ux1-5x-511-analyze.log`，raw/unique `50/50`；与 `/tmp/ux1-5x-59-510-analyze-final.log` 逐条比较，`/tmp/ux1-5x-511-analyze-comparison.json` 为 `added=[]`、`removed=[]`。
- 生产 SHA：`batch-8-production.sha256`；测试 SHA：`batch-8-tests.sha256`。
- `git diff --check` 与 `openspec validate --changes ux1-bookshelf-workspace` 已通过。
- 正常 Linux main 构建已通过，日志 `/tmp/ux1-5x-511-main-build.log`；无本轮 GUI 截图，当前 Wayland/X11 环境局限已记录。
