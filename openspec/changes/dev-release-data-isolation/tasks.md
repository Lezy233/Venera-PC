# Tasks

## 1. 诊断与契约确认

- [ ] 1.1 记录已发布 1.19.0 macOS DMG 的包内扫描结果（仅 `.app`/assets/插件资源，无用户数据），并确认 dev/release 共用 bundle id `com.github.lezy233.veneranext` 与同一 Application Support/沙盒容器；核对 `getApplicationSupportDirectory()` 在沙盒与非沙盒下的实际路径并写入交付说明。
- [ ] 1.2 明确 release 数据目录保持不变的兼容边界：不迁移、不改 bundle id、不新增重置入口；把本文档与任务作为验收依据。

## 2. 调试数据隔离

- [ ] 2.1 在数据目录解析处引入可测试的纯函数（basePath + isRelease → release 原路径 / debug-profile 的 `dev/` 子目录），`App.init` 用 `kReleaseMode` 选择并确保目录存在；不复制、不迁移、不删除任何既有数据。
- [ ] 2.2 增加路径选择单测：release 返回原路径；debug/profile 返回 `dev/`；两者互不影响；补测 `dev/` 自动创建。运行相关测试并确认现有全量测试不因测试进程落入 `dev/` 而回归。

## 3. 路径可观测与文档

- [ ] 3.1 启动日志记录实际 `dataPath`、`cachePath` 与构建模式（release/debug/profile）；确认不输出凭证或用户内容。
- [ ] 3.2 在开发/发布文档中补充：如何从日志定位数据路径、macOS 沙盒与非沙盒路径、如何备份并清理本地 `dev/` 测试数据、已有共享数据需手动清理一次。

## 4. 发布产物洁净性检查

- [ ] 4.1 新增 `.github/scripts/check_release_artifacts.py`：支持 `--app <dir>`、`--zip <file>`、`--dir <dir>`，拒绝 `appdata.json`、`implicitData.json`、`syncdata.json`、`sources/`、`history.db`、`favorites.db`、`local.db`，命中打印路径并退出 1。
- [ ] 4.2 为检查脚本补单元测试：干净目录/zip 通过；植入任一受禁文件/目录失败；zip 内命中失败；空目录不误报。
- [ ] 4.3 接入 `build.yml`：macOS 检查 `.app`，Windows 检查 zip，Linux 在 AppImage 生成后解包检查；新增工作流静态测试锁定三个平台都存在检查步骤与脚本路径。

## 5. 发布清单与验证

- [ ] 5.1 更新发布检查清单：在全新 macOS 用户或清理后的容器中首启 Release，确认无标签、漫画源、历史、同步配置；记录实际启动日志路径与截图/文字证据（截图不入库）。
- [ ] 5.2 用当前 1.19.0 产物回归洁净性脚本（应全部通过）；用一次真实 debug 启动验证写入 `dev/`、Release 数据目录 mtime/hash 不变；记录命令与结果。
- [ ] 5.3 编写 delivery.md：列出 bundle id/路径结论、改动文件、测试命令与计数、产物扫描结果、干净环境验收步骤、已知局限（既有数据不自动清理）；architect 复核、owner 验收后再提交归档。

## Workflow follow-up

- owner 验收通过后归档，并把两个新 capability 同步到正式 specs。
- 下一版本发布前必须按 5.1 在干净用户/容器执行一次首启验收；若发现新数据来源，先停下排查而不是清理用户数据。
