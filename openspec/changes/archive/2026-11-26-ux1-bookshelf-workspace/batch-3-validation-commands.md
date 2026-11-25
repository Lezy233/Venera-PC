# 第三批可重放命令与结果（进行中）

执行目录为仓库根。Flutter前缀固定为：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub
```

以下参数分别追加在此前缀后；均使用`--reporter expanded`。日志在/tmp，重叠命令不累加计数。

| 参数 | 原始日志 | 通过/失败/skip |
|---|---|---|
| `test/app_shell/workspace_preview_test.dart` | ux1-b3-workspace-final-green.log | 7/0/0 |
| `test/features/comic_widgets/comic_preview_test.dart --plain-name 'keyboard Space on focused checkbox'` | ux1-b3-checkbox-semantics-green.log | 1/0/0 |
| `test/app_shell/workspace_preview_test.dart test/features/comic_widgets/comic_preview_test.dart` | ux1-b3-preview-final-loop.log | 37/1/0；唯一测试SemanticsHandle清理过晚，checked实际断言已通过，随后单项finally清理1绿；此轮早于mixed来源新增，不冒称一次39绿 |
| `test/features/comic_widgets/comic_preview_test.dart test/features/search/result_preview_test.dart` | ux1-b3-result-checkbox-enter-green.log | 34/0/0；当时32预览+2结果入口 |
| `test/features/comic_widgets/comic_preview_test.dart test/features/search/result_preview_test.dart test/features/settings/preview_motion_setting_test.dart test/features/favorites/favorite_hit_target_test.dart test/features/favorites/bookshelf_hit_target_test.dart` | ux1-b3-result-motion-preview-loop.log | 43/0/0，早于Checkbox Enter隔离增量，历史而非最终同源码合跑 |
| `test/app_shell/bookshelf_favorites_continuity_test.dart` | ux1-b3-continuity-checkbox-loop.log | 1/0/0 |
| `test/features/favorites/author_shelf_ui_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/author_shelf_independence_test.dart test/features/favorites/author_shelf_order_test.dart test/features/favorites/sidebar_sections_test.dart test/features/favorites/favorite_series_test.dart` | ux1-b3-author-series-protection.log | 80/1/0；唯一F11旧主体选择建场，后续定向迁移1绿 |
| `test/features/favorites/sidebar_sections_test.dart --plain-name 'real local content instance two selections filter and scroll survive collapse'` | ux1-b3-f11-checkbox-loop.log | 1/0/0 |
| `test/features/favorites/author_shelf_hover_test.dart test/features/favorites/author_shelf_layout_test.dart test/features/favorites/author_shelf_storage_test.dart test/features/comic_widgets/comic_hit_target_test.dart` | ux1-b3-layer-hit-protection.log | 115/0/0 |

F1完整原场景命令（`/tmp/ux1-b3-f1-final-protection.log`，24/0/0）：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_aggregate_state_test.dart test/app_shell/workspace_auxiliary_route_test.dart test/app_shell/workspace_background_test.dart test/app_shell/workspace_close_policy_test.dart test/app_shell/workspace_details_state_test.dart test/app_shell/workspace_empty_test.dart test/app_shell/workspace_focus_test.dart test/app_shell/workspace_history_test.dart test/app_shell/workspace_keyboard_test.dart test/app_shell/workspace_local_reader_route_test.dart test/app_shell/workspace_reader_state_test.dart test/app_shell/workspace_reader_tabs_test.dart test/app_shell/workspace_route_lifecycle_test.dart test/app_shell/workspace_save_failure_test.dart test/app_shell/workspace_search_results_test.dart test/app_shell/workspace_search_state_test.dart test/app_shell/workspace_settings_test.dart test/app_shell/workspace_tab_input_test.dart test/app_shell/workspace_tabs_test.dart --reporter expanded
```

最终分析命令，`/tmp/ux1-b3-final-analyze-fixed.log` raw/unique50=38tool+12；具体集合added=[]removed=[]，见progress-analyze-comparison.json。此前final-analyze51唯一新增测试super参数lint已修，未修基线。

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter analyze --no-pub
```

已核准harness构建、之后正常main恢复，分别日志`/tmp/ux1-b3-gui-build.log`、`/tmp/ux1-b3-main-build.log`，均成功：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub --target /tmp/ux1_f2_gui.dart
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub
```

5/6阶段仅诊断红灯的完整重放源/命令/断言，另见batch-3-baseline-diagnostics.md；不混入常规suite或skip。architect独立225/1历史及continuity单项1绿、诊断1绿4预期红、analyze50记录见review-batch-3.md，不改写该architect文件。

## 4.3主体必要依赖最终增量

同上固定Flutter test前缀与--reporter expanded，原始日志分别：

- /tmp/ux1-b3-body-preference-red.log：原/tmp/ux1_b3_click_baseline_test.dart，0/2/0真实read主体红；原脚本保留改前历史。
- /tmp/ux1-b3-body-hit-protection.log：test/features/search/card_body_preference_test.dart、test/features/search/result_preview_test.dart、test/features/favorites/favorite_hit_target_test.dart、test/features/favorites/bookshelf_hit_target_test.dart，19/0/0。
- /tmp/ux1-b3-preview-read-promotion.log：test/app_shell/workspace_preview_test.dart --plain-name 'real selection preview-read'，1/0/0。
- /tmp/ux1-b3-body-reader-hero-protection.log：test/app_shell/workspace_reader_tabs_test.dart、test/features/comic_widgets/comic_hit_target_test.dart，93/0/0；既有内存插件测试平台捕获警告单列。
- architect独立/tmp/ux1-b3-architect-body-dependency.log，123/0/0，不与上述重叠累加。
- 当前analyze --no-pub：/tmp/ux1-b3-body-analyze-fixed.log，50/50具体集合零增减；current_log已同步。
- 同上GUI构建--target /tmp/ux1_f2_gui.dart：/tmp/ux1-b3-body-gui-build.log；同上无target正常main构建：/tmp/ux1-b3-body-main-build.log，均成功。
### 作者栏独立手柄最终增量

同上代理/LD_LIBRARY_PATH前缀，--no-pub --reporter expanded：
- 红灯：test/app_shell/workspace_author_handle_test.dart → /tmp/ux1-b3-author-handle-input-red.log，0/1/0，正确初始化后真实坐标drag预期3标签实际1。初始化/定位修正另列delivery，不计产品红灯。
- 最小绿：同文件 → /tmp/ux1-b3-author-handle-green.log，1/0/0。
- 原三态扩展 → /tmp/ux1-b3-author-handle-matrix.log，3/0/0。
- 新文件 + test/features/favorites/{author_shelf_drag_test,author_shelf_ui_test,sidebar_sections_test}.dart → /tmp/ux1-b3-author-handle-protection.log，58/0/0，含三态选中卡片实际长按仅栏内排序。
- 最终新文件单项 → /tmp/ux1-b3-author-handle-final.log，3/0/0，600/1000/1400三宽、简繁150%、浅深/减少动画条件。
- architect独立/tmp/ux1-b3-architect-author-handle.log，60/0/0，含原独立排序保护；与本地集合重叠，不相加。
- env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 fvm flutter analyze --no-pub → /tmp/ux1-b3-author-handle-analyze.log，raw/unique50=38+12，comparison具体added=[]removed=[]。
- 已批准工具未改，GUI与main构建均env代理 + RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub；GUI额外--target /tmp/ux1_f2_gui.dart，日志/tmp/ux1-b3-author-handle-gui-build.log；无target正常main为/tmp/ux1-b3-author-handle-main-build.log。两者成功。
- 经核准helper前缀 env DISPLAY=:1 python3 /tmp/ux1_f2_x11.py：真实drag 954 226 620 130 cancel author-cancel-live-1102014 / drop author-drop-live-1102014；每步后key F6及capture稳定图。逐图和身份/目录/物理尺寸记录见batch-3-gui-evidence.md。
- git diff --check及openspec validate --changes ux1-bookshelf-workspace均通过，保护文件零授权外diff；planner design/browse-spec/dispatch增量单列。
### 正常main启动修复的最终增量

精确正常入口red/同输入green/fresh green、只观察首帧对照及其原始命令见batch-3-startup-diagnostics.md；/tmp/ux1-b3-startup-order-comparison.json为真实日志断言结果。main唯一授权diff是既有await移到runApp前。

architect独立命令：同代理/LD_LIBRARY_PATH前缀 fvm flutter test --no-pub test/app_runtime/window_placement_host_test.dart test/app_runtime/interactive_window_placement_test.dart test/app_runtime/application_host_test.dart test/app_runtime/application_host_integration_test.dart --reporter expanded，/tmp/ux1-b3-architect-startup-protection.log：32通过0失败2既有Windows专属skip，不是0skip，不与历史60相加。无本轮新增skip/源码镜像测试。

最新analyze --no-pub为/tmp/ux1-b3-architect-startup-analyze.log，raw/unique50=38+12，具体added=[]removed=[]。最终正常main build linux --debug --no-pub日志/tmp/ux1-b3-startup-final-main-build.log成功，kernel4100dcba…；最终fresh运行该未经包装main bundle，有实际完整画面，五自有PID精确清理，另owner同名窗口未操作。19/31/139独立全MATCH，architect已判启动修复符合；收到最终结论后只补交付文字，不再执行检查。
