# ci-quality-gate-recovery 交付说明

- 分支：`fix/ci-quality-gates`（基于 `main` HEAD `cec0762`）
- 本地提交：`e1aed73`（a：干净环境依赖解析与模块边界，含 tasks.md 新任务定义）+
  提交 b（本提交：补齐架构 inventory、格式与静态分析门禁；本文件随该提交入库）
- 状态：1.1–3.1、4.1–4.4 本地完成并勾选；**未 push、未创建 PR、未 archive、未合入正式 specs**；
  4.5（PR 门禁）按 owner 指令不执行。
- 受保护工件零 diff：`proposal.md`、`design.md`、`specs/**`、`design-spec.md`、`openspec/specs/**`、
  `check_structure_imports.py`、`check_architecture_dependencies.py`。

## 任务结果

| 任务 | 结果 | 关键证据 |
|------|------|----------|
| 1.1 | `packages/webdav_client/` 15 个上游文件 + `PROVENANCE.md`；与缓存 commit `2f669c9…` 逐文件一致；无 `.git/`、示例或上游测试 | `tmp/ciqg/1.1-verify.txt` |
| 1.2 | 根依赖改 `path: packages/webdav_client`；lock 仅该条目变化、版本 1.2.2；新增 3 项静态测试；lock 包集合 157=157 | `tmp/ciqg/1.2-verify.txt`、`python-tests-1.2.txt` |
| 1.3 | 干净克隆 + 空 `PUB_CACHE` + `--enforce-lockfile` 成功；lock sha256 前后一致；两个额外失效 git 依赖改同 commit 镜像（仅 URL，10 行） | `tmp/ciqg/1.3-verify.txt`、`1.3-pub-get.log` |
| 2.1 | 4 个文件移至 `foundation/`（1）与 `components/`（3），批量改 package import 57 文件 + 相对 import 9 文件；旧路径零残留 | `tmp/ciqg/structure-2.1-2.2.txt`、`test-2.1*.log` |
| 2.2 | `desktop_chrome`、`desktop_top_bar`、`bookshelf_workspace` 移至 `components/`；桌面/窗口/书架测试零新增失败 | `tmp/ciqg/test-2.2*.log` |
| 2.3 | 新增 feature 注册 API `webdav_library_registry.dart`；app_runtime 仅保留单例/组合；设置页经 `WebDavLibraryScope` 取服务 | `tmp/ciqg/structure-2.3.txt`、`test-2.3*.log` |
| 2.4 | app_shell 3 处 + favorites 1 处 search 实现 import 切到公共入口；入口违规 4→0 | `tmp/ciqg/structure-2.4.txt`、`test-2.4*.log` |
| 2.5 | 44 个未分类库文件最小归类（business 17 / ui 27）；基线 business 350、ui 223、pending 0；`check_architecture_dependencies.py` 退出 0、`test_architecture_dependencies.py` 49/49 | `tmp/ciqg/2.5-architecture.log`、`2.5-architecture-tests.log` |
| 3.1 | `apple-directory-access` runner `macos-14`→`macos-15`；新增 2 项工作流静态测试；job 名称/步骤数与 HEAD 一致 | `tmp/ciqg/3.1-verify.txt` |
| 3.2 | 格式步骤仅排除 vendored `packages/webdav_client/`；新增静态测试锁定过滤范围；CI 同款 diff 验证 vendored 跳过、本仓 78 文件仍检查；vendored sha256 未变 | `tmp/ciqg/3.2-verify.log`、`3.2-vendored-unformatted.log` |
| 4.1 | 74+19 个 Dart 文件格式化（0 待改）；Python 全量测试通过；`git diff --check` 干净；旧 import 零残留；依赖审查脚本通过 | `tmp/ciqg/4.1-*.log` |
| 4.2 | 原生测试库就绪；`flutter test --coverage` 完成（5652 通过/70 失败/150 skip，行覆盖率 81.78%）；`flutter analyze` 50 项与基线一致 | `tmp/ciqg/4.2-*.log`、`coverage/lcov.info` |
| 4.3 | 12 条 CI 可见 analyze 问题修复；`flutter analyze --fatal-infos --fatal-warnings` 50→0；38 项 tool/code_audit 环境项在 `dart pub get --enforce-lockfile` + self_check + dart analyze 后消失；lock 未变 | `tmp/ciqg/4.3-*.log` |
| 4.4 | CI 等价并发全量测试 5719 通过 / 64 失败 / 150 skip；67 项失败与 HEAD worktree 逐条一致；3 项既有仓库缺陷修复；其余 64 项为 HEAD 既有 CI 必挂项，已单列 | `tmp/ciqg/4.4-*.log`、`4.4-bisect.md` |
| 4.5 | 未执行（需 PR 与 GitHub Actions 结果，owner 未授权 push/PR） | — |

## 2.5/3.2/4.3/4.4 本轮实施说明

### 2.5 架构 inventory

- 44 个未分类库文件按现有职责逐文件最小归类：business 17、ui 27；未改检查脚本、未加忽略规则、
  `pending_review_files` 保持 0。
- 归类后检查脚本不再被“未分类短路”，暴露两项 HEAD 已存在的隐藏事实，按基线既有机制处理并记录：
  1. **4 条 UI 层跨 feature 依赖边**（`favorites→search`、`reader→settings`、`search→favorites`、
     `settings→search`）在 HEAD 已存在，登记进 `allowed_feature_edges`（58→62）；均只涉及 UI 文件，
     无 business 边，未减少任何检查。spec 要求新增 feature 依赖边必须先在允许列表中登记。
  2. **foundation 业务循环** `appdata→settings_recovery→translations→app_locale→appdata`：
     把 `app_locale` 对 `appdata` 的反向 import 改为 `Appdata` 构造时绑定 `Settings`
     （`attachAppLocaleSettings`），locale 解析仍逐次读取同一 settings 视图，行为不变。
- 消除 business→UI 边的三处 compat barrel 引用：`favorite_filters.dart`、
  `creator_platform_names.dart`、`search_profile.dart` 由 `comic_source.dart` 改引
  `comic_source_api.dart`（该 barrel 注释已要求业务消费方改用 api）；
  `app_runtime/webdav_library.dart` 改 import feature 的 `webdav_library_api.dart` +
  `webdav_library_registry.dart` 两个公共文件（不再经 UI 入口）。
- 最终 `Architecture dependency baseline is clean.`（退出 0）；`test_architecture_dependencies.py` 49/49。

### 3.2 格式门禁

- `.github/workflows/analyze.yml` 的格式步骤只增加一个排除路径：
  `':(exclude)packages/webdav_client/**'`；本仓 `lib/`、`test/`、`tool/`、其他 `packages/` 仍受检查。
- `test_desktop_ci_cd.py` 新增静态测试，锁定“唯一排除路径、原 `git diff` 范围、`dart format` 命令，
  且不得排除 lib/test/tool 或使用更宽通配”（该文件 14/14）。
- 用 CI 相同的 git diff 范围（`main...HEAD`）验证：范围含 89 个 Dart 文件（11 个 vendored），
  过滤后 78 个本仓文件、0 vendored，格式检查退出 0；对 11 个 vendored 文件直接检查退出 1
  （`webdav_dio.dart` 会被改格式），但 `--output=none` 未写入任何文件，11 文件 sha256 前后一致。
  未格式化或修改 vendored 源码。

### 4.3 静态分析门禁

- 修复 12 条 CI 可见问题（11 条 warning/info + folder_order 测试的返回类型编译错误）：
  补 `await`（或在 try 外返回 Future，保持原语义）、`onReorder`→`onReorderItem`（新回调已调整
  newIndex，移除重复递减）、`cacheExtent`→`scrollCacheExtent`、移除未用 catch stack、
  JS interop typed catch→`isA<DOMException>()`、super parameters、测试返回类型 `onReorderItem!`。
- 未关闭 `--fatal-*`、未加 ignore、未改 vendored。
- `flutter analyze --fatal-infos --fatal-warnings`：修复前 50 项（38 tool/code_audit + 12 lib/test）
  → 修复后 `No issues found!`（退出 0）。
- `cd tool/code_audit && dart pub get --enforce-lockfile`（其 lock sha256 不变）+
  `dart run bin/self_check.dart` + `dart analyze --fatal-infos` 全过后，38 项环境项消失，
  证明其为本地未解析依赖所致；root `pubspec.lock` sha256 前后一致。

### 4.4 全量测试 CI 对齐

- 原生测试库 5 个就绪后，CI 等价并发 `flutter test --coverage --concurrency=4` 完整结束：
  **5719 通过 / 64 失败 / 150 skip**，`coverage/lcov.info` 生成，行覆盖率 **81.96%**。
- 本机 20 核默认并发首轮跑到 `+5698` 后 3 个 `flutter_tester` 在 teardown 卡死 >20 分钟无进展，
  属本机并发/环境问题；`--concurrency=4` 是 CI（4 核）等价绕行，不作为交付条件。
- 4.2 的 70 项失败中 3 项是 `folder_order_ownership_test` 编译错误引起的 loading 失败（4.3 已修）；
  其余 67 项以 31 个失败文件在 **HEAD worktree（`cec0762` 干净副本 + 同原生库）逐条复跑**：
  67 项失败集合与当前逐条一致，本 change **零新增**。
- 二分结果：
  - **3 项既有仓库缺陷已修**：translations 缺 `Dismiss`/`Previous` 的 zh_CN/zh_TW 词条；
    favorite_preferences 默认键缺 `favoritesDensity` 且 `favoritesDisplayMode` 默认仍写 `list`；
    data_sync_operation 的 rollback fixture 未包含 settings 始终存在的 `webdav.connection` 键。
  - **64 项为 HEAD 既有 UX1/reader-shell 未完成缺陷**：确定性 widget finder、布局尺寸、
    `setState() called during build`、焦点/窗口断言失败，非本机环境变量可消，HEAD 同文件逐条复现；
    CI 使用同一 Flutter 3.47.7，属 **CI 必挂项**。它们属于活动 change
    `ux1-bookshelf-workspace` 的实现范围，超出本 change 的 Out of Scope 与“不改产品行为与无关测试断言”
    硬规则，已单列清单交 owner 决策；逐条测试名、失败签名与复现命令见 `tmp/ciqg/4.4-bisect.md`。
    在这些项清除前不得勾选 4.5。

## 需要 architect/owner 注意的偏差与发现

1. **额外失效 git 依赖（已获 owner 授权处理）**：`CyrilPeng/flutter.widgets` 与
   `CyrilPeng/flutter_inappwebview` 也已 404；改为同 commit 可达的 `venera-app` 公开镜像，
   仅改 URL（10 行），ref/版本/内容不变；同步 `doc/development/git_dependencies.json`。
2. **vendored 源码分析排除**：`flutter analyze` 会把 `packages/webdav_client/` 当作本包代码；
   `analysis_options.yaml` 仅排除该目录，未排除任何本仓代码或放宽 lint。
3. **2.5 的 4 条 allowed feature 边**：在 HEAD 已存在、本次仅登记（58→62），均 UI 层、无 business 边。
   如 owner 希望清理这些跨 feature UI 依赖，应在后续 change 中重构，而不是继续扩大允许列表。
4. **4.4 残留 64 项 CI 必挂失败**：需要 owner 决策归属（建议并入 `ux1-bookshelf-workspace`
   的 6.x/7.x 修复，或单列 change），清除前 4.5 的 PR 门禁无法转绿。
5. **本机环境**：20 核默认并发存在 teardown 卡死；CI 等价 `--concurrency=4` 可完整结束。

## 复现命令

```bash
python3 .github/scripts/check_structure_imports.py
python3 .github/scripts/check_architecture_dependencies.py
python3 -m unittest discover -s .github/scripts/tests -p 'test_*.py'
cd tool/code_audit && dart pub get --enforce-lockfile && dart run bin/self_check.dart && dart analyze --fatal-infos && cd ../..
flutter analyze --fatal-infos --fatal-warnings
python3 .github/scripts/prepare_linux_test_libraries.py
LD_LIBRARY_PATH=$PWD/build/test-native/lib flutter test --coverage --concurrency=4
python3 .github/scripts/report_dart_coverage.py coverage/lcov.info
```

所有本地证据位于 `tmp/ciqg/`（`tmp/` 被 .gitignore 忽略，不会进入提交）。
