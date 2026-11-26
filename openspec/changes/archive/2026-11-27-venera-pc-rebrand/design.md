# Design

## Context

产品名目前分散在 Flutter 标题与菜单、翻译、三套桌面原生工程、Linux/Windows 打包脚本、winget manifest、应用更新 API 和中英文文档中。GitHub 仓库已经更名为 `Lezy233/Venera-PC`，因此新链接可以直接确定，无需等待仓库迁移。

本 change 依赖 `desktop-only-ci-cd` 先完成，使 Release 与工作流更名只需处理桌面资产。行为规范见 `specs/distribution/product-identity/spec.md`。

## Goals / Non-Goals

**Goals:**

- 建立明确的显示名、文件名、仓库 URL 和兼容标识边界，避免全局替换。
- 让构建脚本、安装器、Release、应用更新与 README 使用同一当前项目身份。
- 在修改资产名称的同时保留已有安装升级关系、用户数据和既有 Linux 命令入口。

**Non-Goals:**

- 不引入跨语言名称生成系统，不重写打包架构。
- 不迁移数据，不更换应用 ID，不建立新的 winget 包或 Linux 系统包。
- 不为 README 臆造新的赞助收款地址、徽章或截图，不重写历史资料。

## Decisions

### 1. 固定四种名称形式及用途

| 类型 | 取值 | 用途 |
|---|---|---|
| 产品显示名 | `Venera-PC` | 窗口、菜单、关于、桌面入口、README、包描述 |
| 文件名品牌 | `VeneraPC` | Windows exe/zip/installer、macOS app/DMG、AppImage |
| Linux 命令 | `venera-pc` | 新桌面入口和 `/usr/bin` 命令 |
| 当前仓库 | `https://github.com/Lezy233/Venera-PC` | 项目主页、API、Release、CDN 和分发元数据 |

开发窗口保留现有 `-Dev` 语义，显示为 `Venera-PC-Dev`。网络 User-Agent 仅替换产品 token，版本格式不变。

### 2. 对外文件更名，兼容标识原样保留

Windows 将 `BINARY_NAME`、exe 文件名、安装器显示/输出名和构建校验切换到新名称；Inno AppId、ProductCode、winget PackageIdentifier 与 `lib/foundation/app.dart` 的数据目录常量不变。Windows 启动日志目录属于数据路径，也保持旧值。

macOS 使用 `VeneraPC.app` 作为 bundle 文件名，并将用户可见名称设置为 `Venera-PC`；`PRODUCT_BUNDLE_IDENTIFIER` 及测试 bundle ID 不变。同步 Xcode 工程引用、scheme、DMG 创建和上传路径。

Linux 将实际二进制与新命令设为 `venera-pc`，GTK application ID 不变。DEB/RPM/Arch 的 package name、安装目录、图标资源名和包文件名保持 `venera-next` 体系；同时提供 `venera-pc` 与既有 `venera-next` 命令入口。AppImage 对外文件改用 `VeneraPC`，内部兼容路径不被无差别替换。

Dart package 继续为 `venera_next`，所有 `package:venera_next/...` import 保持不变。

### 3. 仓库 URL 只替换“当前项目”引用

`pubspec.yaml` 的 homepage/Arch URL、应用内 GitHub 入口、应用更新 API、工作流 CDN、winget 下载与 manifest URL 改为新仓库。winget 的展示 publisher/author 和产品描述同步为当前项目，但 PackageIdentifier、manifest 目录与升级标识不变。

`pubspec.yaml` 中指向 CyrilPeng、venera-app 等仓库的 git dependencies 是依赖来源，不是本项目主页，必须保留。历史 changelog、历史归档和第三方许可也不按名称替换。

### 4. README 做中英文同步的现行文档重写

两份 README 保留语言切换、项目声明、桌面功能与使用文档入口，重写标题、介绍、功能分类和安装下载。删除旧仓库徽章、Trendshift、Star History、旧截图、fork/本分支叙述、Android/iOS 安装与移动专属 FAQ。

不添加未经 owner 提供的新截图或赞助地址；若保留赞助自动同步占位标记，必须运行生成脚本检查，确保 `sponsors.yml` 不会因 README 重写而失败或写回旧叙述。

### 5. 项目上下文与测试同步

`openspec/config.yaml` 和 `AGENTS.md` 的现行项目介绍改为 Venera-PC 独立桌面项目；移动布局继续工作的约束不变。设计契约与开发/分发文档只更新现行名称和命令，不改写历史验收证据。

测试按层覆盖：Dart 测试验证更新 API 与可见文案，Python 测试验证 Windows/Linux/macOS 资产名、winget URL 和兼容标识，静态文档检查确认中英文 README 不含旧 fork 叙述或移动安装入口。

## Risks / Trade-offs

- [部分名称残留导致构建或上传失败] → 每个平台将原生配置、构建脚本、工作流校验和测试作为同一任务组提交，禁止只改展示层。
- [Linux 包名或数据路径被误改] → 明确保留清单，并用既有包测试及数据路径测试做回归。
- [winget 新旧名称混淆] → 区分稳定 PackageIdentifier 与展示名/资产名，生成 manifest 后验证 ID、URL、文件名和 ProductCode。
- [新仓库尚无对应 Release 时更新检查返回无可用版本或 HTTP 错误] → 不伪造旧仓库回退；首次 Venera-PC Release 后做真实更新检查验收。
- [README 清理被赞助自动化还原] → 保留或调整同步标记时运行对应生成器与测试，不修改赞助数据。
- [全局替换破坏 git 依赖与历史许可] → 使用按目录、按引用的有边界修改，最终检查依赖 URL 和 `pubspec.lock` 无变化。

## Migration Plan

1. 先归档并应用 `desktop-only-ci-cd`，再基于桌面工作流实施更名。
2. 同一次变更中更新产品显示、原生文件、打包、Release 和文档，避免生成半旧半新的资产。
3. 本地验证脚本测试、Flutter 测试和三平台可执行的构建校验；在可用桌面环境检查安装升级与数据保留。
4. 首次以新名称发布前生成 winget manifest 并核对下载 URL；发布后验证应用更新 API 与各桌面资产下载。
5. 回滚通过还原本次提交完成；由于没有数据或应用 ID 迁移，不需要逆向数据迁移。
