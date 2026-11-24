# Spec Delta

## Purpose

为 Venera-PC 建立只面向 Windows、macOS、Linux 的持续集成与发布契约，同时保留通用质量检查和仓库中的移动端源码，避免平台收敛破坏现有代码能力。

## ADDED Requirements

### Requirement: 桌面构建与发布矩阵
系统 SHALL 在手动完整构建和版本标签发布中构建 Windows、macOS、Linux x64 与 Linux ARM64，并且 SHALL 只发布这些桌面平台的资产。

#### Scenario: 触发完整桌面构建
- **WHEN** 维护者手动触发完整构建或推送符合规则的版本标签
- **THEN** 系统执行 Windows、macOS、Linux x64、Linux ARM64 构建
- **AND** 系统不执行 Android 或 iOS 构建

#### Scenario: 创建桌面 Release
- **WHEN** 所有桌面构建与质量门禁成功并进入 Release 阶段
- **THEN** Release 包含 DMG、Windows 安装包与便携包、DEB、RPM、Arch 包和 AppImage 等已配置桌面资产
- **AND** Release 不包含 APK 或 IPA 资产

### Requirement: 桌面 PR 冒烟门禁
系统 SHALL 在相关代码或构建配置变更时保留 Windows PR 冒烟与启动检查，并且 MUST NOT 将 Android 构建结果作为 PR 门禁依赖。

#### Scenario: 相关变更触发 PR 检查
- **WHEN** PR 修改现有平台构建检测规则覆盖的文件
- **THEN** 系统执行 Windows Debug 构建及既有原生启动验证
- **AND** 平台门禁只汇总变更检测与 Windows 检查结果

#### Scenario: 无相关变更
- **WHEN** PR 未修改平台构建检测规则覆盖的文件
- **THEN** 系统按既有变更检测规则跳过平台构建
- **AND** 平台门禁仍能给出成功的汇总结果

### Requirement: 通用与桌面质量检查保留
系统 SHALL 保留静态分析、Flutter 测试、覆盖率、通用 Rust 测试和 macOS 目录授权测试，并且 SHALL 移除仅验证 iOS 原生依赖兼容性的检查。

#### Scenario: 执行质量工作流
- **WHEN** 质量工作流由 PR、受支持分支推送或完整构建调用
- **THEN** 通用分析、测试与 macOS 目录授权检查继续执行
- **AND** 系统不准备 iOS Rust target 或执行 iOS 专属兼容性检查

### Requirement: 移动商店自动化停用
系统 MUST NOT 在代码推送、PR 或桌面 Release 完成后执行 Fastlane Supply 元数据校验或 AltStore 源更新。

#### Scenario: 修改移动商店元数据
- **WHEN** 维护者推送或提交仅修改 Fastlane 元数据的变更
- **THEN** 系统不运行 Fastlane Supply 元数据校验工作流

#### Scenario: 桌面 Release 完成
- **WHEN** 完整构建工作流成功结束
- **THEN** 系统不触发 AltStore 源更新、自动提交或 PR 创建

### Requirement: 非移动端自动化与源码保护
系统 SHALL 保留 winget、依赖审查、Issue 检查、工作流清理与赞助同步，并且 MUST NOT 因 CI/CD 平台收敛而删除移动端源码和工程文件。

#### Scenario: 审查收敛后的自动化集合
- **WHEN** 维护者检查工作流与仓库目录
- **THEN** winget 和平台无关自动化仍可用
- **AND** Android、iOS 与 Fastlane 的源码或元数据文件仍保留在仓库中
