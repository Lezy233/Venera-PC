# Proposal

## Why

GitHub 仓库已经更名为 `Lezy233/Venera-PC`，但应用界面、原生桌面元数据、发布脚本和中英文 README 仍展示 VeneraNext，并保留旧仓库及 fork 叙述。需要建立统一的 Venera-PC 对外身份，同时保护现有用户数据、安装升级和扩展依赖的兼容性。

## What Changes

- 将窗口标题、关于/退出菜单、应用描述和桌面环境显示名统一为 `Venera-PC`，补齐 `.tl` 的 zh_CN、zh_TW 翻译。
- 将适合对外文件名的品牌形式统一为 `VeneraPC`：Windows 可执行文件与安装/便携资产、macOS app/DMG、Linux AppImage 等按现有命名风格更名，并同步构建校验。
- 将项目主页、应用内仓库入口、应用更新 API、Release 下载、winget 和 CDN 等当前项目 URL 统一到 `https://github.com/Lezy233/Venera-PC`。
- 重写中英文 README 的项目定位，删除 fork/上游延续叙述、旧项目宣传链接与移动端安装说明，只保留桌面平台下载和使用入口。
- 同步 `openspec/config.yaml` 的项目名称、独立项目定位和仓库上下文；继续保留移动布局约束直至另行决策。
- 更新受产品名、资产名或仓库 URL 约束的测试与维护文档。
- **BREAKING（外部文件命名）**：新构建的部分可执行文件和 Release 资产不再使用 VeneraNext 名称；系统包名与升级标识保持兼容。

## Capabilities

### New Capabilities

- `distribution/product-identity`: 规定 Venera-PC 的对外展示、仓库与发布命名，以及更名时必须保持不变的数据、应用和升级兼容标识。

### Modified Capabilities

无；现有正式 specs 未覆盖产品身份与分发命名。

## Impact

- 影响 Flutter 应用标题、桌面菜单、关于信息、应用更新服务及翻译资产。
- 影响 Windows、macOS、Linux 原生显示/可执行文件配置，以及 DEB/RPM/Arch/AppImage/DMG/winget 的展示或下载元数据。
- 影响 `.github/workflows/` 和 `.github/scripts/` 中的仓库 URL、资产名校验与对应测试。
- 影响 `README.md`、`README.en.md`、`pubspec.yaml`、OpenSpec 项目上下文和现行开发/分发文档。
- 不重新生成 `pubspec.lock`，不更改依赖版本或 git 依赖来源。

## Out of Scope

- 不修改 Dart package `venera_next` 或批量改写其 import。
- 不修改 application/bundle ID、Windows 公司/产品数据目录、WebDAV 默认路径、MethodChannel 名称。
- 不修改 winget PackageIdentifier、Inno Setup AppId/ProductCode、DEB/RPM/Arch 系统包名；不开展应用数据迁移。
- 不删除 Android/iOS 源码，不改变移动端本地能力；CI/CD 收敛由 `desktop-only-ci-cd` 负责。
- 不重写 CHANGELOG 的历史版本内容，不修改历史 Release，不删除 LICENSE 或依法需要保留的版权/许可声明。
- 不重新设计 logo、图标或界面视觉，不更改赞助者数据及自动同步规则。
