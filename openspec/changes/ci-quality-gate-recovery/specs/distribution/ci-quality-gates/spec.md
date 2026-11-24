# Spec Delta

## Purpose

确保桌面项目能够在没有本机缓存的干净环境中重复恢复依赖并完整执行质量门禁，使 CI 结果真实反映当前源码而不是历史缓存或提前跳过的步骤。

## ADDED Requirements

### Requirement: 干净环境可恢复锁定依赖

系统 SHALL 在干净源码副本和空 pub 缓存中仅使用仓库内源码、公开包源及可访问的公开依赖完成锁定依赖解析，MUST NOT 依赖开发者本机已有缓存。

#### Scenario: 冷缓存解析依赖

- **WHEN** 维护者在干净源码副本中使用空 pub 缓存执行强制锁文件依赖解析
- **THEN** 所有依赖成功解析且应用依赖版本保持锁定
- **AND** 过程不访问已失效的 `CyrilPeng/webdav_client` 仓库

### Requirement: 质量工作流使用受支持的 macOS 环境

macOS 目录授权检查 SHALL 在 GitHub Actions 当前支持的 runner 上执行，并与项目桌面 macOS 构建使用一致的系统主版本。

#### Scenario: 触发质量工作流

- **WHEN** 推送、PR 或完整构建调用质量工作流
- **THEN** GitHub Actions 能接受并启动 macOS 目录授权 job
- **AND** 该 job 不因 runner 配置不受支持而失败

### Requirement: 质量门禁完整执行

质量工作流 SHALL 在依赖恢复后实际执行结构检查、静态分析、Flutter 测试与覆盖率步骤，MUST NOT 通过删除检查或豁免既有违规获得成功结果。

#### Scenario: 当前源码执行质量门禁

- **WHEN** 维护者本地或 CI 按工作流顺序执行质量检查
- **THEN** 结构检查无受限 import 或 feature 入口违规
- **AND** 静态分析相对既有 50 项基线零新增
- **AND** Flutter 测试与覆盖率命令实际运行并成功结束
