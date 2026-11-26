# Tasks

## 1. Flutter 展示名与当前项目入口

- [x] 1.1 将应用标题、关于/退出菜单、应用描述和 User-Agent 改为约定的 Venera-PC 形式，同步 `.tl` 源文案与 `assets/translation.json` 的 zh_CN、zh_TW；用相关 Dart/翻译测试确认无旧可见文案或缺失词条。
- [x] 1.2 将应用内 GitHub 链接和稳定版/预发布更新 API 切换到 `Lezy233/Venera-PC`；更新并运行 `ApplicationUpdateService` 与相关 UI 测试，验证请求 URL 和更新选择行为。
- [x] 1.3 保持 `venera_next`、application ID、数据目录、WebDAV 路径和 MethodChannel 不变；运行应用数据路径、同步配置和原生通道相关回归测试确认兼容边界。

## 2. Windows 可执行文件、安装器与升级

- [x] 2.1 更新 Windows CMake、Runner 元数据、窗口标题、Inno 显示名/exe/输出名及 `windows/build.py` 为 `VeneraPC` 文件形式；运行 Windows 构建与安装器脚本测试，确认 AppId、ProductCode 和卸载升级关系未变。
- [x] 2.2 同步 Windows 启动测试、`.github/scripts/test_windows_startup.ps1`、构建工作流资产校验与上传路径；运行对应 Python/原生测试，确认 zip 内包含 `VeneraPC.exe` 且启动诊断仍有效。
- [x] 2.3 核对 `lib/foundation/app.dart` 与 Windows 启动日志的数据目录仍为既有值，并运行 Windows 数据迁移回归测试证明没有新增迁移或路径切换。

## 3. macOS bundle 与 DMG

- [x] 3.1 将 macOS app 文件名改为 `VeneraPC.app`、显示名改为 `Venera-PC`，同步 Xcode project、scheme、窗口和构建工作流 DMG 路径；用工程静态检查及 macOS CI 构建验证所有引用一致。
- [x] 3.2 保持 macOS application/bundle ID 与 RunnerTests ID 不变，运行 `swift test --package-path apple` 和现有 macOS 相关测试，确认目录授权与测试宿主配置无回归。

## 4. Linux 命令、系统包与 AppImage

- [x] 4.1 将 Linux 二进制和新命令改为 `venera-pc`、窗口及 desktop 显示名改为 `Venera-PC`，保持 GTK application ID 不变；用 Linux 构建和静态检查确认启动配置正确。
  - 2026-11-26：7.3 冷启动走查发现 `linux/my_application.cc` 的 header bar/title 仍是旧名 `VeneraNext-Dev`（rebase 时遗漏），已改为与 Windows/macOS 一致的 `Venera-PC-Dev`，并在 `test_product_identity.py` 新增桌面窗口标题契约测试（Linux/Windows/macOS/MaterialApp 四处一致、禁止 `VeneraNext-Dev`）。Linux debug 重建成功；窗口标题的 GUI 复验待 owner 或获批的 Xvfb 运行。
- [x] 4.2 更新 DEB/RPM/Arch/AppImage 打包，使新包同时提供 `venera-pc` 与既有 `venera-next` 命令，AppImage 改为 `VeneraPC-*`；运行对应 Python 测试验证系统包名、安装目录、图标名和包文件名保持兼容。
- [x] 4.3 运行 AppImage runtime/relocate/smoke 相关测试及 Linux 实际构建，检查新旧命令均能启动同一应用，且桌面入口显示 Venera-PC。

## 5. 发布元数据与仓库 URL

- [x] 5.1 更新 `pubspec.yaml` homepage/Arch URL、winget 生成与提交脚本、Release/winget 工作流和 CDN 为 `Lezy233/Venera-PC`；运行相关 Python 测试验证当前项目链接与新桌面资产名一致。
- [x] 5.2 保留 winget `CyrilPeng.VeneraNext` PackageIdentifier、manifest 目录和升级 ProductCode，仅更新展示元数据；生成测试 manifest 并核对安装命令、下载 URL、显示名与兼容 ID。
- [x] 5.3 对照变更前 `pubspec.yaml` 检查全部 git dependency URL 和 ref 未改变，并确认 `pubspec.lock` 零差异；不得通过 pub add/upgrade 完成更名。

## 6. README 与项目上下文

- [x] 6.1 同步重写 `README.md` 与 `README.en.md` 的标题、独立桌面定位、功能介绍和安装入口，移除旧项目宣传链接、fork 叙述、旧截图与移动安装/FAQ；用文档静态检查确认中英文平台与资产说明一致。
- [x] 6.2 保留 GPL-3.0、必要版权/许可声明和历史 CHANGELOG，不新增未经授权的截图或赞助地址；运行赞助 README 生成器检查和相关测试，确认自动同步不会失败或写回旧叙述。
- [x] 6.3 更新 `openspec/config.yaml`、`AGENTS.md`、设计契约及现行开发/分发文档中的产品名、仓库 URL 和更名后命令；检查历史归档未被批量改写，移动布局继续工作的约束仍保留。

## 7. 集成与真实场景验证

- [x] 7.1 运行 `python3 -m unittest discover -s .github/scripts/tests -p "test_*.py"`、相关 Dart 测试及完整 `flutter test`，确认无失败和非既有跳过；运行 `git diff --check`。
- [x] 7.2 按项目环境运行 `flutter analyze`，确认相对 50 项既有基线零新增；核对 `pubspec.lock`、依赖 URL、application ID、数据目录和升级标识均无未授权变化。
- [x] 7.3 在 Linux 正常入口冷启动并走查窗口、关于和菜单的 Venera-PC 展示；通过 CI 验证 Windows/macOS 构建与 Windows 安装启动，确认桌面 Release 只引用新资产名且中文翻译无回退。
  - 2026-11-26：已触发 CI `构建`（Windows + macOS，Linux 关闭）验证安装包/启动与资产名；Linux 冷启动走查发现并修复窗口标题旧名（见 4.1）；关于/菜单文案由 `test_product_identity.py` 与既有 widget 测试覆盖。Linux GUI 目视复验尚未完成（本会话 Xvfb 命令被沙箱拒绝），待 owner 在本机启动确认或授权重试。
  - 2026-11-26 追加：首次 `构建` run 45673869115 的 Build_MacOS 在“串行化 Rustup 安装操作”失败（runner 的 rustup 不在 `$HOME/.cargo/bin`，BSD install 目标目录不存在，exit 71），与产品代码无关；已改为 `$RUNNER_TEMP/rustup-shim` 并写入 `GITHUB_PATH`，新增静态测试；待重跑 Windows + macOS。
  - 2026-11-27：owner 在 niri 下目视确认 Linux 窗口标题为 `Venera-PC-Dev`；关于/菜单文案由 `test_product_identity.py` 与既有 widget 测试覆盖，7.3 闭合。
  - 2026-11-27：CI 证据齐备。`构建` run 45675463749（`cd560df`）success：Build_Windows 的「验证 Windows 安装、无头命令与实际启动」「校验 Windows 构建产物」均成功，Build_MacOS 的「构建 Flutter macOS 应用」「创建 DMG」成功；`代码分析` run 45675465187 全绿。Linux 侧：debug 构建成功、桌面窗口标题契约测试通过（Linux/Windows/macOS/MaterialApp 一致，禁止 `VeneraNext-Dev`）；因 owner 使用 Wayland+niri 且不允许本地窗口截图，窗口目视走查改以静态契约 + 构建成功替代，待 owner 确认后勾选。关于/菜单文案由 `test_product_identity.py` 与既有 widget 测试覆盖。
- [x] 7.4 用既有用户数据副本验证升级前后收藏、历史、设置和同步配置仍从原位置读取；首次新仓库 Release 前不伪造更新成功，交付中明确真实更新 API 与下载链接的发布后验收项。

## Workflow follow-up

- 本 change 必须在 `desktop-only-ci-cd` 完成后实施；owner 验收通过后再归档并同步 `distribution/product-identity` 正式 spec。
- 首次 Venera-PC Release 发布后，由 owner 验证应用更新检查、桌面资产下载、winget manifest 与 Linux 新旧命令。
