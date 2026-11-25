# UX1 第一批补证交付（以文末最新权威段为准，等待复核）

基准 HEAD：6f1f1bc01ce69be91e62b9474a0b95f83a752d73，分支 redesign-2026；开局工作区干净。冻结清单见 batch-1-baseline.sha256。

范围：1.1–1.4 / 2.1–2.4；F1/F2、搜索详情与阅读器后续阶段未实施。1.1/1.2、2.1–2.4已勾；1.3/1.4仅部分完成，保持未勾。无提交、归档或推送。

入口：MainPage → NaviPane → 单 Navigator；WindowFrame / DesktopChromeController / DesktopSearchBox 承载窗口控件与搜索。FavoritesPage 管理文件夹侧栏，LocalFavoritesPage → FavoriteFolderComics → AuthorShelf / SliverGridComics → ComicTile；布局入口 SliverGridDelegateWithComics。搜索 SearchPage / SearchResultPage，详情 ComicPage，阅读器 scaffold.dart / page_layout.dart，设置 LocalFavoritesSettings。持久化 Appdata.updateImplicit / updateSettings，数据目录 App.dataPath，原子临时文件与备份沿用现有实现。

阶段迁移：architect 已确认保留 favorite_hit_target_test.dart 220–264 的既有多选主体选择语义，本批不改断言；4.3 统一迁移为复选框选择、主体正常打开，保留真实命中、一次动作、身份/路由、菜单隔离、Escape。此为阶段边界，非最终 UX1 豁免。

真实基线：`fvm flutter analyze --no-pub` → 50 项，日志 /tmp/ux1-baseline-analyze.log；`fvm flutter test --no-pub test/app_shell test/components/navigation_bar_lifecycle_test.dart test/features/favorites/sidebar_sections_test.dart test/features/favorites/author_shelf_ui_test.dart test/features/favorites/author_shelf_layout_test.dart test/features/favorites/author_shelf_hover_test.dart test/features/favorites/favorite_hit_target_test.dart test/features/favorites/favorite_series_test.dart test/features/comic_widgets/comic_hit_target_test.dart --reporter expanded` → 174 通过、0 失败、0 skip，日志 /tmp/ux1-baseline-tests.log。调用前设置指定代理与 LD_LIBRARY_PATH。

## 实现与可证伪反馈

MainPage opt-in 接入 BookshelfWorkspace；宽窗收起偏好沿用 updateImplicit / SettingsSaveState，窄窗覆盖状态独立，遮罩与 Escape 关闭，焦点进入/返回；不重建工作区内容 Element。WindowFrame 内继续复用既有交通灯和窗口按钮；工作区承载搜索/历史，窄窗应用菜单收进原操作的 popup。收藏默认舒适画廊，保留既有显式列表偏好，新增紧凑密度设置；新样式仅收藏网格与作者 shelf。语义颜色、尺寸 token、减少动画、简繁文案随改动补齐。

| 观察 / 假设 | 单变量处理 / 证据 |
| --- | --- |
| 壳层无生产开关 | `/tmp/ux1-shell-red.log`；接入后真实控件点击、输入现场与 Element 保留测试通过 |
| Compact 设置不改变卡宽 | `/tmp/ux1-density-red.log`；接入布局密度 token 后真实设置操作改变宽度，字号保持 |
| 通用 gallery 改样式造成 B4 多项失败 | 共同根因是共享 renderer 把旧画廊两行标题改成单行；另外短名称 Tooltip 与原文本造成 F10 hover 定位歧义。恢复通用 renderer，将新视觉限于收藏，Tooltip仅真实截断时存在。原 B4/F5/F10 测试未删弱；`/tmp/ux1-hit-green.log` 104通过0失败0skip |
| Tooltip 长按与选择竞争 | 新样式 Tooltip 改 manual trigger（鼠标 hover 仍由 Tooltip 内建逻辑响应）。新增真实鼠标 hover 显示完整长名、离开隐藏、长按选择且不 push；150%两条实际文字行和遮挡封面命中仍核对正确实体/路由/准确一次/菜单/Escape。`/tmp/ux1-tooltip-hit.log` 4通过0失败0skip |
| compact 键盘 Escape 未关闭 | 已观察8个compact组合失败、17通过；旧 matrix 红灯日志随后被覆盖，不能作为现存原始可复核日志，不伪重建。修复 post-frame 焦点转入、背景 ExcludeFocus 与 Escape，`/tmp/ux1-matrix-green.log` 26通过0失败0skip |
| GUI 标题栏压住工具栏 | WindowFrame提供媒体padding但body未消费；NaviPane桌面壳层增加SafeArea。生产WindowFrame测试断言工具栏与工作区 top ≥ titleBarHeight，保留原命中坐标测试。随后发现compact英文菜单0.5px溢出（`/tmp/ux1-titlebar-debug.log`），窄窗收进应用菜单；`/tmp/ux1-titlebar-green.log` 31通过0失败0skip |
| 最终analyze从50增到52 | 两处新增 curly_braces_in_flow_control_structures（bookshelf_workspace.dart原63/99行）；加括号后最终 `/tmp/ux1-final-analyze.log` raw/unique50，38tool+12其他，具体集合 added=[] / removed=[]，见 batch-1-analyze-comparison.json |

真实磁盘故障：把本测试隔离目录 implicitData.json.tmp 置为目录，阻断真实原子保存；核对失败反馈、Retry、新意图替代旧意图、保留无关值42、真实磁盘重读恢复。日志中的预期 FileSystemException 为测试注入故障，不是遗漏失败。测试初始化曾因 FakeAsync 等待真实磁盘队列卡住，已只停止自己的 session；改用有界 settleSidebarWork（最多200次交替真实IO/泵帧）。初始化异常不计产品红灯。

1.3未完成部分：多栈、预览、统一主体、单进度依赖后续生产入口，尚无完整红灯。1.4未完成部分：本批只保存书架布尔偏好；不是工作区快照v1。稳定标签/实体身份、损坏恢复、跨目录旧回调与3.x生命周期仍待实现及故障红绿。

## 回归与命令

所有Flutter命令前缀：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter`，测试、分析和构建均 `--no-pub`，未加依赖或重生成lock。

`/tmp/ux1-regression-final.log`：274通过0失败0skip，涵盖 app_shell、导航生命周期、F11分组、F10三态/独立排序/hover/拖动/存储、B4、F5系列、设置持久化与新增命中。该轮在最后SafeArea/窄菜单修复前；之后针对受影响WindowFrame、24组合、故障保存和topbar复验31通过。不得把两轮相加称独立总数。最终仅括号lint修复后的复验36通过0失败0skip（31新增+5标题栏回归），见 `/tmp/ux1-frozen-tests.log`（命令：`test --no-pub test/app_shell/bookshelf_workspace_test.dart test/app_shell/bookshelf_matrix_test.dart test/app_shell/bookshelf_density_test.dart test/app_shell/desktop_top_bar_test.dart test/features/favorites/bookshelf_hit_target_test.dart --reporter expanded`）。选定回归没有既有失败或skip；未跑全库，已知folder_order_ownership编译错误仍属于analyze基线。

## 初次交付 GUI 与冻结关系（历史阶段）

生产文件冻结见 batch-1-production.sha256，清单自身 SHA256 `027b202687bee9a5555c8c9504523743586f370249c8ef53167f41b1c50fc775`。含14个资产/生产文件；新增测试另见后附验证冻结清单。

已核准 `/tmp/ux1_gui.dart` SHA256 `4f787b9ce751148416eeb79c06bd164ba289b0806f489226936bbed141b9410f`；helper `/tmp/ux1_x11.py` SHA256 `5cdadf1b25a9a185e6a78800985eae991ec55428f5f751f34905d00edd80f3ed`，此后未改。最终源码构建 `/tmp/ux1-gui-frozen-build.log` 成功；debug exe SHA256 `274b77c2f07494de8043fd7eb61a58715e50450042ce021c6b009a24bf94ae1b`，真正Dart入口产物 kernel_blob.bin SHA256 `5fe95d45652501acdf7157057481df95c96f1c5c558bd217fdd3f7b695f5b9c3`。

本轮启动 PID77565，XID0xa00002，固定title `UX1 bookshelf batch1 fixture`；每次操作核完整exe/PID/title/UX1_FIXTURE，局部坐标同时核窗口和root范围。DISPLAY=:1、GDK_BACKEND=x11；XDG为/tmp/ux1-xdg，业务为/tmp/ux1-batch1-business，cache为/tmp/ux1-batch1-cache。未修改正常main或runner。

| 最终证据文件（均在/tmp） | 范围 |
| --- | --- |
| ux1-full-1400x900-light-cn-100-motion.png | RepaintBoundary完整Flutter帧，expanded浅色简体100%；可见标题栏与工作区无重叠 |
| ux1-final-expanded-cropped.png | 1080×760宿主裁截X11图，**不是**完整expanded截图 |
| ux1-full-1000x700-light-cn-100-motion.png / ux1-final-medium-light-cn.png | medium浅色简体，完整Flutter帧 / X11全窗 |
| ux1-full-1000x700-dark-tw-150-reduced.png / ux1-final-medium-dark-tw-150-reduced.png | medium深色繁体150%减少动画，完整Flutter帧 / X11全窗 |
| ux1-full-600x700-light-cn-100-motion.png | compact浅色简体完整Flutter帧 |
| ux1-final-compact-dark-tw-150-reduced.png | compact深色繁体150%减少动画X11全窗 |
| ux1-final-compact-overlay.png / ux1-final-compact-escape.png | 真实鼠标局部(24,76)打开覆盖侧栏、真实Escape关闭及焦点回开关 |

完整Flutter帧不等于完整X11宿主截图。宿主root1080×760，未调整宿主；鼠标只操作宿主可达区域。F6异步抓帧后曾立即resize，目标expanded深色抓帧实际落在1000×700，故没有冒称expanded深色全帧。GUI未穷举所有矩阵组合；测试24组合覆盖600/1000/1400、浅深、简繁、150%、减少动画开关。ThemeData为fixture受控主题，不证明生产动态取色链路；F4直接写设置，不冒称真实设置GUI操作（设置入口由生产控件测试验证）。空封面为隔离fixture内容，未照抄探索稿资产。macOS交通灯仅代码位置核对，未在macOS运行。软件GL存在resize超时警告，最终渲染图已实际检查无溢出。

## 初次交付清理与保护（历史阶段）

已在最后一次helper身份核对后仅CtrlC停止自己的fixture会话，PID77565已不存在；未停止其他程序。正常main `build linux --debug --no-pub` 成功，日志 `/tmp/ux1-main-final-build.log`；正常kernel SHA256 `71d8e3036eda4bbca31ab7be4b59def51add4e57f99157dda4b0f5b33f740b8b`，与fixture不同。临时harness/helper/截图仅/tmp，正常入口与runner未为fixture修改，留/tmp证据供独立复核，不入库。

受保护文档、正式spec、归档、pubspec.yaml/lock零diff；原favorite_hit_target和comic_hit_target测试零diff。`git diff --check`通过，`openspec validate ux1-bookshelf-workspace`通过。新增测试冻结见batch-1-tests.sha256。SHA清单列出本批修改生产文件；无需假称这些获授权修改也与HEAD相同。architect批准前不提交，交付后等待本阶段独立复核，不接续3.x。


## 独立复核补证进行中

architect已独立274通过。本轮补证未完成，暂不提交/不跨3.x。密度真实调用红灯见/tmp/ux1-supplement-paths.log（旧手动排序卡158.7×289.1→134.9×254.1），opt-in隔离后/tmp/ux1-isolation-green.log 2通过。获批准将FavoritesPage/LocalFavoritesPage的didChangeDependencies同步chrome通知移交已有build post-frame，保留全部通知。当前真实收藏已滚轮420px并选两卡，但Tab开关定位仍待查；/tmp/ux1-continuity-traversal.log不能冒称通过。下一单变量是8次实际焦点节点和祖先链。GUI无fixture运行；/tmp/ux1_gui.dart新稿SHA2641bac1f9c6cc3d570741c188d9b26643eb161f358a194435f7c19845d7ef5a尚未获核，不构建。

当前修改生产SHA（非最终冻结）：

```
d0e4a79b4f7c1e080bdc3b73ff202bd4e28ab65c60f315e6eb9854b35e20ee24  lib/components/layout.dart
78c5fcca719d3d1ad1ee0aff668f6dfee373357ecdb1668bc09f735339b1cb68  lib/features/comic_widgets/comic_list.dart
f560ffe9e90aebac4d001e1989d16723a54a978c161b2186cc363b30e0dafc63  lib/features/favorites/author_shelf.dart
0f7d3ed122c5599b993a76db9ac6d209f107736ecf9e1fd5627981f3bd41567f  lib/features/favorites/favorites_page.dart
cc77f8fcc09aafe3b8679d13d7d46c8311765c6edd8efffcc18073f805489d70  lib/features/favorites/local_favorites_page.dart
```


## 2026-11-08 恢复补证进度（替代上段pending结论）

HEAD仍6f1f1bc，保留全部脏改，无提交。五个生产补修SHA与上一段一致，另将当前16个资产/生产文件冻结于batch-1-supplement-production.sha256；旧14文件清单只代表上一阶段。

已完成的真实集成测试：MainPage→WindowFrame→BookshelfWorkspace→FavoritesPage→LocalFavoritesPage；60部作品，真实鼠标滚轮420px，长按book-4、点击book-5，核对(local,id)实体集合、选2提示。同一LocalFavoritesPage State/Element与同一ScrollController，在宽窗收起、600宽覆盖、Escape关闭、1400恢复宽窗后均保持，真实偏移420±0.01px；原焦点local-favorites-selection在Escape后精确同一FocusNode，第二次Escape继续清空收藏选择。查询Book 00核对仅book-0；卸载后left/right/bookshelf/canNavigate全部false，调用退役入口无异常。原shell/matrix键盘断言保留。

旧probe原始日志/tmp/ux1-continuity-probe.log保留：step0/2/3/4为ComicTile/ClickInkWell内FocusNode；step1为InkWell；step5/6/7同FocusNode#680c8，祖先MouseRegion/Actions/Semantics/Focus/Shortcuts/FocusableActionDetector，前12级无IconButton。未证明内层Navigator全局Tab可达外层书架，明确保留为未完成全局键盘观察；本次不冒称全局可达性通过。临时8次probe循环/print已从测试删除。新增的ScrollableState身份断言过强：原收藏响应式容器会替换内部Scrollable，SmoothScrollProvider也会随输入physics替换ScrollPosition；最终保留契约要求的页面State/Element、控制器及准确偏移断言，不要求框架内部对象恒等。

本轮实际产品红灯：/tmp/ux1-supplement-paths.log内FavoritesPage.setLeftSidebar与LocalFavoritesPage.setRightSidebar/setFavoritesSearchQuery在didChangeDependencies中同步通知，触发build-phase assertion。同步点HEAD已存在，本轮D3新壳真实集成触发，architect明确授权必要集成修复；仅移除didChangeDependencies即时发送，已有build post-frame继续发送全部绑定/可用性/query/callback，未删通知。真实查询与卸载断言通过。

初始化/等待误差单列：首轮测试缺App.dataPath/Res导入，随后增加query测试缺OpenCC.init，均为测试初始化错误，未计产品红灯。宽窗开关真实磁盘保存必须先有界settleSidebarWork再pumpAndSettle，否则保存spinner导致动画等待超时；没有删除保存断言或扩大无界等待。

/tmp/ux1-supplement-regression-green.log：248通过0失败0skip。覆盖test/app_shell全部、navigation_bar_lifecycle、smooth_scroll_lifecycle、F11 sidebar_sections、author_shelf layout/drag/hover/ui、favorite_hit_target/favorite_series、comic_hit_target/comic_list_lifecycle。上一轮同集合247通过1失败为新增测试缺OpenCC初始化（/tmp/ux1-supplement-regression.log），已单列，非产品回退。/tmp/ux1-continuity-lifecycle.log单项通过，实体book-4/book-5、offset420。/tmp/ux1-isolation-green.log：真实普通ComicList与生产排序页2通过，排序尺寸固定为原七列1000/7-8。

/tmp/ux1-supplement-analyze.log raw/unique50=38tool+12其他，具体集合added=[] removed=[]，见batch-1-supplement-analyze-comparison.json；旧50结果不代替本轮。

GUI仍待最终补齐：已批准harness3923cff1cf4f4f05ff2a2e73f6b8e5ee32ed0434e1e1647fe0f905c9c9f59aa1，helper38174d8595f7d67addf0a07da89456fc711348b6dd6c2a99365a8b4cac3381bc。旧PID342244通过最后helper身份核验后仅CtrlC停止（exit130），其已选2卡图仅阶段证据。新harness只增加FavoriteFolderComics实体只读日志，正在重新构建，未直接设选择或offset；下一步新PID真实输入重做逐步capture并另存图。正常main目前仍待这次GUI完成后重建，不能沿用上轮正常main构建称本次已恢复。


## 2026-11-08 最终权威交付（覆盖上文进行中状态）

本轮补证已完成，等待architect复核；无提交、不跨3.x。tasks1.1/1.2、2.1–2.4完成；1.3/1.4继续如实未勾，3.x–7.x未实施。原多选主体选择语义留4.3迁移的阶段边界不变，不是最终UX1豁免。

当前权威冻结为 **batch-1-supplement-production.sha256（16文件）** 与 **batch-1-supplement-tests.sha256（6新增测试）**。旧batch-1-production.sha256含14文件，仅初次交付历史，有3个本次获授权修改文件与当前不同，这是预期；旧四测试/GUI清单同样不作为当前冻结。原始基线SHA保留，不覆盖历史。

最终五文件补修SHA：

```
d0e4a79b4f7c1e080bdc3b73ff202bd4e28ab65c60f315e6eb9854b35e20ee24  lib/components/layout.dart
78c5fcca719d3d1ad1ee0aff668f6dfee373357ecdb1668bc09f735339b1cb68  lib/features/comic_widgets/comic_list.dart
f560ffe9e90aebac4d001e1989d16723a54a978c161b2186cc363b30e0dafc63  lib/features/favorites/author_shelf.dart
0f7d3ed122c5599b993a76db9ac6d209f107736ecf9e1fd5627981f3bd41567f  lib/features/favorites/favorites_page.dart
cc77f8fcc09aafe3b8679d13d7d46c8311765c6edd8efffcc18073f805489d70  lib/features/favorites/local_favorites_page.dart
```

密度隔离的实际入口：ExplorePage多个入口、HistoryPage与普通ComicList均默认SliverGridComics(useFavoriteDisplaySettings:false)→galleryColumns:null，走发现brief/detailed，原来已无尺寸泄漏，但共享delegate无条件读取收藏密度会造成不必要耦合。另一个真实调用ComicReorderPage使用galleryColumns但旧ComicTile renderer，确有新密度改变其尺寸的红灯。本轮delegate新增bookshelf=false显式开关，false时不读收藏密度且保留HEAD gallery144/0.64尺寸；只由本批收藏SliverGridComics的新gallery renderer和作者shelf显式true启用。排序页调用与拖动行为不改。测试真实打开生产排序页、真实普通ComicList，在comfortable/compact往返尺寸相同；排序卡保留HEAD七列尺寸。相关drag与B4原断言全部保留通过。

绑定修复的产品红灯与HEAD同步点已在上段区分。当前仅FavoritesPage/LocalFavoritesPage didChangeDependencies取消即时_syncChrome，保留已有build post-frame完整通知（左/右可用性、展开状态、搜索query、callback）；真实MainPage挂载/宽窄/卸载和query断言及既有绑定生命周期回归通过。未扩历史清理。

最终执行者回归：**248通过0失败0skip**，/tmp/ux1-supplement-regression-green.log，命令为指定env前缀后 `fvm flutter test --no-pub test/app_shell test/components/navigation_bar_lifecycle_test.dart test/components/smooth_scroll_lifecycle_test.dart test/features/favorites/sidebar_sections_test.dart test/features/favorites/author_shelf_layout_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/author_shelf_hover_test.dart test/features/favorites/author_shelf_ui_test.dart test/features/favorites/favorite_hit_target_test.dart test/features/favorites/favorite_series_test.dart test/features/comic_widgets/comic_hit_target_test.dart test/features/comic_widgets/comic_list_lifecycle_test.dart --reporter expanded`。architect于本次会话报告在最终补修独立复跑**293通过0失败0skip**；与我方248分别报告、不相加。此前274仅旧阶段。新增6个测试文件含34新增测试（原31+2密度隔离+1完整收藏现场），全部无skip。

最终analyze **raw/unique50=38+12**，执行者/tmp/ux1-supplement-analyze.log具体集合added=[]removed=[]；batch-1-supplement-analyze-comparison.json存完整集合。architect亦独立复核同结果。受保护文件与原favorite_hit_target/comic_hit_target零diff；git diff --check与openspec validate ux1-bookshelf-workspace通过。

### 最终真实GUI逐步对应

最终生产冻结后构建的harness SHA `3923cff1cf4f4f05ff2a2e73f6b8e5ee32ed0434e1e1647fe0f905c9c9f59aa1`，helper SHA `38174d8595f7d67addf0a07da89456fc711348b6dd6c2a99365a8b4cac3381bc`，均经architect全文核准后执行。工具清单batch-1-supplement-tools.sha256；截图清单batch-1-supplement-gui.sha256；关键红绿/构建/GUI日志清单batch-1-supplement-logs.sha256。

最终fixture构建/tmp/ux1-supplement-gui-final-build.log成功，exe SHA `274b77c2f07494de8043fd7eb61a58715e50450042ce021c6b009a24bf94ae1b`，fixture kernel_blob SHA `a6168f53770c9d0ff15ab353285d7cae6dd41907b09debebdbb4237e829308a8`。PID351413 / XID0xa00002，固定title/完整exe/PID/UX1_FIXTURE每次核对；DISPLAY=:1、GDK_BACKEND=x11、/tmp独立XDG/业务/cache同前；没有为fixture改main/runner。

真实生产动作：1000×700宽窗收藏右上菜单(970,114)→选择漫画(824,364)→作品0标题(560,451)→作品1标题(730,451)；卡片区(560,400)真实4tick滚轮，产生214.95852066715972px。没有直接设置选择或offset。每次输入后先稳定截图，再F6读场景并完整帧capture；等完成日志后将帧另存到各自文件，不覆盖关键前后图。

| 阶段 | X11截图（/tmp下） | 完整Flutter帧（/tmp下） | 对应场景日志 |
| --- | --- | --- | --- |
| A 宽窗两卡+非零滚动 | ux1-cont-a-wide-selected-scrolled.png | ux1-cont-a-wide-flutter.png | 两实体、offset214.9585，原选择焦点 |
| B 真实点击(247,63)收起 | ux1-cont-b-wide-collapsed.png | ux1-cont-b-wide-flutter.png | 两实体/同page/controller/offset/焦点保持 |
| C 缩至600×700 | ux1-cont-c-compact.png | ux1-cont-c-compact-flutter.png | 同上，宽窗偏好未被窄窗写覆盖 |
| D 点击(24,63)打开覆盖层 | ux1-cont-d-overlay.png | ux1-cont-d-overlay-flutter.png | 两实体/同page/controller/offset保持，焦点在覆盖域 |
| E 真实Escape关闭覆盖层 | ux1-cont-e-escape.png | ux1-cont-e-escape-flutter.png | 返回精确原选择FocusNode，选2仍在 |
| F 恢复1000×700 | ux1-cont-f-wide-restored.png | ux1-cont-f-wide-flutter.png | 宽窗保持收起，现场与原焦点均保持 |
| G 最终深色繁体150%减少动画1400×900 | ux1-cont-g-expanded-dark-cropped.png（宿主裁截） | ux1-cont-g-expanded-flutter.png（完整1400×900） | 两实体与现场依旧保持，标题栏不重叠 |

/tmp/ux1-supplement-gui-final-run.log按A–G顺序共7组capture：实体始终local:ux1-0,local:ux1-1；page=273429618，controller=85245702，offset=214.95852066715972；A/B/C/E/F/G均focus local-favorites-selection identity558480815，D为bookshelf overlay identity801026654。界面可见已选2本与作品0/1选中表面；architect已独立view_image核A/D/F/G并核六阶段场景日志。

局限仍如实保留：完整Flutter帧不等于完整宿主X11图，1400窗口的X11图为cropped；GUI受控ThemeData不证明真实动态取色链路；macOS未实机运行；简繁/大字/减少动画GUI为代表组合，非全部排列。内层Navigator全局Tab到外层的8次观察尚未证明可达，不冒称全局可访问性通过；原shell/matrix的键盘覆盖未删除。原始probe日志保留、临时probe代码已删除。

### 最终正常入口与清理

最后helper身份核验后仅CtrlC停止自己的PID351413（exit130），已确认/proc/351413不存在；X11树仅剩原QQ/Chromium剪贴板窗口，本任务无残留窗口。未停止他人进程。最终生产正常main `build linux --debug --no-pub`成功（/tmp/ux1-supplement-main-build.log），正常kernel_blob SHA `37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8`，与fixture kernel不同。临时harness/helper/隔离fixture数据与截图仅/tmp留作复核证据，不进入仓库；正常main/runner没有fixture修改。

最终状态：本批补证完成等待architect，不提交/归档/push，不启动3.x或其他change。
