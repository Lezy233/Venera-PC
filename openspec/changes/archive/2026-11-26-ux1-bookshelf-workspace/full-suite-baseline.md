# UX1 全量测试基线（64 项 CI 必挂失败）

- 来源：`ci-quality-gate-recovery` 4.4（2026-11-25）；原始逐条证据在本地 `tmp/ciqg/4.4-bisect.md`（`tmp/` 被 .gitignore 忽略，不入库），本文件为 architect 转录的入库摘要。
- 基线：CI 等价并发 `flutter test --coverage --concurrency=4` → **5719 通过 / 64 失败 / 150 skip**；64 项与 HEAD worktree（`cec0762`）逐条一致，`ci-quality-gate-recovery` 零新增。150 skip 为既有平台条件跳过，不是本表新增。
- 分组：reader-shell 6.x **28**（`reader_exit_integration` 15、`information_overlay` 6、`shell_presentation` 3、`auto_reading_viewport` 2、`gallery_viewport_rendering` 2）；workspace/bookshelf **24**；favorites/search/settings **12**。
- 归属：全部属于本 change 未完成范围（6.x 阅读器、5A 纠偏、5.x 收尾），由 `tasks.md` 7.6 承接。
- 规则：修到 0；禁止 skip、删除断言、放宽 finder 或与契约不符的产品改动掩盖；完成后复跑全量并保留 HEAD 对照与覆盖率报告。
- 前置关系：本基线清零前，`ci-quality-gate-recovery` 4.5、`desktop-only-ci-cd` 4.3、`venera-pc-rebrand` 7.3 均不得勾选。

## 分组与清单

- 修复前失败集合：67 项；HEAD worktree 对照集合：67 项；两者逐条一致：True
- 分类：3 项仓库缺陷（已修） + 64 项 HEAD 既有 UX1/reader-shell 缺陷（CI 必挂，非本 change 引入，超出本 change 范围）

## A. 已修仓库缺陷（3）

| 测试 | 根因 | 修复 |
|---|---|---|
| `foundation/translations_test.dart` :: all literal translation keys used by Dart code are defined | 缺 'Dismiss'/'Previous' 的 zh_CN/zh_TW 词条 | 见下 |
| `foundation/favorite_preferences_test.dart` :: favorite defaults keep legacy keys and JSON value types | 默认键集合缺 favoritesDensity、displayMode 默认仍写 list（实际已发版 gallery） | 见下 |
| `features/sync/data_sync_operation_test.dart` :: configuration rollback snapshots detach nested raw values and retain operation ownership | fixture settings 未含始终存在的 webdav.connection 键，回滚后多出 null 键 | 见下 |

## B. HEAD 既有缺陷（64，CI 必挂，逐文件）

| 文件 | 失败数 | 首个失败签名 |
|---|---|---|
| `app_shell/bookshelf_favorites_continuity_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: exactly one matching candidate Actual: _DescendantWidgetFinder:<Found 0 widgets with widget matching predicate descending from widgets with type "BookshelfWo |
| `app_shell/bookshelf_workspace_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: exactly one matching candidate Actual: _DescendantWidgetFinder:<Found 0 widgets with widget matching predicate descending from widgets with type "BookshelfWo |
| `app_shell/workspace_aggregate_state_test.dart` | 1 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.first (dart:core/iterable.dart:663:7) #1      _FirstFinderMixin.filter (packag |
| `app_shell/workspace_author_handle_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: null Actual: FlutterError:<A RenderFlex overflowed by 39 pixels on the right.> When the exception was thrown, this was the stack: #4      main.<anonymous clo |
| `app_shell/workspace_auxiliary_route_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (12) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown, |
| `app_shell/workspace_background_test.dart` | 1 | The following assertion was thrown while handling a gesture: Navigator operation requested with a context that does not include a Navigator. The context used to push or pop routes from the Navigator must be that of a wid |
| `app_shell/workspace_details_state_test.dart` | 2 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (18) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown, |
| `app_shell/workspace_focus_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: true Actual: <false> content traversal cycled before reaching workspace controls: FocusNode#fc65d([PRIMARY FOCUS])(context: Focus, PRIMARY FOCUS) When the ex |
| `app_shell/workspace_history_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (4) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown,  |
| `app_shell/workspace_keyboard_test.dart` | 1 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.first (dart:core/iterable.dart:663:7) #1      _FirstFinderMixin.filter (packag |
| `app_shell/workspace_local_reader_route_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (6) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown,  |
| `app_shell/workspace_preview_test.dart` | 3 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (10) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown, |
| `app_shell/workspace_reader_state_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: no matching candidates Actual: _HitTestableWidgetFinder:<Found 1 widget with type "WorkspaceTabStrip" (considering only hit-testable widgets with a RenderBox |
| `app_shell/workspace_reader_tabs_test.dart` | 1 | The following TestFailure was thrown running a test: Expected: true Actual: <false> reader Tab cycled before reaching the outer workspace: FocusNode#8fea1([PRIMARY FOCUS])(context: Focus, PRIMARY FOCUS) When the exceptio |
| `app_shell/workspace_route_lifecycle_test.dart` | 3 | The following TestFailure was thrown running a test: Expected: null Actual: 'Multiple exceptions (4) were detected during the running of the current test, and at least one was unexpected.' When the exception was thrown,  |
| `app_shell/workspace_search_results_test.dart` | 1 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.first (dart:core/iterable.dart:663:7) #1      _FirstFinderMixin.filter (packag |
| `app_shell/workspace_search_state_test.dart` | 1 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.first (dart:core/iterable.dart:663:7) #1      _FirstFinderMixin.filter (packag |
| `app_shell/workspace_tab_input_test.dart` | 2 | The following TestFailure was thrown running a test: Expected: exactly 5 matching candidates Actual: _TypeWidgetFinder:<Found 0 widgets with type "PopupMenuItem<String>": []> Which: means none were found but some were ex |
| `features/favorites/bookshelf_hit_target_test.dart` | 4 | The following TestFailure was thrown running a test: Expected: ['book-1'] Actual: EfficientLengthMappedIterable<Comic, String>:[] Which: at location [0] is EfficientLengthMappedIterable<Comic, String>:[] which shorter th |
| `features/favorites/favorites_reorder_test.dart` | 4 | The following TestFailure was thrown running a test: Expected: _DebugSize:<Size(85.8, 181.9)> Actual: _DebugSize:<Size(85.8, 138.5)> When the exception was thrown, this was the stack: #4      main.<anonymous closure> (fi |
| `features/favorites/folder_creation_presentation_test.dart` | 2 | The following StateError was thrown running a test: Bad state: Too many elements When the exception was thrown, this was the stack: #0      Iterable.single (dart:core/iterable.dart:696:24) #1      WidgetController.widget |
| `features/reader/auto_reading_viewport_test.dart` | 2 | The following TestFailure was thrown running a test: Expected: a numeric value within <0.01> of <168.0> Actual: <165.76> Which:  differs by <2.240000000000009> When the exception was thrown, this was the stack: #4      m |
| `features/reader/gallery_viewport_rendering_test.dart` | 2 | The following TestFailure was thrown running a test: Expected: Size:<Size(1280.0, 700.0)> Actual: _DebugSize:<Size(1280.0, 692.0)> When the exception was thrown, this was the stack: #4      main.<anonymous closure> (file |
| `features/reader/information_overlay_test.dart` | 6 | The following TestFailure was thrown running a test: Expected: <2> Actual: <0> Information must not intercept reading taps. When the exception was thrown, this was the stack: #4      main.<anonymous closure> (file:///tmp |
| `features/reader/reader_exit_integration_test.dart` | 15 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.single (dart:core/iterable.dart:694:25) #1      WidgetController.element (pack |
| `features/reader/shell_presentation_test.dart` | 3 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.single (dart:core/iterable.dart:694:25) #1      WidgetController.element (pack |
| `features/search/search_profile_flow_test.dart` | 1 | The following assertion was thrown running a test: The finder "Found 0 widgets with type "SimpleComicTile" that are ancestors of widgets with text "Controlled result 1 · Platform A": []" (used in a call to "getTopLeft()" |
| `features/settings/settings_inplace_editing_test.dart` | 1 | The following StateError was thrown running a test: Bad state: No element When the exception was thrown, this was the stack: #0      Iterable.single (dart:core/iterable.dart:694:25) #1      WidgetController.element (pack |

## C. 逐条测试清单（64）

### app_shell/bookshelf_favorites_continuity_test.dart (1)
- real favorite selection scroll instance and focus survive bookshelf transitions

### app_shell/bookshelf_workspace_test.dart (1)
- desktop bookshelf collapses and compact overlay preserves content

### app_shell/workspace_aggregate_state_test.dart (1)
- real aggregate profile retains applied source identities options keyword and nonzero scroll per tab

### app_shell/workspace_author_handle_test.dart (1)
- production author handle collapsed drops distinct sources once without reordering

### app_shell/workspace_auxiliary_route_test.dart (1)
- real cover auxiliary route retains runtime history and restores its parent once with feedback from disk

### app_shell/workspace_background_test.dart (1)
- real background menu defers three detail requests until activation and retains each page

### app_shell/workspace_details_state_test.dart (2)
- real details expansion and scroll survive tabs and disk while Alt Left preserves the favorite scene; grouped=false
- real details expansion and scroll survive tabs and disk while Alt Left preserves the favorite scene; grouped=true

### app_shell/workspace_focus_test.dart (1)
- Tab escapes the active content Navigator to the real workspace tab strip without cycling

### app_shell/workspace_history_test.dart (1)
- Alt Left returns to the real selected scrolled favorite stack without closing its tab

### app_shell/workspace_keyboard_test.dart (1)
- real workspace keyboard commands retain current stack and ignore editable input

### app_shell/workspace_local_reader_route_test.dart (1)
- real local favorite details redirects into its own reader stack and Alt Left retains the original scene

### app_shell/workspace_preview_test.dart (3)
- production workspace preview preserves two selections 420px instance focus and promotes only once
- production workspace real selection preview-read and Escape
- production workspace real selection drag-compact and Escape

### app_shell/workspace_reader_state_test.dart (1)
- real reader stays inside its tab and pauses background work while retaining its exact page

### app_shell/workspace_reader_tabs_test.dart (1)
- two real readers retain separate pages and background/current tab close releases only their own resources

### app_shell/workspace_route_lifecycle_test.dart (3)
- real details builder once and retained history; replacement=none
- real details builder once and retained history; replacement=current
- real details builder once and retained history; replacement=covered

### app_shell/workspace_search_results_test.dart (1)
- real single source results retain paging scroll identity and history through workspace and details

### app_shell/workspace_search_state_test.dart (1)
- two real search entries retain independent source options query focus and original favorites beneath each stack

### app_shell/workspace_tab_input_test.dart (2)
- real workspace overflow and full-title keyboard menu; dark150=false
- real workspace overflow and full-title keyboard menu; dark150=true

### features/favorites/bookshelf_hit_target_test.dart (4)
- production favorites UX1 bookshelf gallery=true preference=viewDetail text=1.0 hover/real rows/cover/menu/selection
- production favorites UX1 bookshelf gallery=true preference=read text=1.0 hover/real rows/cover/menu/selection
- production favorites UX1 bookshelf gallery=true preference=viewDetail text=1.5 hover/real rows/cover/menu/selection
- production favorites UX1 bookshelf gallery=true preference=read text=1.5 hover/real rows/cover/menu/selection

### features/favorites/favorites_reorder_test.dart (4)
- favorite mouse columns 4 keeps layout and drag order
- favorite touch columns 4 keeps layout and drag order
- favorite mouse columns 0 keeps layout and drag order
- favorite touch columns 0 keeps layout and drag order

### features/favorites/folder_creation_presentation_test.dart (2)
- removed sidebar rejects a late Create Folder publication
- removed sidebar rejects a late Sort publication

### features/reader/auto_reading_viewport_test.dart (2)
- waterfallTopToBottom: reads content before crossing chapters and stops at the end
- continuousTopToBottom: reads content before crossing chapters and stops at the end

### features/reader/gallery_viewport_rendering_test.dart (2)
- collapsed thumbnails preserve full viewport
- floating thumbnails preserve full viewport

### features/reader/information_overlay_test.dart (6)
- information stays readable inside safe area (dark: false, scale: 1.0, size: Size(375.0, 667.0))
- information stays readable inside safe area (dark: true, scale: 3.2, size: Size(375.0, 667.0))
- information stays readable inside safe area (dark: true, scale: 1.0, size: Size(667.0, 375.0))
- information stays readable inside safe area (dark: false, scale: 3.2, size: Size(667.0, 375.0))
- information stays readable inside safe area (dark: false, scale: 2.0, size: Size(1024.0, 768.0))
- information stays readable inside safe area (dark: true, scale: 3.2, size: Size(320.0, 568.0))

### features/reader/reader_exit_integration_test.dart (15)
- progress dispatches image endpoints in waterfallTopToBottom
- progress dispatches image endpoints in galleryLeftToRight
- progress dispatches image endpoints in galleryRightToLeft
- progress dispatches image endpoints in galleryTopToBottom
- progress dispatches image endpoints in continuousTopToBottom
- progress dispatches image endpoints in continuousLeftToRight
- progress dispatches image endpoints in continuousRightToLeft
- registry F12 remains key-up fullscreen and supports an override
- production window manager channel acknowledgement gates core close
- host waits for window restoration; detached=false
- host waits for window restoration; detached=true
- failed window show blocks core; retry only shows and preserves reader writes
- removing an old reader keeps newer reader fullscreen in the shared frame
- window close restores fullscreen after a later reversible preparation fails
- window release stays with original application after reader reparenting

### features/reader/shell_presentation_test.dart (3)
- shell renders from explicit input at Size(375.0, 667.0)
- shell renders from explicit input at Size(667.0, 375.0)
- shell renders from explicit input at Size(1024.0, 768.0)

### features/search/search_profile_flow_test.dart (1)
- aggregate title and cover open exact source detail once, not full results

### features/settings/settings_inplace_editing_test.dart (1)
- Comment keyword blocking uses the right pane at 720.0

