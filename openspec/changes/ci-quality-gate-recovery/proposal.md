# Proposal

## Why

当前主分支的质量工作流无法完成：结构检查发现 25 条受限 import 与 4 条 feature 入口违规，干净环境无法下载 `CyrilPeng/webdav_client`（冷缓存验证又发现 `CyrilPeng/flutter.widgets` 与 `CyrilPeng/flutter_inappwebview` 同样失效），macOS 目录授权 job 还使用了不受支持的 runner；此外架构 inventory 的既有未分类库文件、CI 可见的 12 条 analyze 问题与全量测试的既有失败也会继续让分析 job 保持红色。现有本地缓存和提前中断的 job 掩盖了后续检查状态，需要先恢复可信、可重复的 CI 门禁，才能继续验证桌面化与后续功能改动。

## What Changes

- 将当前锁定版本的 `webdav_client` 源码及许可证纳入仓库，改用本地 path 依赖，并对锁文件做最小同步；不得通过升级依赖或重新生成整份锁文件解决。
- 将冷缓存暴露的另外两个失效 git 依赖（`scrollable_positioned_list` 所属 `flutter.widgets`、`flutter_inappwebview`）的 URL 指向同 commit 可达的 `venera-app` 镜像，ref、版本与源码内容保持不变；不替换实现、不升级版本。
- 修复现有受限 import 与 search feature 入口违规，保持用户行为不变，不删除结构检查、不增加豁免基线。
- 补齐仓库既有的模块边界 inventory 缺口（当前 44 个未分类库文件，含本 change 搬迁到 `components/` 的 6 个文件），使 `check_architecture_dependencies.py` 通过；inventory 是分类登记，不得以白名单、忽略规则或删除检查替代。
- 修复 CI 可见的既有静态分析问题（12 条，含 `test/features/favorites/folder_order_ownership_test.dart` 的返回类型编译错误），使 `flutter analyze --fatal-infos --fatal-warnings` 在本仓范围内通过；静态分析与 Dart 格式检查仅排除 vendored `packages/webdav_client/`，本仓代码与 lint 规则不缩减。
- 将 macOS 目录授权测试迁移到受支持的 runner，与现有桌面构建所使用的 macOS 环境保持一致。
- 增加或调整针对冷缓存依赖解析、结构边界、架构 inventory、工作流配置与 vendored 排除范围的回归验证，并实际运行结构检查、Flutter 测试与静态分析。
- 通过普通提交和 PR 核对代码分析、Flutter 测试与覆盖率、macOS 目录授权及桌面平台门禁结果；全量测试的既有失败须逐条区分“环境限制”与“仓库缺陷”，仓库缺陷在门禁通过前修复。

## Capabilities

### New Capabilities

- `architecture/module-boundaries`: 规定 components、features、app_runtime 与 app_shell 的依赖方向，以及 feature 公共入口的使用要求。
- `distribution/ci-quality-gates`: 规定干净环境中的依赖可解析性、受支持 CI 运行环境和质量门禁的完整执行要求。

### Modified Capabilities

无；现有 `settings/webdav-storage` 的远程存储行为不变，本 change 只替换其客户端源码的供应方式。

## Impact

- 影响 `pubspec.yaml`、`pubspec.lock`、新增 `packages/webdav_client/` 及其许可证。
- 影响 `pubspec.yaml`／`pubspec.lock` 中 `scrollable_positioned_list` 与 `flutter_inappwebview` 的 git URL（仅 URL），以及 `doc/development/git_dependencies.json` 的依赖来源记录。
- 影响 `lib/components/`、`lib/features/`、`lib/app_shell/` 中现有违规 import 及为反转依赖所需的接口或公共入口。
- 影响 `doc/architecture/dependency_baseline.json` 的库文件分类（补齐既有 inventory 并登记本 change 搬迁/新增文件）。
- 影响 `analysis_options.yaml`（仅排除 vendored 目录）与 `.github/workflows/analyze.yml` 的格式检查步骤（仅排除 vendored 目录）。
- 影响 CI 可见的 12 条既有静态分析问题及其中的测试编译错误；本地 `tool/code_audit` 环境产生的 38 项不属于本 change 目标。
- 影响 `.github/workflows/analyze.yml` 与相关脚本测试。
- 本地与 CI 的 WebDAV 客户端固定在当前已锁定提交对应的源码，不再依赖原远端仓库持续可用。

## Out of Scope

- 不改变 WebDAV 连接配置、同步、备份或在线漫画库的用户行为。
- 不升级 Flutter、Dart、WebDAV 客户端或其他依赖，不重新生成整份 `pubspec.lock`；两个镜像 URL 变更不改变 ref、版本或源码内容。
- 不借本 change 重构无关模块、扩大桌面发布矩阵，或清理本地 `tool/code_audit` 环境产生的 38 项；只修复 CI 可见的 12 条。
- 不修改 vendored 源码内容或格式来通过检查；`packages/webdav_client/` 保持与上游提交逐字节一致。
- 不把既有违规以白名单、忽略规则或删除检查的方式消音；inventory 与既有 UI 层依赖边的登记必须附清单并作为已知债务，不得用于吸收新引入的反向依赖。
- 不修改与本门禁无关的产品行为或测试断言；全量测试中的既有环境失败只做二分、记录与复现命令，不擅自修。
- 不引入 actionlint 作为必装工具；它不能发现本次依赖与架构问题。
