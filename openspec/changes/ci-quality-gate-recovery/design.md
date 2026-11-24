# Design

## Context

当前 `webdav_client` 通过失效的 Git 仓库固定在提交 `2f669c98fb81cff1c64fee93466a1475c77e4273`，本机 pub 缓存仍保存对应 1.2.2 源码和 BSD 3-Clause 许可证。结构违规主要来自共享 UI 与工作区文件放在 `app_shell`，导致 components 和 features 反向 import；search 的公共入口已经导出所需三个页面。macOS 构建已使用 `macos-15`，只有目录授权检查仍使用 `macos-14`。

冷缓存验证进一步暴露：`scrollable_positioned_list`（`CyrilPeng/flutter.widgets`）与 `flutter_inappwebview`（`CyrilPeng/flutter_inappwebview`）的远端仓库同样失效；`packages/webdav_client/` 作为 vendored 源码会额外产生 138 项 analyze 结果并触发格式检查；`check_architecture_dependencies.py` 在 HEAD 已有 45 个未分类库文件，CI 以 `--fatal-infos --fatal-warnings` 运行时还有 12 条真实 analyze 问题。

## Goals / Non-Goals

**Goals:**

- 用最小文件移动和 import 更新消除现有违规，保持类名、页面组合和运行行为稳定。
- 固定当前 WebDAV 客户端源码，不引入新的远端账户、令牌或私有仓库配置。
- 让本地冷缓存验证覆盖 CI 的首次依赖恢复路径，包括全部 git 依赖而不仅是 WebDAV。
- 让架构 inventory、Dart 格式检查与 `flutter analyze --fatal-infos --fatal-warnings` 在干净环境按 CI 实际命令通过。

**Non-Goals:**

- 不重新设计工作区、桌面 chrome 或 WebDAV 服务接口。
- 不复制上游示例工程、图片或依赖真实服务器的上游测试。
- 不通过修改结构检查规则绕过现有违规。
- 不修改 vendored 源码内容，不把 vendored 目录的检查排除扩大到本仓代码。

## Decisions

### 1. 将锁定的 WebDAV 客户端作为仓库内 package 维护

从本机缓存中与锁定提交完全对应的副本提取 `lib/`、`pubspec.yaml`、`README.md`、`CHANGELOG.md` 和 `LICENSE` 到 `packages/webdav_client/`。根 `pubspec.yaml` 改为 path 依赖；`pubspec.lock` 只把该包的 source/description 改为本地路径并保留 1.2.2，不运行会重算整份锁文件的 upgrade/add 命令。

选择仓库内固定源码而不是新建 GitHub fork，是因为前者不需要 owner 额外创建仓库或配置凭据，也不会再次受单一远端仓库删除影响。保留上游 README、许可证和来源提交信息以维护来源与许可可追溯性。

### 2. 将已经属于下层职责的文件移出 app_shell

把纯工作区记录 `workspace_record.dart` 移到 `foundation/`；把 `workspace_page_scope.dart`、`workspace_navigation_scope.dart`、`workspace_comic_drag.dart`、`desktop_chrome.dart`、`desktop_top_bar.dart` 和 `bookshelf_workspace.dart` 移到 `components/`。这些文件当前不依赖 app_shell 的业务实现，移动比新建一整套回调接口更小，也符合其现有共享 UI、状态契约职责。

保留所有公共类型和行为，只更新相对 import、package import 与受影响测试的引用。`app_shell` 继续负责组合这些下层能力，components 与 features 不再反向引用它。

### 3. WebDAV 注册能力归入 feature，设置页复用现有 scope

将 `mountWebDavLibrary` 及注册所有权记录从 `app_runtime/webdav_library.dart` 分离到 `features/webdav_library/` 的公共 API；应用单例创建和启动组合仍留在 app_runtime。`RemoteStorageSettings` 在切换漫画库用途时通过现有 `WebDavLibraryScope.of(context)` 取得服务并调用该 feature 能力，不再读取 app_runtime 全局单例。

相比向设置页层层新增回调参数，这复用了生产环境已经提供的 scope。受影响测试宿主需要显式提供 scope，以验证相同路径。

### 4. search 只切换到已经存在的公共入口

`features/search/search.dart` 已导出 `search_page.dart`、`search_result_page.dart` 和 `aggregated_search_page.dart`，因此四处跨模块引用统一改为该入口，不新增转发层或重复导出文件。

### 5. macOS 质量检查与构建统一使用 macos-15

将 `apple-directory-access` 的 runner 从 `macos-14` 改为 `macos-15`，与 `build.yml` 现有 macOS 构建一致。使用明确版本而不是 `macos-latest`，避免 runner 自动升级改变 Swift 测试环境。无需为本问题安装 actionlint；由现有 Python 工作流契约测试和 GitHub 实际运行验证。

### 6. 用静态契约与真实冷启动共同验收

新增脚本测试检查 WebDAV path 依赖、锁文件本地来源和 macOS runner 一致性。随后在临时干净克隆中使用空 `PUB_CACHE` 执行 `flutter pub get --enforce-lockfile`，证明没有本机缓存遮蔽。

结构修复后运行结构检查、架构 inventory、相关 Flutter 测试、全量 Flutter 测试与覆盖率及 analyze。**门禁完成标准不再是“相对本地 50 项零新增”，而是 CI 实际命令通过**：`python3 .github/scripts/check_structure_imports.py`、`python3 .github/scripts/check_architecture_dependencies.py`、`flutter analyze --fatal-infos --fatal-warnings` 全绿，全量测试失败经二分后仓库缺陷为 0；本地 `tool/code_audit` 的 38 项环境问题须单独证明在 CI 解析依赖后消失。最后通过 PR 核对 GitHub 上的 macOS、analyze、Flutter 测试与桌面平台门禁。

### 7. 两个额外失效 git 依赖改用同 commit 镜像

冷缓存验证暴露 `scrollable_positioned_list`（`flutter.widgets`，0.3.8+1）与 `flutter_inappwebview`（6.2.0-beta.3）的 `CyrilPeng` 仓库同样 404。上游 `google/flutter.widgets`、`pichillilorenzo/flutter_inappwebview` 只能按 SHA 取到悬空对象、没有 ref 可达，pub 的 mirror clone 取不到，因此改为指向 `venera-app` 下同 commit 可达的镜像。项目在 HEAD 已有 4 个依赖指向该组织（`flutter_desktop_webview`、`lodepng_flutter`、`flutter_saf`、`flutter_7zip`），属于既有供应模式，而不是新引入的陌生来源。

只改 `pubspec.yaml`／`pubspec.lock` 的 URL 行，`ref`、`resolved-ref`、版本与源码内容不变。git 提交哈希对内容寻址，同一 commit 即同一 tree，内容完整性由哈希保证。风险仍记录：若该镜像组织不可用，需要重新评估 vendoring 或自有托管；禁止为此升级版本、改用浮动 ref 或格式化 vendored 源码。

### 8. vendored 第三方源码排除静态分析与格式检查

`packages/webdav_client/` 是逐字节保留的上游代码。`flutter analyze` 会把它当成本包代码（实测额外 138 项），`dart format` 也会按当前格式化器报告旧格式（实测 `webdav_dio.dart` 需要重排）。两者都不是本仓缺陷，也不能通过修改源码“修”掉。

因此 `analysis_options.yaml` 的 `analyzer.exclude` 与 analyze 工作流的 Dart 格式步骤都只排除 `packages/webdav_client/`；本仓 `lib/`、`test/`、`tool/`、其他 `packages/` 与全部 lint 规则不变。该排除范围由静态测试锁定，防止后续扩大成通用豁免。vendored 代码的正确性由 `flutter test`、构建与 PROVENANCE/许可证测试保证，不依赖 analyze。

### 9. 以完整 inventory 与 CI 实际命令作为门禁完成标准

`check_architecture_dependencies.py` 要求 `lib/` 下每个库文件恰有一个分类（business/ui/pending），当前 HEAD 已有 45 个未分类（含本 change 搬迁到 `components/` 的 6 个），该检查在 analyze job 第二步即失败。仅登记本 change 新增的 2 个文件不够，必须把剩余 44 个全部归类；归类是登记既有事实，不得修改脚本、增加忽略规则，或把业务文件塞进 `pending_review_files` 绕过业务依赖检查。

同时，`flutter analyze --fatal-infos --fatal-warnings` 在当前源码有 12 条真实问题（11 条 warning/info + `folder_order_ownership_test.dart` 的返回类型编译错误），本地另外 38 条预计来自未解析的 `tool/code_audit` 依赖，CI 先 `dart pub get` 后应消失，须在 4.3 用 CI 同款步骤证明。前者在本 change 修复，后者只做证明，不纳入修复范围。

## Risks / Trade-offs

- [移动共享文件遗漏相对 import 或测试引用] → 全局搜索旧路径，运行格式检查、analyze 和相关测试；不改变公共类型名称。
- [仓库内 WebDAV 源码后续缺乏上游自动更新] → 固定来源提交并保留许可证；后续升级必须作为独立、可审查的依赖变更。
- [设置测试未提供 WebDAV scope] → 更新测试宿主显式注入服务，覆盖用途切换后的注册调用。
- [完整 Flutter 测试此前被依赖失败遮蔽] → 实际运行全量测试；只修复与本 change 相关的回归，其他既有问题单独记录。
- [镜像组织未来不可用] → 已记录镜像 URL 与锁定 commit 的对应关系；若不可用，重新评估 vendoring 或自有托管，不改为浮动 ref。
- [vendored 排除范围被后续扩大] → 仅排除 `packages/webdav_client/`，由静态测试锁定；代码审查拒绝把本仓目录加入排除。
- [inventory 归类错误或用来绕过检查] → 逐文件按现有职责最小归类，运行脚本确认无新增 feature 依赖边与业务循环；禁止把业务文件归入 pending 来消音。
- [70 项既有测试失败被误判为环境问题] → 以 HEAD worktree 逐条对照并保留复现命令；CI 必挂项在 4.4 单独列出，不得带病勾 4.5。

## Migration Plan

1. 先纳入 WebDAV 源码并做最小锁文件同步，以空缓存冷启动验证恢复依赖解析；再按同一 constraint 处理两个额外失效 git 依赖（仅改 URL），并同步依赖来源记录。
2. 再移动共享模块、分离 WebDAV 注册能力并切换 search 公共入口，逐步运行结构检查。
3. 补齐架构 inventory 的 44 个未分类库文件，修复 12 条 CI 可见 analyze 问题，并给静态分析与格式检查加上仅限 vendored 目录的排除。
4. 更新 macOS runner 和静态契约测试，用 CI 同款命令完成本地全量验证后提交 PR。
5. GitHub 验收只使用普通提交和 PR，不创建 Release tag；若出现回归，回滚该 change 的提交即可恢复旧依赖和文件位置，无应用数据迁移。
