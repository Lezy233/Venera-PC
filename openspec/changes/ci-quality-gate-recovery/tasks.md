# Tasks

## 1. 固定 WebDAV 客户端供应

- [ ] 1.1 从锁定提交对应的本机缓存提取 `webdav_client` 1.2.2 的运行时代码、pubspec、README、CHANGELOG 与 BSD 许可证到 `packages/webdav_client/`，记录来源提交；逐文件核对缓存副本且不包含 `.git/`、示例工程、图片或真实服务器测试。
- [ ] 1.2 将根 `pubspec.yaml` 改为 path 依赖，仅最小编辑锁文件中的 WebDAV source/description 并保留 1.2.2；新增静态回归测试验证本地来源，运行对应 Python 测试并确认其他锁文件条目无差异。
- [ ] 1.3 在临时干净克隆中使用空 `PUB_CACHE` 运行 `flutter pub get --enforce-lockfile`，确认成功、没有访问失效仓库且锁文件无变化，随后清理临时目录。

## 2. 恢复模块依赖边界

- [ ] 2.1 按 design 移动工作区记录、页面/导航 scope 与拖拽 payload，更新所有生产及测试 import；运行相关工作区 Flutter 测试和结构检查，确认这些旧路径及其受限 import 全部消失。
- [ ] 2.2 将 desktop chrome、top bar 与 bookshelf workspace 移到 components，更新生产及测试引用；运行桌面 chrome、窗口和书架相关 Flutter 测试及结构检查，确认没有遗漏旧路径。
- [ ] 2.3 将 WebDAV 注册能力分离到 feature 公共 API，设置页改用 `WebDavLibraryScope` 获取服务，调整测试宿主并覆盖用途切换注册；运行 remote storage 与 WebDAV library 相关测试。
- [ ] 2.4 将 app_shell 与 favorites 对 search 实现文件的四处引用切换到 `features/search/search.dart`；运行 search/favorites 相关测试及完整 `check_structure_imports.py`，确认 25 条受限 import 和 4 条入口违规全部清零且检查规则未改。

## 3. 恢复受支持的 CI 环境

- [ ] 3.1 将 `apple-directory-access` runner 改为与桌面构建一致的 `macos-15`，补充工作流静态测试；运行受影响 Python 测试并解析 YAML，确认质量 job 与步骤集合未缩减。

## 4. 集成与 GitHub 验收

- [ ] 4.1 格式化本次修改的 Dart 文件，运行全部 `.github/scripts/tests/` Python 测试、`git diff --check` 和旧 import 路径搜索，确认无新增无关文件或检查豁免。
- [ ] 4.2 准备既有 Linux 原生测试库并运行 `flutter test --coverage`，确认测试与覆盖率命令实际完成；运行 `flutter analyze`，记录相对既有 50 项基线零新增。
- [ ] 4.3 通过普通提交和 PR 核对 macOS 目录授权、analyze、Flutter 测试与覆盖率、Windows 冒烟及 `platform_gate` 全部通过；不创建 Release tag，并在交付中保留下一次桌面 Release 的人工验收项。

## Workflow follow-up

- owner 验收通过后归档，并将两个新 capability 同步到正式 specs。
- 使用本 change 的本地与 PR 证据复核 `desktop-only-ci-cd` 剩余的 4.1、4.3，不在证据不足时勾选。
