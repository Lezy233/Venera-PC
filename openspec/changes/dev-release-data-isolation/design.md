# Design

## Context

1.19.0 macOS DMG 已核对：包内只有 `VeneraPC.app`、Flutter assets 与插件资源，没有 `appdata.json`、`implicitData.json`、`sources/` 或数据库；问题不在打包。

`App.init` 使用 `getApplicationSupportDirectory()` 作为数据目录。macOS 上该路径由 `NSSearchPath(NSApplicationSupportDirectory)` 加 bundle id 组成；沙盒内是 `~/Library/Containers/com.github.lezy233.veneranext/Data/Library/Application Support/com.github.lezy233.veneranext`，非沙盒是 `~/Library/Application Support/com.github.lezy233.veneranext`。Debug 与 Release 使用同一 bundle id（rebrand 为保留升级兼容刻意未改），因此本地调试导入的标签、漫画源与设置会出现在 Release 中。

当前没有开发/发布数据目录隔离，也没有启动日志暴露实际路径，发布构建也没有“包内不得含用户数据”的自动检查。

## Goals / Non-Goals

**Goals:**

- 让本地调试（debug/profile）不再写入 Release 数据目录，避免后续测试数据污染发布体验。
- 保持 Release 数据目录与 1.19.0 完全一致，保留从 Venera-Next 升级的数据兼容。
- 让实际数据路径在启动日志与文档中可查，支持定位/清理本地测试数据。
- 用自动检查阻止任何用户数据文件进入 macOS/Windows/Linux 发布产物。
- 把“干净环境首启为空”列为发布验收项。

**Non-Goals:**

- 不自动删除、迁移或合并任何既有用户数据。
- 不为 Release 更换数据目录或 bundle id。
- 不提供 Release 内清空/重置数据入口。
- 不改变同步协议、数据格式或移动端数据路径。

## Decisions

### 1. Release 数据目录保持不变

Release 继续使用 `getApplicationSupportDirectory()`；bundle id、数据目录名、沙盒容器与升级读取关系均不变。选择兼容而不是“全新目录”，是因为 1.19.0 已经发布，改名/换路径会让既有用户的收藏、历史、设置与同步配置失联；本 change 不承担数据迁移风险。

### 2. 非 Release 构建使用 `dev/` 子目录

在数据目录解析处引入可测试的纯函数：`resolveAppDataPath(basePath, {required bool isRelease})`。Release 返回 `basePath`，debug/profile 返回 `basePath/dev` 并确保目录存在。`App.init` 用 `kReleaseMode` 选择；不自动复制或迁移任何已有数据。

测试（flutter test）属于非 Release，若有测试直接走 `App.init` 会落到 `dev/`；现有测试不依赖真实 Application Support，需在实现时核对并保持测试隔离。

### 3. 启动日志暴露数据路径

启动时记录实际 `dataPath`、`cachePath` 与构建模式（release/debug/profile）。日志走现有 `Log`，不新增界面；文档给出读取日志与清理 `dev/` 的命令。路径属于本地诊断信息，不涉及凭证。

### 4. 发布产物洁净性由脚本 + 工作流静态测试共同保证

新增 `.github/scripts/check_release_artifacts.py`：
- `--app <dir>`：遍历 macOS `.app`；
- `--zip <file>`：检查 Windows zip 条目；
- `--dir <dir>`：检查已解包的 AppImage 目录。

禁止的用户数据名：`appdata.json`、`implicitData.json`、`syncdata.json`、`sources`（目录）、`history.db`、`favorites.db`、`local.db`。命中即退出 1 并打印路径。脚本覆盖单元测试（干净目录通过、植入文件失败、zip 失败）。

工作流：macOS 在 `flutter build macos --release` 后检查 `.app`；Windows 在生成 zip 后检查 zip；Linux 在 AppImage 生成后 `--appimage-extract` 再检查。`test_release_artifact_workflow.py` 锁定三个工作流都存在检查步骤，防止以后新增平台漏检。

### 5. 干净环境首启是发布验收项

Release 前的检查清单增加：在全新 macOS 用户或删除/隔离 `~/Library/Containers/com.github.lezy233.veneranext` 后首次启动，必须没有标签、漫画源、历史、同步配置。文档同时说明：已有调试数据的机器需要手动清理一次，本 change 不会代为删除。

## Risks / Trade-offs

- [调试数据与 Release 数据被隔离后，开发者原有调试数据不再自动出现在 debug 构建] → 保留原路径数据供 Release 使用；如需继续使用，可手动复制到 `dev/`；文档说明。
- [现有被污染的 Release 数据不会自动消失] → 发布验收要求干净容器/用户；文档给出手动清理命令与备份提示。
- [沙盒/非沙盒路径不同导致日志与实际容器不一致] → 启动日志输出实际解析路径，验收以日志为准。
- [产物检查误报合法资源] → 仅匹配明确的用户数据文件名/目录，并先用当前 1.19.0 产物做回归；新增资源如需同名必须显式评审。
- [测试环境落入 dev/ 目录] → 纯函数单测 + 现有测试不读真实 Application Support；实现后跑全量测试确认。

## Migration Plan

1. 合入后：Release 路径、数据格式、升级读取全部不变；debug/profile 改写到 `dev/`。
2. 开发者按文档清理一次旧的共享测试数据（备份后删除 Application Support/容器内数据）。
3. 下一次 Release 按清单在干净用户/容器验证首启为空；无需用户迁移。
