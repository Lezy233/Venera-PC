# UX1 5.12 搜索画廊/列表

本批基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`，分支 `redesign-2026`，保留此前 5.x 授权脏改；没有提交、归档或 push。仅实施 5.12，5.5 仍未勾，6.x/7.x 未启动。本文件为本批权威交接，不替换 batch-4–8 历史。

## 根因、范围与实现

单源 `SearchResultPage` 原先把 `ComicList.displayMode` 固定为 gallery，无可见切换入口；聚合来源分组只有横向 SimpleComicTile 画廊，无列表模式。

- 新增 `DiscoveryPreferences.searchDisplayMode`，默认 gallery、支持 list/gallery、坏值按既有 ChoicePreference 回默认。单源和聚合共用这一独立搜索偏好；**不共享或改写 FavoritePreferences.displayMode / galleryColumns**。
- 参数化既有 `FavoriteDisplayButton` 的偏好、tooltip 与是否显示列数菜单。所有收藏调用者仍使用原默认参数，收藏列数/保存/Retry/菜单归属语义不变；搜索不增加收藏列数设置。搜索沿用普通 ComicList 列数与 detailed/gallery renderer。
- 单源保留原 ComicList key、控制器和 State，只更新 displayMode；不重发搜索或重置选择。按钮和过滤设置各有独立 tooltip。
- 聚合也提供同一模式菜单：gallery 保留横向 SimpleComicTile，list 在原来源分组内复用生产 SliverGridComics/detailed 卡片；原来源标题进入完整结果页的入口保留。分组 State 与 selections 保持，不改变来源方案、关键词、筛选或请求身份。列表使用随外层页面滚动的 shrinkWrap 网格，无嵌套滚动拦截。
- 新文案 `Search display mode`.tl，zh_CN/zh_TW 均已补入。未重做卡片视觉、密度或作者栏手势。

修改生产文件：`lib/foundation/application_preferences.dart`、`lib/features/favorites/favorites_display.dart`、`lib/features/search/search_result_page.dart`、`lib/features/search/aggregated_search_page.dart`、`assets/translation.json`。测试：新增 `test/features/search/search_display_mode_test.dart`；扩充 `test/app_shell/workspace_search_results_test.dart` 的真实 MainPage 模式切换断言，原业务断言保留。

## 可证伪循环与证据

恢复后重新取得证据，不引用已丢失的旧 /tmp 日志。早期测试编译缺导入/未实现字段与 fake-async 等待异常不是产品红灯。

1. 单源入口缺失红灯 `/tmp/ux1-512-entry-red.log`：**0通过1失败0skip**，已加载真实结果文字，再断言 FavoriteDisplayButton 实际为0；回放差异仅移除 SearchResultPage 中新增按钮，不改测试断言。随后恢复该按钮。
2. 聚合缺入口红灯 `/tmp/ux1-512-aggregate-red.log`：**0/1/0**，同一测试单源切换/磁盘部分已通过，聚合实际 tooltip 为0，随后接入聚合模式。
3. 早期等待假设：①fake-async 不放行 IO；②菜单重建重复保存；③切换重建结果 State。仅修测试等待：独立临时目录、AppDataOperations 有界排空、真实 IO 与 pump 交替；无生产等待/吞异常。最终一次请求与同 State 断言排除②③，磁盘保存及重载实际成立。
4. `/tmp/ux1-512-state-green.log`：**2/0/0，19秒**。真实菜单选择 List/Gallery、checkbox 选择、鼠标120px滚动、原页面/网格 State/控制器/实体和查询/options 保留；真实 appdata.json 写入和磁盘重载后 List 重进，收藏隔离断言使用实际 `FavoritePreferences.displayMode.key`。聚合两来源与单源共享偏好，切换不重发原来源请求且选集保持，来源标题仍打开正确完整结果。MainPage/WindowFrame/Workspace 真实标签切换保留同 tab 对象、420px、页码/筛选/详情返回；原全部实体/请求/两卡/焦点断言保留。
5. `/tmp/ux1-512-protection.log`：**111通过0失败0skip，33秒**。覆盖本项、F2预览/checkbox/主体、F8来源记忆、搜索方案/单源请求、B4、收藏模式、作者手柄/排序及 F11；与上述2项重叠，**不累加**。

真实控件测试/回归命令（均在仓库根目录）：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_display_mode_test.dart --reporter expanded

env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_display_mode_test.dart test/app_shell/workspace_search_results_test.dart --reporter expanded

env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/search/search_display_mode_test.dart test/app_shell/workspace_search_results_test.dart test/features/search/result_preview_test.dart test/features/search/card_body_preference_test.dart test/features/search/search_target_memory_test.dart test/features/search/search_profile_flow_test.dart test/features/search/search_cover_ratio_and_single_drag_test.dart test/features/favorites/favorites_display_test.dart test/features/favorites/favorite_hit_target_test.dart test/app_shell/workspace_author_handle_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/sidebar_sections_test.dart --reporter expanded
```

## 分析、保护、构建和局限

- `env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 fvm flutter analyze --no-pub` → `/tmp/ux1-512-analyze.log`，raw/unique **50/50=38tool+12其他**。仓库 `batch-3-progress-analyze-comparison.json:baseline` 的50条逐条比较：added=[]、removed=[]；完整具体集合与 current_log 已写 `batch-9-analyze-comparison.json`。
- 5生产/2测试 SHA 见 `batch-9-production.sha256`、`batch-9-tests.sha256`；其中包含本批以前尚未提交的既有改动，清单为当前文件冻结，不冒称所有 diff 均属5.12。
- 固定保护范围（AGENTS/ROADMAP/proposal/design-spec/正式spec/pubspec.yaml/lock/main/runner）对 HEAD 零 diff。活动 design 和 browse delta 已有 architect 的5.6–5.12契约改动，本 executor 未编辑；当前只读 SHA 单列 `batch-9-architect-contracts.sha256`，不宣称它们相对 HEAD 零 diff。
- `git diff --check` 与 `openspec validate --changes ux1-bookshelf-workspace` 通过。
- 正常 main Linux `env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter build linux --no-pub` 已成功，日志 `/tmp/ux1-512-main-build.log`，产物 `build/linux/x64/release/bundle/venera-next`；不改 main/runner，不启动 fixture。
- GUI 本轮无新截图/进程。此前真实显示会话输入访问阻塞未获新的安全输入路径，未回退旧 :1。控件测试与磁盘重载不冒称真实 GUI/新PID验收；5.5保持未勾。本项聚合两来源、默认/双向切换与实际控件证据见测试，未声称本轮完整宽度/主题/150%GUI矩阵。

等待 architect 独立复核，不提交。
