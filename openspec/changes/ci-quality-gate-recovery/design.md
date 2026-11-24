# Design

## Context

当前 `webdav_client` 通过失效的 Git 仓库固定在提交 `2f669c98fb81cff1c64fee93466a1475c77e4273`，本机 pub 缓存仍保存对应 1.2.2 源码和 BSD 3-Clause 许可证。结构违规主要来自共享 UI 与工作区文件放在 `app_shell`，导致 components 和 features 反向 import；search 的公共入口已经导出所需三个页面。macOS 构建已使用 `macos-15`，只有目录授权检查仍使用 `macos-14`。

## Goals / Non-Goals

**Goals:**

- 用最小文件移动和 import 更新消除现有违规，保持类名、页面组合和运行行为稳定。
- 固定当前 WebDAV 客户端源码，不引入新的远端账户、令牌或私有仓库配置。
- 让本地冷缓存验证覆盖 CI 的首次依赖恢复路径。

**Non-Goals:**

- 不重新设计工作区、桌面 chrome 或 WebDAV 服务接口。
- 不复制上游示例工程、图片或依赖真实服务器的上游测试。
- 不通过修改结构检查规则绕过现有违规。

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

结构修复后运行结构检查、相关 Flutter 测试、全量 Flutter 测试与覆盖率及 analyze；analyze 只要求相对既有 50 项基线零新增。最后通过 PR 核对 GitHub 上的 macOS、analyze、Flutter 测试与桌面平台门禁。

## Risks / Trade-offs

- [移动共享文件遗漏相对 import 或测试引用] → 全局搜索旧路径，运行格式检查、analyze 和相关测试；不改变公共类型名称。
- [仓库内 WebDAV 源码后续缺乏上游自动更新] → 固定来源提交并保留许可证；后续升级必须作为独立、可审查的依赖变更。
- [设置测试未提供 WebDAV scope] → 更新测试宿主显式注入服务，覆盖用途切换后的注册调用。
- [完整 Flutter 测试此前被依赖失败遮蔽] → 实际运行全量测试；只修复与本 change 相关的回归，其他既有问题单独记录。

## Migration Plan

1. 先纳入 WebDAV 源码并做最小锁文件同步，以冷缓存验证恢复依赖解析。
2. 再移动共享模块、分离 WebDAV 注册能力并切换 search 公共入口，逐步运行结构检查。
3. 更新 macOS runner 和静态契约测试，完成本地全量验证后提交 PR。
4. GitHub 验收只使用普通提交和 PR，不创建 Release tag；若出现回归，回滚该 change 的提交即可恢复旧依赖和文件位置，无应用数据迁移。
