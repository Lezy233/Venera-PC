# distribution/ci-quality-gates Specification

## Purpose

确保桌面项目能够在没有本机缓存的干净环境中重复恢复依赖并完整执行质量门禁，使 CI 结果真实反映当前源码而不是历史缓存或提前跳过的步骤。

## Requirements

### Requirement: 干净环境可恢复锁定依赖

系统 SHALL 在干净源码副本和空 pub 缓存中仅使用仓库内源码、公开包源及可访问的公开依赖完成锁定依赖解析，MUST NOT 依赖开发者本机已有缓存。

#### Scenario: 冷缓存解析依赖

- **WHEN** 维护者在干净源码副本中使用空 pub 缓存执行强制锁文件依赖解析
- **THEN** 所有依赖成功解析且应用依赖版本保持锁定
- **AND** 过程不访问任何已失效的 `CyrilPeng` 仓库
- **AND** 所有 git 依赖保持锁定 ref、版本与源码内容不变

#### Scenario: 失效 git 依赖迁移

- **WHEN** 一个已锁定 git 依赖的远端仓库不可访问
- **THEN** 该依赖 SHALL 迁移到同一 commit 可达的来源，或改为仓库内 vendored 源码
- **AND** 迁移 MUST NOT 改变 ref、锁定版本或源码内容

### Requirement: 质量工作流使用受支持的 macOS 环境

macOS 目录授权检查 SHALL 在 GitHub Actions 当前支持的 runner 上执行，并与项目桌面 macOS 构建使用一致的系统主版本。

#### Scenario: 触发质量工作流

- **WHEN** 推送、PR 或完整构建调用质量工作流
- **THEN** GitHub Actions 能接受并启动 macOS 目录授权 job
- **AND** 该 job 不因 runner 配置不受支持而失败

### Requirement: 锁定依赖在干净环境可编译

质量工作流 SHALL 在干净 pub 缓存中让锁定的依赖源码可编译。若锁定版本含已知编译缺陷，工作流 MAY 在 `pub get` 后应用仓库内可审查、幂等的补丁，但 MUST NOT 升级版本、修改锁文件或静默跳过补丁失败。

#### Scenario: 干净环境编译锁定依赖

- **WHEN** CI 在空 pub 缓存中解析锁定依赖并编译应用或测试
- **THEN** 依赖源码可编译，已知缺陷由仓库内脚本确定性修复
- **AND** 补丁缺失或源码形状变化时工作流失败并给出可诊断信息

### Requirement: 质量门禁完整执行

质量工作流 SHALL 在依赖恢复后实际执行结构检查、架构 inventory 检查、静态分析、Flutter 测试与覆盖率步骤，MUST NOT 通过删除检查、扩大豁免范围或把既有违规加入白名单获得成功结果。

#### Scenario: 当前源码执行质量门禁

- **WHEN** 维护者本地或 CI 按工作流顺序执行质量检查
- **THEN** 结构检查无受限 import 或 feature 入口违规
- **AND** 架构 inventory 中每个 `lib/` 库文件恰有一个分类，且没有未登记的新 feature 依赖边
- **AND** `flutter analyze --fatal-infos --fatal-warnings` 通过
- **AND** Flutter 测试与覆盖率命令实际运行，失败项均被归类为可复现的环境限制或已修复的仓库缺陷

### Requirement: vendored 第三方源码不属于本包检查范围

静态分析与 Dart 格式检查 SHALL 允许排除仓库内 vendored 的第三方源码目录，MUST 仅限该目录，且 MUST NOT 缩减本仓代码、测试、工具或其他本地 package 的检查范围，也不得放宽 lint 规则。

#### Scenario: 检查 vendored 依赖

- **WHEN** 维护者或 CI 对仓库运行静态分析与格式检查
- **THEN** `packages/webdav_client/` 不被当作本包代码报告问题
- **AND** 本仓其他目录仍按原有规则检查
- **AND** 排除范围由静态测试锁定，不能被扩大为通用豁免
