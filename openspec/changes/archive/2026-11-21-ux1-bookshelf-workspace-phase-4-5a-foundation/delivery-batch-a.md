# Batch A 合并工作区顶栏与断点壳层

- 日期：2026-11-20
- 基线：`d25642aff96ecd866df6f9ee67f938e7f6b52104`
- 状态：单行顶栏收尾切片完成，待 owner GUI 复核。

## 实现

- `BookshelfWorkspace` 新增 `showToolbar`；桌面生产路径关闭其独立 48px toolbar，独立测试宿主仍保留本地 toolbar。
- `WindowFrame` 合并桌面工作区侧栏开关、返回、命令中心和收藏左右布局控件；现有 `titleBarHeight` 成为唯一工作区顶栏入口。
- 工作区标签栏已移入该唯一顶栏并改为紧凑内嵌模式；生产顶栏移除搜索框，搜索入口继续由侧栏提供。
- 漫画详情页在桌面工作区隐藏页面 SliverAppbar 的隐式返回入口，避免与全局返回按钮重复；移动端仍保留页面返回。
- 保留 compact 侧栏覆盖、遮罩、Escape 和宽窗口偏好保存逻辑；未改变标签身份、历史、搜索或收藏数据。

## 验证

- `fvm flutter analyze lib/app_shell/bookshelf_workspace.dart lib/components/navigation_bar.dart lib/components/window_frame.dart`：通过，No issues found。
- `fvm flutter test test/app_shell/desktop_top_bar_test.dart`：5/0/0，通过。
- `fvm flutter test test/app_shell/bookshelf_workspace_test.dart test/app_shell/bookshelf_matrix_test.dart`：矩阵 25/0/0；`bookshelf_workspace_test.dart` 1 项失败，失败发生在测试宿主未构造 `BookshelfWorkspace` 的既有平台分支，尚未宣称通过。
- `fvm flutter build macos --debug --no-pub`：通过，生成 `build/macos/Build/Products/Debug/VeneraNext.app`。
- `git diff --check`：通过。
- 变更后 Dart 分析（受影响 5 个源码文件）：通过，No issues found；`git diff --check`：通过。

## GUI 证据

用户允许新构建访问文稿目录后，重新启动 Debug 产物并取得：

- `/tmp/ux1-batch-a-expanded.png`：expanded，顶栏同一行包含侧栏开关、返回、命令中心；该截图对应收尾前版本，标签仍在下一行。
- `/tmp/ux1-batch-a-medium.png`：medium，顶栏保留侧栏开关/返回，命令中心隐藏；无额外独立标题栏。
- `/tmp/ux1-batch-a-compact.png`：compact，窗口缩窄后顶栏仍为单行，内容保持可见，标签行独立位于其下。

截图来自当前 Batch A 构建产物；阅读器现场用于验证顶栏层级，未改标签身份、章节或页码。

此前通过已授权的 CUA 重新绑定当前构建实例确认 AX/UI；该证据对应收尾前版本，因此不能作为本次单行顶栏的最终验收证据。当前实现需重新构建后核对：顶栏不再出现搜索框，标签与顶栏同一行，详情页只保留全局返回按钮。

本轮尝试重新构建时，Flutter 已通过本地权限问题并进入 macOS 编译，但 `rhttp` 的 Cargokit 需要下载 Rust 1.92.0；当前代理端口拒绝连接，构建因此停在依赖下载阶段，尚未产生可供 CUA 复核的新 GUI 截图。
