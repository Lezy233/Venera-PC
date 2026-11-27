# Spec Delta

## Purpose

界定 Release 与调试构建的数据目录边界：升级兼容的 Release 路径保持不变，调试数据进入独立子目录，并让实际路径可观测。

## ADDED Requirements

### Requirement: Release 数据目录保持升级兼容

Release 构建 SHALL 继续使用 `getApplicationSupportDirectory()` 返回的既有数据目录；bundle id、application id、数据目录名称与沙盒容器 MUST NOT 改变，既有收藏、历史、设置与同步配置 MUST 继续从原位置读取。

#### Scenario: Release 首次启动沿用既有目录

- **WHEN** 1.19.0 之后的 Release 构建启动
- **THEN** 实际数据目录与 1.19.0 相同
- **AND** 原目录中的收藏、历史、设置与同步配置可被读取，不触发数据迁移

### Requirement: 非 Release 构建使用隔离数据目录

debug 与 profile 构建 SHALL 在既有数据目录下使用 `dev/` 子目录读写应用数据；MUST NOT 写入 Release 数据目录；MUST NOT 自动复制、迁移或清空 Release 数据。

#### Scenario: 调试启动写入 dev 子目录

- **WHEN** 开发者在 debug/profile 构建中导入漫画源或创建标签
- **THEN** 数据写入 `<既有数据目录>/dev/`
- **AND** Release 数据目录中的文件内容与修改时间不变

#### Scenario: 清理调试数据不影响 Release

- **WHEN** 开发者删除 `dev/` 子目录
- **THEN** Release 数据目录保持完整
- **AND** 下一次 debug/profile 启动从空的 `dev/` 开始

### Requirement: 实际数据路径可观测

启动 SHALL 在日志中记录实际 `dataPath`、`cachePath` 与构建模式；开发文档 SHALL 说明如何读取该日志、定位以及清理本地 `dev/` 测试数据。

#### Scenario: 启动日志包含路径

- **WHEN** 应用启动并完成路径解析
- **THEN** 日志包含实际 dataPath、cachePath 以及 release/debug/profile 标记
- **AND** 文档描述的路径与该日志一致

### Requirement: 不自动处理既有数据

本 change MUST NOT 删除、移动、合并或改写现有用户数据；对已被调试数据污染的安装，SHALL 由文档指导用户备份后手动清理。

#### Scenario: 既有共享数据保留

- **WHEN** 升级到包含本 change 的版本
- **THEN** 既有数据目录与文件保持原样
- **AND** 不出现自动迁移、重命名或清理
