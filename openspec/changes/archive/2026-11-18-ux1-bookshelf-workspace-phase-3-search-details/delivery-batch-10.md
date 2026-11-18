# UX1 5.13 — 搜索画廊几何修复

HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c` / `redesign-2026`；保留此前授权脏改，仅实施5.13，未提交/归档/push。batch-9为改前阶段证据；本文件与 batch-10 清单是本增量当前交接，architect 的 review-batch-9.md 保留。

## 实际根因与单变量反馈

修复前，显式 `ComicTileDisplayMode.gallery` 确实使卡片采用 bookshelf renderer，但 `SliverGridComics` 仅在 `useFavoriteDisplaySettings` 路径提供 galleryColumns；搜索显式gallery传入 null，网格委托因此按 detailed/brief 计算列数与行高。**竖向画廊 renderer 被装入横向列表槽位**，完整封面 contain 因而留下大片水平空白。不是 dynamic_color、主题或图片未解码问题。

先列并验证三个假设：

1. renderer/网格几何入口失配：实际红灯在默认detailed偏好下搜索1/2/3列，收藏自动4/6/8列。仅使显式gallery传0（自动列数）后，单源12组均与收藏一致；聚合仍红。
2. 收藏和搜索密度分支不一致：实际标题高度/内边距已相同，改变上述单变量后 compact/comfortable 的卡片/槽位也一致，证明不需要第二套密度token或修改收藏偏好。
3. 聚合横向SimpleComicTile固定162高度另有尺寸体系：单源修复后的 `/tmp/ux1-513-single-variable.log` 明确显示聚合仍没有画廊网格；把聚合gallery接入原list分支的SliverGridComics后，12组也一致，来源分组/标题进入完整结果入口保留。

**最小生产改动仅两文件**：

- `lib/features/comic_widgets/comic_list.dart`：显式gallery传 `galleryColumns:0`，调用现有 bookshelf 自动列数、密度、文字缩放与纵向槽位规则。收藏原有displayMode和固定列数分支保持，搜索不读取/改写收藏mode或固定列数偏好。没有修改共享网格算法、token或图像fit。
- `lib/features/search/aggregated_search_page.dart`：已加载分组的gallery/list都用原生产SliverGridComics；gallery去掉横向SimpleComicTile路径，list仍用detailed。保留分组State、selections、请求归属/次数、来源标题与单源导航。没有改列表模式、作者栏、主体菜单/拖动手柄或持久化格式。

## 几何红绿与原始测量

新增 `test/features/search/search_gallery_geometry_test.dart`，用真正 SearchResultPage、AggregatedSearchPage 与 `SliverGridComics(useFavoriteDisplaySettings:true)` 比较；**内容可用宽度完全相同**，无侧栏差值或伪造槽位。覆盖600/1000/1400×100%/150%×comfortable/compact共12组。

修复前 `/tmp/ux1-513-geometry-red.log`：**0通过12失败0skip，5秒**。这是实际矩形失配，不是初始化错误；没有改坏生产或断言制造红灯。

下表为100%文字的实测值（px，圆整仅用于表格；原始未圆整JSON保留）：

|内容宽|密度|搜索列→收藏列|旧搜索卡片|修复后/收藏卡片|旧搜索封面槽位|修复后/收藏槽位|
|---|---|---|---|---|---|---|
|600|comfortable|1→4|592×144|142×264.59|576×88.8|126×209.39|
|600|compact|1→5|592×144|112×220.47|584×96.8|104×173.27|
|1000|comfortable|2→6|492×144|158.67×289.10|476×88.8|142.67×233.90|
|1000|compact|2→7|492×144|134.86×254.08|484×96.8|126.86×206.88|
|1400|comfortable|3→8|458.67×144|167×301.35|442.67×88.8|151×246.15|
|1400|compact|3→10|458.67×144|132×249.88|450.67×96.8|124×202.68|

150%文字下列数不变：旧搜索卡片仍144高，封面槽位仅43.4/51.4高；修复后同收藏卡片高各增加35px，标题区域从18.2增至54.6px。600舒适场景的标准68:100封面原只能画成约60.4px宽，槽位却576px宽，约89.5%水平空白；修复后126px宽纵向槽位消除此错误。

行列步长、卡片/封面槽位/title rect、标题高度、内边距、外边距都记录在 `batch-10-geometry.json`：12条原红测量+12条单源绿测量+12条聚合绿测量。行列间距由实际stride减card extent得8px，外侧4px；内部padding舒适8px/紧凑4px，封面到标题4px。保留未圆整测量，比较容差仅 `1e-6px`；中途7项 `1e-14px` 浮点减法差异单列，不冒称产品缺陷。

最终 `/tmp/ux1-513-geometry-final.log`：**14通过0失败0skip，5秒**（12组几何+1像素+原5.12真实模式/磁盘现场）。

像素证据不是仅断言fit：实际解码68×100纵向与160×60宽幅图片，原图左/右/上/下边分别为红/绿/蓝/黄；对真实SearchResultPage的RenderRepaintBoundary完整渲染帧逐像素采样，四条原始色边均可见。日志含解码尺寸、实际槽位与绘制矩形。纵向图槽位142.67×233.90，绘制142.67×209.80；宽幅图同槽位绘制142.67×53.50，上下letterbox是保留完整宽封面所需，未当作故障。无裁切、缩字或隐藏异常。

## 现场与保护

`search_display_mode_test.dart` 保留全部5.12偏好隔离、真实菜单/checkbox、同State/controller/120px/selection/keyword/options/sourceKey与真实磁盘List重载断言。仅将旧SimpleComicTile实现断言迁移为实际gallery网格；分组变长后用真实指针滚动到第二来源再验证其原请求断言，没有删弱来源/次数或选择保护。

受影响回归 `/tmp/ux1-513-protection.log`：**128通过0失败0skip，41秒**，包括以上14项（重叠不相加）、MainPage/WindowFrame真实同tab/420px/焦点/两卡/请求/返回，聚合现场和磁盘恢复、F2预览/键盘/checkbox/单卡多选drag/Escape、B4/right click/主体、F8来源记忆、收藏显示/列数、F10/F11作者手柄/排序/折叠。

准确命令（仓库根目录，日志重定向路径见上）：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_gallery_geometry_test.dart --reporter expanded

env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_gallery_geometry_test.dart test/features/search/search_display_mode_test.dart --reporter expanded

env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_gallery_geometry_test.dart test/features/search/search_display_mode_test.dart test/app_shell/workspace_search_results_test.dart test/app_shell/workspace_aggregate_state_test.dart test/features/search/result_preview_test.dart test/features/search/card_body_preference_test.dart test/features/search/search_target_memory_test.dart test/features/search/search_cover_ratio_and_single_drag_test.dart test/features/favorites/favorites_single_drag_test.dart test/features/favorites/favorites_display_test.dart test/features/favorites/favorite_hit_target_test.dart test/app_shell/workspace_preview_test.dart test/app_shell/workspace_author_handle_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/sidebar_sections_test.dart --reporter expanded
```

## 收尾

- analyze：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 fvm flutter analyze --no-pub`，`/tmp/ux1-513-analyze.log` **raw/unique50/50=38tool+12其他**，对 batch-9 具体50集合 added=[]removed=[]；完整比较与current_log见 `batch-10-analyze-comparison.json`。
- 2生产/2测试 SHA 当前冻结见 `batch-10-production.sha256`、`batch-10-tests.sha256`。这些文件包含既有未提交改动，不把所有HEAD diff归因本批。
- 固定保护范围 AGENTS/ROADMAP/proposal/design-spec/正式spec/pubspec.yaml/lock/main/runner 对HEAD零diff；活动design/browse delta已有architect本轮澄清，executor未编辑，SHA单列 `batch-10-architect-contracts.sha256`，不冒称它们对HEAD零diff。
- diffcheck/OpenSpec已通过。正常main Linux构建成功：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter build linux --no-pub`，日志 `/tmp/ux1-513-main-build.log`，产物 `build/linux/x64/release/bundle/venera-next`。
- GUI无新安全输入路径，本轮无fixture/窗口/截图，不使用旧:1。像素证据来自测试实际渲染帧，不冒称owner桌面GUI；5.5仍未勾。无新用户文案、main/runner未改、无需fixture清理。

等待architect独立复核，不提交。
