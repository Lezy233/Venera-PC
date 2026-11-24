# Tasks

## 1. 桌面完整构建与 Release

- [x] 1.1 精简 `.github/workflows/build.yml`，删除 Android/iOS inputs、secrets 与 jobs，保留四个桌面 jobs；用工作流静态测试验证手动调用只暴露桌面输入且不再引用移动签名。
- [x] 1.2 精简 `.github/workflows/main.yml` 的 Build 输入、artifact 下载与 Release 文件集合；用静态测试验证桌面资产和 winget 步骤保留，APK/IPA 不再被下载或发布。
- [x] 1.3 在 `.github/scripts/tests/` 增补或调整上述工作流契约测试，并运行对应 Python 测试确认通过；不得删除仅用于本地移动端能力校验的既有脚本测试。

## 2. PR 与质量门禁

- [x] 2.1 修改 `.github/workflows/pr_build.yml`，删除 Android job 及 `platform_gate` 的 Android 依赖、变量和文案；用静态测试验证 Windows 冒烟、启动检查和门禁汇总仍完整。
- [x] 2.2 修改 `.github/workflows/analyze.yml`，仅删除 `rhttp-ios`；用静态测试验证 `apple-directory-access`、`rhttp-native`、analyze、Flutter 测试与覆盖率步骤保留。
- [x] 2.3 运行受影响的工作流/脚本 Python 测试，并检查变更后的 YAML 可解析、job 依赖引用均存在。

## 3. 移动商店入口与维护文档

- [x] 3.1 删除 `.github/workflows/fastlane.yml` 和 `.github/workflows/update_alt_store.yml`；通过文件清单与差异检查确认移动端源码、`fastlane/`、AltStore 数据和更新脚本仍保留。
- [x] 3.2 更新构建与分发维护文档中对 CI/CD 平台、PR 检查和 Release 资产的现行描述，移除“自动化仍发布移动端”的说明；核对文档中的命令与工作流名称有效。
- [x] 3.3 检查 winget、依赖审查、Issue 检查、工作流清理和赞助同步未被本 change 修改，并运行相关现有脚本测试确认无回归。

## 4. 集成验证

- [x] 4.1 运行 `python3 -m unittest discover -s .github/scripts/tests -p "test_*.py"`，确认全部通过；运行 `git diff --check` 并检查只有预期工作流、测试和文档发生变化。
- [x] 4.2 按项目环境运行 `flutter analyze`，确认相对 50 项既有基线零新增；不得重新生成 `pubspec.lock`，并核对其无差异。
- [ ] 4.3 在 PR 中确认代码分析、Flutter 测试、Windows 冒烟与 `platform_gate` 通过，且不再出现 Android/iOS 检查；不通过实际打 tag 验证 Release，交付中列出下一次桌面 Release 的人工验收项。

## Workflow follow-up

- owner 验收通过后归档，并将 `distribution/desktop-ci-cd` 同步到正式 specs。
- 合并后由 owner 核对 GitHub 分支保护是否仍引用已移除的 Android 检查。
