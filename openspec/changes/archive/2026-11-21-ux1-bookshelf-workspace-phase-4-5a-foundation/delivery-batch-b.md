# Batch B 收藏、作者 shelf、搜索与详情层级

- 日期：2026-11-20
- 状态：首个实现切片完成，Batch B 尚未整体闭合。

## 本次实现

- 在本地收藏首屏标题下增加筛选摘要 chips：阅读状态、作者筛选、标签筛选。
- 摘要复用既有 `readFilterSelect`、`authorFilters`、`tagFilters` 与持久化；不改变卡片主体、复选框、作者 shelf 手柄、排序和拖放语义。
- 只在普通收藏浏览态显示；搜索态和多选态不插入摘要，避免打断搜索现场和选择工具栏。
- 生产详情页未改数据栈；当前 GUI 复核确认现有 hero、作者/来源、主动作、简介/信息和章节顺序可继续作为 Batch B 基线。

## 验证

- `fvm flutter analyze lib/features/favorites/local_favorites_page.dart`：通过。
- `fvm flutter test test/features/favorites/favorites_settings_persistence_test.dart test/features/favorites/author_shelf_ui_test.dart`：12/0/0，通过；持久化测试中的 FileSystemException 是测试主动注入的故障路径。
- `fvm flutter test test/app_shell/workspace_search_results_test.dart test/features/search/search_cover_ratio_and_single_drag_test.dart`：3/0/0，通过。
- `git diff --check`：通过。
- CUA 生产复核：详情页首屏真实渲染，AX 树暴露标题、作者/来源、收藏、稍后阅读、评论、分享、下载、阅读、章节及相关作品；Batch A 合并顶栏仍保持。

## 尚未完成

- 收藏/文件夹双层导航的最终收敛仍待 Batch B 后续切片。
- 作者 shelf 首屏层级和平台名称区域尚未改动。
- 搜索结果 pane 首屏摘要暂不调整；现有 pinned 搜索栏和 workspace scroll/focus 保护优先，插入额外 Sliver 摘要会破坏既有测试场景。
- 详情 hero 的尺寸/首屏关系尚未调整；现有真实详情截图作为后续差异基线。
