# Proposal

## Why

项目已经明确以 Windows、macOS、Linux 为目标平台，但现有 CI/CD 仍构建、检查并发布 Android 与 iOS 产物，维护成本和项目定位不一致。需要先收敛自动化与发布范围，再进行 Venera-PC 对外更名，避免更名工作继续覆盖即将移除的移动端链路。

## What Changes

- **BREAKING（发布行为）**：完整构建与 Release 只生成并发布 Windows、macOS、Linux 资产，不再构建或上传 APK、IPA。
- 移除可复用构建工作流中的 Android/iOS 输入、签名 secrets 与 jobs，保留 Windows、macOS、Linux x64、Linux ARM64。
- PR 平台冒烟移除 Android job 及其门禁依赖，保留现有 Windows 冒烟；不借本 change 扩大 PR 平台矩阵。
- 质量检查移除 iOS 专属 Rust 兼容性 job，保留 macOS 目录授权、通用 Rust/Flutter 测试、静态分析和覆盖率。
- 停用 Fastlane Supply 元数据校验与 AltStore 源自动更新流程。
- 保留 winget、依赖审查、Issue 检查、工作流清理和赞助同步等平台无关或桌面相关自动化。
- 同步受工作流结构与 Release 资产集合约束的脚本测试和维护文档。

## Capabilities

### New Capabilities

- `distribution/desktop-ci-cd`: 规定桌面平台的持续集成、发布资产集合、移动端自动化排除范围，以及通用质量门禁的保留要求。

### Modified Capabilities

无；现有正式 specs 未覆盖构建与发布自动化。

## Impact

- 影响 `.github/workflows/` 下的构建、发布、PR 冒烟、质量检查及移动端商店工作流。
- 影响 `.github/scripts/tests/` 中依赖上述工作流结构的测试，以及相关开发、分发文档。
- GitHub Release 不再提供 Android/iOS 资产；已有历史 Release 不受影响。
- 不修改 Dart 应用逻辑，不重新生成 `pubspec.lock`。

## Out of Scope

- 不删除 `android/`、`ios/`、`fastlane/` 或其他移动端源码、工程文件和元数据。
- 不改变移动端布局继续工作的项目约束，也不主动破坏移动端本地构建能力。
- 不修改产品名称、README 项目叙述、应用 ID、包名或数据目录；这些由后续更名 change 处理。
- 不新增 macOS/Linux PR 冒烟、代码签名、公证或新的分发渠道。
- 不清理历史 Release、移动端 secrets 或仓库中的历史文档叙述。
