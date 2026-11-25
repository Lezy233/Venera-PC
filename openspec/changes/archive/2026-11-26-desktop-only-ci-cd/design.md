# Design

## Context

现有 `build.yml` 是可复用的多平台构建入口，`main.yml` 负责聚合构建、发布 Release 和生成 winget manifest；`pr_build.yml` 当前只运行 Android 与 Windows 冒烟。`analyze.yml` 同时包含通用检查、macOS Swift 测试和 iOS Rust 检查。Fastlane 与 AltStore 各有一条独立的移动端自动化。

本 change 只调整自动化行为，不重写桌面打包脚本，也不修改 Dart 代码。具体契约见 `specs/distribution/desktop-ci-cd/spec.md`。

## Goals / Non-Goals

**Goals:**

- 以最小结构调整现有工作流，使构建、Release 和 PR 门禁的平台集合一致地收敛到桌面端。
- 保持桌面产物名称、artifact 名称、质量检查名称和 winget 发布路径稳定，避免影响后续更名 change 之外的消费者。
- 用仓库已有脚本测试与静态校验证明没有残留的移动端构建或发布依赖。

**Non-Goals:**

- 不重构工作流为新的 matrix 架构，不调整 runner、Flutter 渠道、触发分支或桌面架构集合。
- 不删除移动端构建脚本、Release 元数据校验能力或本地移动开发支持。
- 不在本 change 中更改 Venera-PC 名称、仓库 URL 或发布资产名称。

## Decisions

### 1. 原位删减工作流，保持桌面 artifact 契约

直接在现有工作流中删除 Android/iOS 输入、jobs、secrets 和 Release 下载/ glob 项，保留桌面 job 与 artifact 名称。相比重写 matrix，这种方式减少变量，并让后续更名可以集中处理桌面名称。

`main.yml` 的 Build 调用只传桌面输入；Release 的 `needs` 结构保持不变，仍由完整 Build 聚合桌面结果。

### 2. PR 保持单一 Windows 冒烟

删除 Android job 后，`platform_gate` 仅依赖 `changes` 与 `windows`，同时删除环境变量、结果判断和摘要中的 Android 分支。Windows job 名称与 `platform_gate` 名称保持不变，降低分支保护规则的额外变化。

不将 macOS/Linux 加入 PR：这是成本和触发策略变化，不是“移除移动端”所必需。

### 3. 只移除 iOS 专属质量检查

从 `analyze.yml` 删除 `rhttp-ios`。`apple-directory-access` 虽位于 `apple/`，但 macOS 仍使用 Swift 目录授权测试，必须保留；`rhttp-native`、Flutter 测试、静态分析和覆盖率也保持原样。

已有 iOS 元数据或 Rust 防护的本地脚本与测试不随 CI 删除，因为它们属于保留的移动端源码能力，不再是桌面 CI 门禁。

### 4. 移除移动商店工作流入口，保留其文件内容

删除 `.github/workflows/fastlane.yml` 与 `.github/workflows/update_alt_store.yml`，使推送、PR 和 Release 不再触发这些自动化。`fastlane/`、AltStore 数据及更新脚本保留，符合“只收敛 CI/CD，不删除源码与元数据”的边界。

### 5. 保留 winget 与通用自动化

winget 是 Windows 桌面分发链路，继续由 Release 生成 manifest 并保留独立提交入口。依赖审查、Issue 检查、工作流清理与赞助同步不因平台收敛而改变。

## Risks / Trade-offs

- [分支保护仍要求已删除的 Android 检查] → 保持门禁汇总名称不变；交付说明列出需要在 GitHub 人工核对的分支保护项，不由代码擅自修改。
- [Release 仍引用不存在的 APK/IPA artifact 或 glob] → 同步检查 Build 输入、下载步骤和文件数组，并用脚本测试或静态断言覆盖。
- [误删 macOS 所需的 Apple 测试] → 将 `apple-directory-access` 保留写入契约与验证任务。
- [删除工作流不等于清理移动端支持] → 保留源码与元数据，并通过 `git diff` 检查变更范围。
- [旧标签重跑仍可能使用当时工作流] → 本 change 只保证新提交上的自动化行为，不修改历史 Release 或历史 tag 内容。

## Migration Plan

1. 在普通提交中完成工作流与测试调整，先通过本地脚本测试和 YAML/静态校验。
2. 通过 PR 验证 Windows 冒烟、质量检查及桌面工作流语法；不实际创建 Release。
3. 合并后由维护者核对 GitHub 分支保护中是否仍引用 Android 检查。
4. 下一次版本标签发布只产生桌面资产；若出现异常，回滚该提交即可恢复旧工作流，不涉及应用数据迁移。
