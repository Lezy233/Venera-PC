# Spec Delta

## Purpose

为独立的 Venera-PC 桌面漫画阅读器定义一致的对外产品身份、仓库入口与发布命名，并确保品牌更名不会改变用户数据位置或既有安装升级关系。

## ADDED Requirements

### Requirement: 桌面产品展示身份
系统 SHALL 在用户可见的窗口标题、关于与退出菜单、应用描述及桌面环境元数据中使用 `Venera-PC`，并 SHALL 为变更文案提供 zh_CN 与 zh_TW 翻译。

#### Scenario: 查看应用与桌面入口
- **WHEN** 用户启动桌面应用或查看窗口、关于页面、应用菜单和系统应用入口
- **THEN** 产品显示名为 `Venera-PC`
- **AND** 当前产品的用户可见位置不再展示 `VeneraNext` 或 `VeneraNext-Dev`

#### Scenario: 切换中文语言
- **WHEN** 用户使用 zh_CN 或 zh_TW 界面
- **THEN** 更名的关于、退出和应用描述文案具有对应翻译
- **AND** 不出现因缺少词条而残留的旧产品名

### Requirement: 桌面可执行文件与发布资产命名
系统 SHALL 使用 `VeneraPC` 作为不包含空格的对外文件名品牌形式，并 SHALL 让构建校验、打包和发布流程使用同一组新名称。

#### Scenario: 构建 Windows 与 macOS 资产
- **WHEN** 桌面构建生成 Windows 或 macOS 发布产物
- **THEN** Windows 可执行文件、安装包和便携包使用 `VeneraPC` 名称
- **AND** macOS app bundle 与 DMG 使用 `VeneraPC` 文件名，同时产品显示名保持 `Venera-PC`

#### Scenario: 构建 Linux 资产
- **WHEN** 桌面构建生成 AppImage 和系统软件包
- **THEN** AppImage 使用 `VeneraPC` 文件名
- **AND** DEB、RPM、Arch 文件继续遵循保留的系统包名与包管理命名规则

### Requirement: 当前项目仓库入口
系统 SHALL 将应用更新检查、应用内项目链接、项目主页和当前项目发布元数据指向 `https://github.com/Lezy233/Venera-PC` 及其对应 API/Release 地址。

#### Scenario: 检查应用更新
- **WHEN** 应用检查稳定版或预发布版本更新
- **THEN** 请求发送至 `Lezy233/Venera-PC` 的 GitHub Releases API
- **AND** 更新结果来自当前项目而非旧仓库

#### Scenario: 使用项目与发布链接
- **WHEN** 用户或发布工具打开主页、下载、winget、CDN 等项目链接
- **THEN** 链接指向 `Lezy233/Venera-PC`
- **AND** 第三方依赖的上游仓库地址不因该规则被改写

### Requirement: 独立桌面项目文档
中英文 README SHALL 将项目描述为 Venera-PC 桌面漫画阅读器，并且 MUST NOT 继续以 fork、上游分支或 Android/iOS 安装包作为当前项目的发布说明。

#### Scenario: 阅读项目介绍与安装说明
- **WHEN** 用户打开中文或英文 README
- **THEN** 用户看到 Venera-PC 的独立项目定位和 Windows、macOS、Linux 安装入口
- **AND** 当前项目的 fork 叙述、旧仓库宣传徽章及 Android/iOS 安装说明不再出现

#### Scenario: 查阅许可与历史
- **WHEN** 用户继续查阅许可或历史版本记录
- **THEN** GPL-3.0 许可及必要版权/许可声明仍保留
- **AND** 历史 CHANGELOG 不被更名操作重写

### Requirement: 内部与升级兼容标识
系统 MUST 保持 Dart package、application/bundle ID、用户数据路径、WebDAV 默认路径、MethodChannel、winget PackageIdentifier、Inno 升级标识和 Linux 系统包名不变。

#### Scenario: 既有用户升级安装
- **WHEN** 既有用户安装更名后的版本或启动应用
- **THEN** 系统沿用既有应用身份、数据目录和包管理升级关系
- **AND** 不要求用户迁移收藏、历史、设置或同步目录

#### Scenario: 使用既有 Linux 命令入口
- **WHEN** 用户或脚本在更名后调用既有 `venera-next` 命令
- **THEN** 系统通过兼容入口继续启动应用
- **AND** 新的 `venera-pc` 命令也可启动同一应用
