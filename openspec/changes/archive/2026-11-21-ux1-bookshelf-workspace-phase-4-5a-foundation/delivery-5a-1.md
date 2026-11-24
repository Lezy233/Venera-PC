# 5A.1 草稿视觉基线审计

- 初始审计日期：2026-11-19；初始基线 HEAD：`bccedcb2534b625b6413be8060a234a2929d8e1e`。
- 2026-11-20 复核基线：当前分支 HEAD 为 `d25642aff96ecd866df6f9ee67f938e7f6b52104`（已包含此前 reader chrome checkpoint）；本轮仍只更新审计记录，不修改生产代码、测试、契约或依赖。`tasks.md` 仍未勾选 5A.1。

## 证据与限制

探索稿运行入口是 `explorations/ux1-directions/package.json` 的 `npm run dev`，实际执行 `node server.mjs`（默认 `127.0.0.1:7100`）。源码证据：

- 壳层/标签：`explorations/ux1-directions/src/main.js:40-66`；收藏/shelf：`:17-38`；搜索：`:69-81`；详情：`:83-104`；预览：`:106-118`；阅读器：`:120-124`。
- 视口/样式：`explorations/ux1-directions/index.html:108-143,145-260,260-410,410-520`。
- 生产关键定位：`lib/components/window_frame.dart:374-429`、`lib/app_shell/bookshelf_workspace.dart:127-203`、`lib/app_shell/workspace/desktop_workspace.dart:375-397`、`lib/app_shell/workspace/workspace_tab_strip.dart:62-129`、`lib/features/reader/scaffold.dart:541-668,715-788`、`lib/features/reader/top_bar.dart:6-75`、`lib/features/reader/reader_page.dart:1932-1953,2021-2085`。

尝试启动探索稿服务时得到 `listen EPERM 127.0.0.1:7100`；CUA 浏览器宿主返回 `The browser access host is unavailable`。尝试正常生产 bundle（隔离 `/tmp/ux1-5a-*` XDG）后，`:1` 不可用：`xwininfo: unable to open display ":1"`，且没有可核验的生产窗口。因此本轮 **0 张截图、0 个 DOM/布局快照**；没有把 fixture/helper、静态推测或构建成功冒充 GUI 证据。正常 GUI 仍受限，停止等待并将限制保留在本报告。

2026-11-20 复核时通过 CUA 拉起已安装的 `VeneraNext-Dev`，观察到真实窗口的壳层截图，但内容区全黑且无可访问页面/路由；该截图只能证明窗口已创建，不能证明任一页面的布局、行数或控件组合，故不计入 GUI 对照证据。探索稿服务在 7101 端口重试仍返回 `listen EPERM`。

2026-11-20 按 owner 指定改用 ego lite。原始探索稿以 `file://` 打开时 ES module 被浏览器策略阻止，页面只显示静态占位；随后将仓库内 `index.html` 与 `src/main.js` 原样合并为 `/tmp/ux1-5a-1-exploration-inline.html`（未改仓库文件），在 ego lite 中成功取得页面级 DOM 与截图。DOM 快照已保存为 `evidence-5a-1-draft-dom.json`；截图留在 `/tmp/ux1-5a-1-draft-*.png`，覆盖 A 方案收藏首页的 expanded/medium/compact、作者 shelf、快速预览、普通阅读工具显示/隐藏和沉浸阅读。代表性 DOM 可见 A 方案工作区包含书架导航、工作区顶栏、收藏摘要、作者分栏与封面网格；阅读器状态分别暴露 `data-reader-mode="normal"`、工具显隐和 `data-reader-mode="immersive"`。

2026-11-20 生产窗口复核：按用户命令尝试 `fvm flutter run -d macos`，当前环境在 `rhttp` 原生插件构建阶段因 Rust 1.92.0 下载被代理拒绝而未启动；随后直接启动当前分支已有的 `build/macos/Build/Products/Debug/VeneraNext.app`。首次启动触发 macOS “允许访问文稿文件夹”权限对话框，点击允许后重新激活窗口，真实生产页面正常显示。截图 `/tmp/venera-front-2.png`（2940×1912）可核验 expanded 收藏工作区；窗口自动缩放后 `/tmp/venera-medium.png`、`/tmp/venera-compact.png` 分别核验 medium/compact；点击首卡后 `/tmp/venera-after-card.png` 核验详情页；点击“阅读”后 `/tmp/venera-reader.png` 核验普通阅读器。阅读器漫画区域点击复核 `/tmp/venera-reader-tools.png`、`/tmp/venera-reader-tools-2.png` 均未出现草稿预期的阅读工具行，记录为真实差异，交由 5A.2 分类。空壳根因是权限提示/启动时机与旧安装实例，不是生产页面缺失。

约束分类：**[草稿]** 指 A 草稿的布局/层级/控件/行数基线；**[token]** 指 `design-spec.md` §2–§4、§7 和 `tokens.dart`/`breakpoints.dart`；**[功能]** 指 proposal/design/reader spec 的标签、预览、章节和恢复契约。

## 逐页差异表

| 页面/状态 | A 草稿结构与层级 | 生产源码结构 | expanded / medium / compact | 审计结论 |
|---|---|---|---|---|
| 壳层/工作区 | [草稿] 左书架 + 右工作区；窗口控制/菜单/侧栏开关/历史/标签同一行；不分屏、无独立标题行。 | [token] `WindowFrame` 36px title strip；[token] `BookshelfWorkspace` 48px toolbar；[功能] `DesktopWorkspace` 再有 44px `WorkspaceTabStrip`。 | expanded 显示 320×26 命令中心；medium 隐藏；compact 书架覆盖/遮罩、菜单改 PopupMenu。三档都仍可能是 36+48+44 多层。 | **高差异：顶栏行数/层级未证明符合 A。** |
| 收藏/作者 shelf | [草稿] 页面标题+筛选摘要+舒适封面 shelf；作者栏折叠/正常/展开，平台名称展开不请求；选择控件按需出现。 | 收藏页仍有 160–420px 可调文件夹侧栏（`favorites_page.dart:26-28,118-267`）；内容是 SliverAppbar/列表（`:412-465`）。作者 shelf 是 `SliverList`/`_AuthorShelf`（`author_shelf.dart:70-110,555-600`），拖拽手柄 44px（`:520-546`）。 | 720 为页内双栏阈值；compact 页内侧栏改菜单/弹层，而外层书架也可覆盖。 | **中高差异：功能保留，但出现书架+收藏文件夹两级导航，层级不是草稿单一书架。** |
| 搜索/单源/聚合 | [草稿] 搜索工作区顶栏+结果 pane；封面平铺主视图；复选框、加载/空态/失败/刷新在结果区；主体、Space、Ctrl/Cmd+Enter 分离。 | `SearchPage` 首屏为 `SliverSearchBar`、搜索目标、选项、快捷项、历史（`search_page.dart:432-475,478-520`）；单源结果为 `ComicList`，gallery/list 由偏好切换（`search_result_page.dart:228-259`）；聚合是每来源 `SliverList` 内嵌 `SliverGridComics`（`aggregated_search_page.dart:146-189,345-360`）。 | expanded 命令中心可见；medium/compact 隐藏或窄化，compact 外层侧栏覆盖。 | **中差异：交互契约大多有，A 的结果 pane/封面首层级与生产搜索配置/来源分组树不同。** |
| 详情（信息优先） | [草稿] 单标签 hero（封面、标题、作者/来源、主动作）后简介/最近章节。 | `ComicPage` 是纵向 `SmoothCustomScrollView`，顺序 title、actions、description、info、chapters、comments、thumbnails、recommend（`comic_page.dart:255-301`）；`SliverAppbar` 与 144px 封面（`:376-452`）。 | 三档主要改变外层 chrome 与窄屏 app bar；medium/expanded 无并排详情。 | **中差异：信息优先存在，但首屏是 SliverAppbar+长滚动栈，不是草稿单一 hero。** |
| 详情（阅读优先） | [草稿] 只改变顺序/默认展开，不删功能。 | `comicDetailMode == reading` 时折叠 “Works details and sources”（`comic_page.dart:255-290`），章节/评论/缩略图/推荐仍在同一栈。 | 三档功能相同，compact 更易换行。 | **低到中差异；真实首屏尺寸未取证。** |
| 临时预览 | [草稿] 居中临时 modal，封面+概览/目录/详情，左右切换；Enter 当前标签，Ctrl/Cmd+Enter 后台标签，关闭回原焦点。 | `showComicPreview` 为 Dialog，最大宽 640、inset 16、封面高 200、滚动详情和章节、Details/后台标签按钮（`comic_preview.dart:11-38,79-118,113-159,164-245`）；Space/Esc/左右/Enter 由 tile Focus 处理（`comic_tile.dart:395-451`）。 | 三档均为 modal；compact 受可用宽度约束。 | **低到中差异：功能边界基本对齐；切换控件、遮罩与焦点尺寸待 GUI。** |
| 阅读器普通/工具隐藏 | [草稿/功能] 顶部唯一合并工作区行；窗口控制/侧栏开关/历史/标签可用；底部仅一条精简进度。 | `BookshelfWorkspace` 控制书架可见性（`:127-203`），但外层 `WindowFrame`、toolbar、tab strip 仍独立；`ReaderScaffold` 隐藏工具时仍保留 body+bottom（`scaffold.dart:559-565`）。 | expanded/medium/compact 都不能由源码证明唯一一行；compact 还有覆盖书架状态。 | **高差异/待实拍：当前树存在多层 top chrome。** |
| 阅读器普通/工具显示 | [草稿/功能] 只在工作区行下加一行 reader tools，共两行。 | `_isOpen` 时 `AnimatedPositioned` 渲染 `ReaderTopBar`（`scaffold.dart:587-597,635-668`）；其自身有返回、标题/章节、fullscreen/comments/settings（`top_bar.dart:6-75`），底部另有 `ReaderBottomBar`（`scaffold.dart:599-605,715-788`）。 | expanded 多一个命令中心；medium 无；compact 更易标题换行。 | **高差异/待实拍：reader 行存在，但上方生产 chrome 不是草稿唯一合并行。** |
| 阅读器沉浸/工具显示 | [草稿/功能] 隐藏标签和非必要 chrome；顶部仅 reader tools；Escape 先浮层后退出；主题跟随应用。 | `DesktopWorkspace` 隐藏 tab strip（`desktop_workspace.dart:383-397`），`BookshelfWorkspace` 隐藏 toolbar/书架（`bookshelf_workspace.dart:127,156-203`）；immersive 状态/窗口切换见 `reader_page.dart:1932-1953,2021-2085`。但 `ReaderTopBar` 仍使用 `BlurEffect` 与 `Colors.grey.toOpacity`（`top_bar.dart:20-27`）。 | 三档均依赖窗口 frame 实际状态，源码不能证明最终物理行数和颜色。 | **中高差异/待实拍：隐藏路径存在；“只一行”和 token 主题尚未闭合。** |

## 视口与阅读器状态矩阵

| 档位 | 壳层预期 [草稿] | 普通隐藏 | 普通显示 | 沉浸工具显示 |
|---|---|---|---|---|
| expanded (≥1200) | 书架+工作区，命令中心在同一行 | 1 行合并行 + 内容 + 1 条精简进度 | 合并行 + 1 行 reader tools，共 2 行 | 仅 1 行 reader tools |
| medium (720–1199) | 书架可收起+工作区，无命令中心 | 同上，无命令中心 | 同上 | 同上 |
| compact (<720) | 侧栏覆盖内容，Escape/外部关闭，不挤压正文 | 窄工作区行 + 内容 + 精简进度 | 窄工作区行 + reader tools | 仅 reader tools，不恢复标签 |

生产断点来自 `lib/design_system/breakpoints.dart:28-51`。生产尺寸为 `bookshelfWidth=224`、`workspaceToolbarHeight=48`、`workspaceTabHeight=44`、`titleBarHeight=36`（`lib/design_system/tokens.dart:65-103`）；design-spec 的合并顶栏要求 36px，存在需 5A.2 分类的尺寸/行数冲突。

## 未决差异（交给 5A.2）

- 是否把 WindowFrame 36px 纳入合并工作区行，或合并/移除 48px toolbar 与 44px tab strip；owner 需按真实窗口截图拍板。
- 书架 224px 与收藏 160–420px 文件夹侧栏是否保留两级，还是归并为 A 的单一导航。
- 搜索结果默认信息层级（草稿封面平铺 vs 生产搜索配置/来源分组）及详情首屏 hero/SliverAppbar 关系。
- 预览 Dialog 的 640px/200px 占位、遮罩、焦点在三档是否满足草稿。
- `ReaderTopBar` 的 BlurEffect/灰色边界、普通两行/沉浸一行以及浅深主题语义色需正常 main 实拍确认。

## 校验与交付边界

- `git diff --check`：通过。
- `openspec validate --changes ux1-bookshelf-workspace`：通过（1 passed, 0 failed）。
- 草稿 GUI/DOM 证据：8 张页面级截图 + `evidence-5a-1-draft-dom.json`；正常生产页面级证据：expanded/medium/compact 收藏、详情、普通阅读器和阅读器点击复核共 7 张截图。已完成页面级差异审计；差异未视为视觉纠偏通过，后续由 5A.2 分类与排批。
- 未提交、未归档、未 push；未运行会改变依赖或生产代码的命令。
