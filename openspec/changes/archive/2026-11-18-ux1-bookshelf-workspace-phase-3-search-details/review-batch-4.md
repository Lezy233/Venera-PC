# UX1 5.x 独立复核（进行中）

architect，2026-11-18；基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`。本阶段未提交、未归档、未 push；5.5 尚未完成，不能视为 5.x 或 UX1 验收通过。

## 已完成范围

- 5.1：SearchResultPage 单源 ComicList 显式使用 `ComicTileDisplayMode.gallery`；聚合结果保留既有 SimpleComicTile 封面路径。executor 真实相关回归 `/tmp/ux1-5x-search-existing.log` 11通过/0失败/0skip。
- 5.2：按 architect 裁定增加 `DiscoveryPreferences.comicDetailMode`，默认 information、reading 可选；复用 Explore 现有设置入口和可靠偏好保存；ComicPage reading 默认收起“作品详情与来源”，information 直接展示。executor 详情/主体回归 `/tmp/ux1-5x-detail-green.log` 10通过/0失败/0skip；现有 ComicDetails 测试未逐字段覆盖 D7 全部展开内容，局限保留。
- 5.3/5.4：现有 Preference/WorkspaceStore 持久化、工作区设置、搜索过滤、真实 loading/error/empty/retry 路径 `/tmp/ux1-5x-234-regression.log` 25通过/0失败/0skip。受控保存失败是既有故障注入，最终断言通过。

## 独立复核

architect 独立执行 `fvm flutter test --no-pub test/features/comic_details/comic_details_page_test.dart test/features/search/card_body_preference_test.dart test/app_shell/workspace_settings_test.dart test/app_shell/workspace_search_results_test.dart test/features/search/result_preview_test.dart --reporter expanded`：`/tmp/ux1-5x-architect-independent.log` **14通过/0失败/0skip**。重叠集合不相加。

architect 独立 `fvm flutter analyze --no-pub`：`/tmp/ux1-5x-architect-independent-analyze.log` raw/unique **50/50=38 tool＋12既有**，added/removed 均空；`git diff --check` 和 `openspec validate --changes ux1-bookshelf-workspace` 通过。生产清单6项全部 MATCH；测试清单为空，表示本阶段没有新增/修改测试文件，不包含伪路径 `-`。

## 未完成与真实阻断

5.5 保持未勾选。自动化搜索身份/方案/过滤/焦点/状态回归 `/tmp/ux1-5x-55-regression.log` 50通过/0失败/0skip，不能替代真实 GUI。重启后 executor 当前环境为 `DISPLAY=:2`、`GDK_BACKEND=wayland,x11`、`WAYLAND_DISPLAY=wayland-1`、`XDG_SESSION_TYPE=wayland`；Wayland socket 可读，系统有 `grim`/`wl-copy`/`wayland-info`，但没有 `wtype`/`ydotool`/`swaymsg`，X11 helper 无法打开 `:2`。未回退旧 `:1` fixture，未操作 owner 窗口或数据，也未伪造搜索/详情/设置 GUI 证据。`batch-4-gui.md` 记录该局限。

因此当前可交付状态是 5.1–5.4 通过独立自动化复核，5.5 等真实显示会话键鼠能力恢复后补证；不提交、归档或 push，不启动 6.x/7.x。
