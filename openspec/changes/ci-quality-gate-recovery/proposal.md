# Proposal

## Why

当前主分支的质量工作流无法完成：结构检查发现 25 条受限 import 与 4 条 feature 入口违规，干净环境无法下载 `CyrilPeng/webdav_client`，macOS 目录授权 job 还使用了不受支持的 runner。现有本地缓存和提前中断的 job 掩盖了后续检查状态，需要先恢复可信、可重复的 CI 门禁，才能继续验证桌面化与后续功能改动。

## What Changes

- 将当前锁定版本的 `webdav_client` 源码及许可证纳入仓库，改用本地 path 依赖，并对锁文件做最小同步；不得通过升级依赖或重新生成整份锁文件解决。
- 修复现有受限 import 与 search feature 入口违规，保持用户行为不变，不删除结构检查、不增加豁免基线。
- 将 macOS 目录授权测试迁移到受支持的 runner，与现有桌面构建所使用的 macOS 环境保持一致。
- 增加或调整针对冷缓存依赖解析、结构边界和工作流配置的回归验证，并实际运行结构检查、Flutter 测试与静态分析。
- 通过 PR 核对代码分析、Flutter 测试与覆盖率、macOS 目录授权及桌面平台门禁结果。

## Capabilities

### New Capabilities

- `architecture/module-boundaries`: 规定 components、features、app_runtime 与 app_shell 的依赖方向，以及 feature 公共入口的使用要求。
- `distribution/ci-quality-gates`: 规定干净环境中的依赖可解析性、受支持 CI 运行环境和质量门禁的完整执行要求。

### Modified Capabilities

无；现有 `settings/webdav-storage` 的远程存储行为不变，本 change 只替换其客户端源码的供应方式。

## Impact

- 影响 `pubspec.yaml`、`pubspec.lock`、新增 `packages/webdav_client/` 及其许可证。
- 影响 `lib/components/`、`lib/features/`、`lib/app_shell/` 中现有违规 import 及为反转依赖所需的接口或公共入口。
- 影响 `.github/workflows/analyze.yml` 与相关脚本测试。
- 本地与 CI 的 WebDAV 客户端固定在当前已锁定提交对应的源码，不再依赖原远端仓库持续可用。

## Out of Scope

- 不改变 WebDAV 连接配置、同步、备份或在线漫画库的用户行为。
- 不升级 Flutter、Dart、WebDAV 客户端或其他依赖，不重新生成整份 `pubspec.lock`。
- 不借本 change 重构无关模块、清理既有 50 项 analyze 基线或扩大桌面发布矩阵。
- 不引入 actionlint 作为必装工具；它不能发现本次依赖与架构问题。
- 不通过删除检查、注释违规规则或建立既有问题白名单使 CI 变绿。
