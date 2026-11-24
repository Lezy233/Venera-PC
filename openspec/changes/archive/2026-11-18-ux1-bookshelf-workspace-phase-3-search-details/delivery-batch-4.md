# UX1 5.x delivery — 搜索、详情与设置一致性

基准 HEAD `7ba491faad84f09d5d9736c2c48a3afd5cee2f5c`，分支 `redesign-2026`。本阶段未提交、未归档、未 push；6.x/7.x 未启动。F2 的 `lib/main.dart` 启动顺序授权改动保留。

## 反馈循环与红灯

开局已用真实生产单源/聚合卡片路径建立主体命中基线；历史1.3诊断保留“read偏好单源/聚合进入ComicPage”的红灯。本阶段未删除或弱化该历史断言。5.1最小新增缺口是 `SearchResultPage` 的单源 `ComicList` 未显式使用封面平铺，默认落到全局详细模式；修复只增加 `ComicList.displayMode` opt-in，搜索入口传 `ComicTileDisplayMode.gallery`。聚合结果继续使用既有 `SimpleComicTile` 封面组件。

5.2 初始契约缺口已由 architect 裁定可最小闭合：沿 `DiscoveryPreferences` 增加 `comicDetailMode`（`information` 默认、`reading`），复用 Explore 设置和持久化；ComicPage 阅读优先默认收起“作品详情与来源”，原页展开，信息优先直接展示。未新造服务、未改变收藏/章节/阅读方案业务。未知值由 Preference 回退默认 information。当前详情测试尚未逐字段覆盖展开后的全部D7字段，已列独立复核局限。

## 红绿命令与计数

- 5.1 受影响真实主体/返回/选择回归：`/tmp/ux1-5x-search-existing.log`，11通过、0失败、0skip；单源/聚合、read/viewDetail、鼠标/键盘、一次路由、返回及选集现场均保留。
- 5.2 详情页/主体回归：`/tmp/ux1-5x-detail-green.log`，10通过、0失败、0skip；其中现有ComicDetails页面测试尚未逐字段断言新展开内容，局限不冒称为完整D7矩阵。
- 5.3/5.4 设置持久化、工作区启动/关闭、搜索过滤、真实loading/error/empty/retry回归：`/tmp/ux1-5x-234-regression.log`，25通过、0失败、0skip。日志中的受控 initial save failure/syncdata failure 是既有故障注入场景，测试最终通过，不计产品失败。
- 5.5 搜索身份/方案/过滤/键盘焦点/状态反馈及B4/F8相关回归：`/tmp/ux1-5x-55-regression.log`，50通过、0失败、0skip；与前两组不相加。

## 变更与 SHA

本阶段6个生产文件清单 `batch-4-production.sha256` 全部 MATCH：

- `lib/features/comic_widgets/comic_list.dart` `8b40713501ae30ee66684e1605df436d91c2853d6c94b87876f2206bb4e393da`
- `lib/features/search/search_result_page.dart` `74c0bd1b68f304fd4adf698823a0a109b1db3aaadce74b1815adc230ee957cf7`
- `lib/foundation/application_preferences.dart` `8457404cd805cdbd26c15f6f71e201b203371832a15b71e3a3c83df4560db68e`
- `lib/features/settings/explore_settings.dart` `5631ba84a5488524b0b570ba352d7ed432bb5f041a44ab6acb1ad175eaa38922`
- `lib/features/comic_details/comic_page.dart` `f05f2f431456cd4ccbbe3ae321cd42b94859ad15599a9341b5baa26be6589090`
- `assets/translation.json` `dcd8d43dc835a8d35baaf6787858eb6cfb1f7ebacf3d3d54c3a4d77a43759b9a`

新增文案 `Comic detail mode`、`Information first`、`Reading first`、`Works details and sources` 已补 zh_CN/zh_TW；未改 pubspec.yaml/lock、proposal/design/design-spec/正式spec/main/runner。

## 分析与保护

`fvm flutter analyze --no-pub`：`/tmp/ux1-5x-final-analyze.log`，raw/unique 50/50，38 tool + 12 既有其他；`/tmp/ux1-5x-analyze-comparison.json` `added=[]`、`removed=[]`。基线问题未清理。定向 `dart format` 已执行。`git diff --check` 与 OpenSpec validate 需由 architect 独立复核；未提交任何 protected 文件。

本阶段没有新增或修改仓库内测试文件；`batch-4-tests.sha256` 为空清单，明确不包含 stdin 的伪路径 `-`。测试命令使用的既有测试文件均未改写。

本阶段未启动可交付 GUI；旧 F2 GUI/显示会话证据不冒称5.x证据。正常 main 启动顺序修复仍按前阶段记录，未重跑无关 GUI。5.1–5.4 tasks 已即时更新，5.5 因 GUI 阻塞保持未勾，6.x/7.x 保持未勾。

## GUI 与构建收口

按实际会话只读核对：`DISPLAY=:2`、`GDK_BACKEND=wayland,x11`、`WAYLAND_DISPLAY=wayland-1`、`XDG_SESSION_TYPE=wayland`，`XAUTHORITY` 未设置，`/run/user/1000/wayland-1` 可读；`xprop -root` 对 `:2` 无法连接。当前 pane 没有可供已核准 X11 helper 使用的显示认证，因此没有启动旧 `:1` fixture，也没有把自动化或历史 F2 截图冒称本阶段 GUI。详细记录见 `batch-4-gui.md`。

正常生产 bundle 已以 `fvm flutter build linux --debug --no-pub` 成功生成，日志 `/tmp/ux1-5x-main-build.log`；这是编译证据，不替代真实 GUI。5.5 保持未勾选，待 architect 提供当前桌面的固定 GUI 访问路径后再取搜索单源、详情层级、设置重进及加载/错误场景的稳定截图与 JSON。未提交、未归档、未 push。

补充的有界 Wayland 能力探测见 `batch-4-gui.md`：系统有 `grim`/`wl-copy`/`wayland-info`，但没有 `wtype`/`ydotool`/`swaymsg`，无法在不新建 helper 的条件下完成真实键鼠动作。因此没有启动生产 bundle 冒称 GUI 通过；5.1–5.4 保持已勾，5.5 明确等待可核准的当前会话输入路径。
