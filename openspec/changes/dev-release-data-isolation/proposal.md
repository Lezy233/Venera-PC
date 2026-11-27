# Proposal

## Why

1.19.0 macOS Release 首次打开就出现多个工作区标签与漫画源。核对已发布 DMG：包内只有 `.app`、Flutter assets 与插件资源，**没有** `appdata.json`、`implicitData.json`、`sources/` 或数据库等用户数据，因此不是“把测试数据打包了”。

实际原因是数据目录共享：Release 与本地调试构建使用同一个 bundle id（`com.github.lezy233.veneranext`，为保留升级兼容性刻意未改），`App.dataPath` 由 `getApplicationSupportDirectory()` 解析到同一个 Application Support/沙盒容器，调试时导入的标签、漫画源和设置被 Release 原样读取。当前既没有开发/发布数据隔离，也没有启动日志暴露实际数据路径，发布包也没有“不得包含用户数据”的自动校验。

## What Changes

- 调试与 profile 构建改用隔离的数据子目录（release 路径下的 `dev/`），Release 继续使用既有路径，保持从 Venera-Next 升级时的数据兼容；不自动迁移、不复制调试数据。
- 启动日志记录实际数据目录、缓存目录与构建模式；文档给出定位与清理本地测试数据的命令。
- 新增发布产物洁净性检查：对 macOS `.app`、Windows zip、Linux AppImage 与 deb/rpm 载荷扫描用户数据文件名，发现即失败；接入构建工作流并用静态测试锁定。
- 发布清单增加“干净用户/沙盒容器首次启动”验收：不得出现任何标签、漫画源、历史或同步配置。
- 明确本 change 不迁移或删除任何既有用户数据；已存在的共享数据需要用户/开发者手动清理（文档提供步骤）。

## Capabilities

### New Capabilities

- `foundation/data-directory-isolation`: 规定 Release 与调试构建的数据目录边界、路径可观测性及升级兼容性。
- `distribution/release-artifact-hygiene`: 规定发布产物不得包含用户数据，以及干净环境首启验收。

### Modified Capabilities

无；现有数据目录、升级关系与同步协议不变。

## Impact

- 影响 `lib/foundation/app.dart` 的数据目录解析与测试；启动日志。
- 影响 `.github/scripts/` 新增产物检查脚本、`build.yml` 的 macOS/Windows/Linux 构建校验与对应 Python 测试。
- 影响发布/开发文档与 BACKLOG 的发布清单。
- 不改 bundle id、application id、数据目录名称、WebDAV 路径或 `pubspec.lock`。

## Out of Scope

- 不自动删除、移动或合并已有用户数据；不提供 Release 内“清空数据”入口。
- 不改变 Release 的数据目录以换取“干净首启”；升级兼容优先。
- 不引入新的存储后端、同步协议或账号体系。
- 不把测试数据隔离扩展到移动端。
