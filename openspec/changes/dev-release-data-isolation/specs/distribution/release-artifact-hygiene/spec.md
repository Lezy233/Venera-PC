# Spec Delta

## Purpose

保证对外发布产物只包含程序与资源，不携带任何用户数据，并把干净环境首启列为发布验收条件。

## ADDED Requirements

### Requirement: 发布产物不得包含用户数据

macOS `.app`、Windows zip 与 Linux AppImage 的发布载荷 MUST NOT 包含 `appdata.json`、`implicitData.json`、`syncdata.json`、`sources` 目录、`history.db`、`favorites.db` 或 `local.db`；构建工作流 SHALL 在打包后自动扫描，命中即失败。

#### Scenario: 干净产物通过检查

- **WHEN** CI 构建并打包 macOS、Windows 或 Linux 产物
- **THEN** 洁净性检查扫描打包载荷并通过
- **AND** 检查失败时构建不会继续生成 Release

#### Scenario: 植入用户数据时检查失败

- **WHEN** 产物中被放入任一受禁的用户数据文件或目录
- **THEN** 检查脚本以非零状态退出
- **AND** 输出命中的具体路径

### Requirement: 干净环境首启验收

发布检查清单 SHALL 要求在全新 macOS 用户或清理过的沙盒容器中首次启动 Release，并确认没有标签、漫画源、历史与同步配置。

#### Scenario: 干净容器首启为空

- **WHEN** 维护者在全新用户/容器中首次启动 Release
- **THEN** 工作区没有既有标签
- **AND** 没有漫画源、历史或同步配置
- **AND** 启动日志显示的数据路径位于该用户/容器的干净目录

#### Scenario: 已有调试数据的机器需手动清理

- **WHEN** 机器上已有旧版调试数据
- **THEN** 发布文档提供备份与手动清理步骤
- **AND** 本 change 不自动删除这些数据
