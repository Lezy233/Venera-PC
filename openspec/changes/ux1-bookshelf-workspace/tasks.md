# UX1 A 书架型工作区实施任务

2026-11-25 architect 依 owner 决定调整排期：全量测试基线由本 change 承接。`ci-quality-gate-recovery` 4.4 的 64 项 HEAD 既有 CI 必挂失败按区域归入 6.x（reader-shell）、5A（workspace/bookshelf）与 5.x（favorites/search/settings），新增 7.6 作为全量测试归零任务；在 7.6 完成前，`ci-quality-gate-recovery` 4.5、`desktop-only-ci-cd` 4.3 与 `venera-pc-rebrand` 7.3 均不能勾选。

2026-11-21 owner指令归档并提交UX1 5A基本工作，未授权push。5A.1/5A.2审计与计划、Batch A–D已交付切片及标签布局/排序证据已冻结到 `../archive/2026-11-21-ux1-bookshelf-workspace-phase-4-5a-foundation/`；Batch B后续项、owner GUI复核与6.x/7.x仍未完成，本活动change继续作为契约和任务源，不整项archive或合入未实现delta。

2026-11-19 owner 澄清 `explorations/ux1-directions` A 草稿是布局、信息层级、控件组合与顶栏行数基线，并确认普通阅读工具隐藏时顶部一行、显示工具时两行，不保留独立标题栏形成第三行。当前 6.x 暂停，先完成 5A 草稿视觉对齐审计与纠偏批次确认；既有阶段功能验收和证据保留，但不自动视为视觉对齐通过。本项仅更新契约与计划，未改生产代码，未勾任何实现任务。

2026-11-18 owner已验收UX1搜索/详情及全局卡片交互阶段（5.1–5.4、5.6–5.13），授权阶段归档提交，未授权push。归档 `openspec/changes/archive/2026-11-18-ux1-bookshelf-workspace-phase-3-search-details/`；独立15/0skip、相关128/0skip（重叠不相加）、analyze raw/unique50=38+12零新增、正常构建/保护校验通过。5.5真实GUI证据保持未勾，活动change继续6.x阅读器→7.x整体验收，不整项archive或合入未实现delta。

本阶段batch-4–10交付/复核/SHA/派工记录已移入上述归档；以下历史备注中的同名文件在那里查阅。

2026-11-17 owner已验收1.3＋F2（4.1–4.5）通过并授权归档提交，未授权此次推送。包含正常main首帧顺序修复及实际显示路由排查；历史待验收/阻断记录以本次通过为最终状态。阶段快照见 `../archive/2026-11-17-ux1-bookshelf-workspace-phase-2-f2/`；5.x/6.x/7.x仍未完成，不补勾、不整项archive。

第一批已实施并记录证据；未勾项仍未完成，后续阶段须继续。每项完成后立即勾选并备注真实命令、通过/失败/skip 计数和证据；不得把探索稿检查计入生产验收。executor 不得自行修改 proposal/design/delta spec 或 design-spec，发现冲突先报告 architect。

2026-11-16 owner 已验收并授权归档、提交、推送书架壳层与 F1 阶段；归档 `../archive/2026-11-16-ux1-bookshelf-workspace-phase-1-f1/`。活动 tasks 保留全部未完成项，继续执行时以此为准；阶段快照不作为后续任务的编辑位置。

## 1. 契约、基线与最小上下文

- [x] 1.1 核对派工 HEAD、工作区和最小阅读清单；记录现有壳层、收藏、搜索、详情、阅读器、设置及持久化入口，冻结受影响生产文件和保护测试 SHA，不全库探索。
  - 2026-11-07：HEAD 6f1f1bc01ce69be91e62b9474a0b95f83a752d73 / redesign-2026，初始工作区干净。最小工件已读，入口与冻结清单见 batch-1-baseline.sha256 和 delivery-batch-1.md。
- [x] 1.2 核对 design-spec §1/3/4/7.1/7.3/7.4 已容纳 A 书架、多标签与普通阅读标签；为新增书架侧栏、标签和控件补齐 AppSizes/AppSpacing 等 token，禁止裸断点、硬编码颜色与第二套窗口框架。
  - 2026-11-07：v0.2 §1/3/4/7.1/7.3/7.4 已核；补 AppSizes 书架宽度/工具栏/导航项/舒适与紧凑封面宽度/比例 token，复用既有 breakpoint 与语义角色；analyze 暂测仍 50 项，最终具体集合复验待本批结束。
- [x] 1.3 以真实生产控件建立当前缺少多栈、预览、统一主体点击和单进度等行为的红灯；分别记录既有 analyze 50 项与测试基线，不把初始化异常当产品红灯。
  - 2026-11-07：部分：174项真实现状基线、壳层开关红灯(/tmp/ux1-shell-red.log)、密度不变红灯(/tmp/ux1-density-red.log)、键盘Escape红灯(旧matrix红灯日志已被后续宿主修复日志覆盖；8项失败为已观察历史事实，现无原始日志可独立重放，详见delivery局限)已取得。多栈/预览/统一主体/单进度尚未实施和建立完整生产红灯，留后续阶段，不勾整项。
  - 2026-11-16：复核当前生产入口：`ComicTile` 仅有主体打开/Details/后台打开菜单，没有 Space 临时预览入口；现有 `workspace_search_results_test.dart` 与 `workspace_tabs_test.dart` 的多栈、筛选、滚动、焦点和返回为局部绿，不能覆盖“所有列表统一主体点击”或 D8 单进度。尝试重跑真实控件集合时 Flutter 初始化在 `/home/_Le/fvm/versions/3.47.7/bin/cache/engine.stamp.tmp.*` 受只读环境阻断，已单列为初始化异常，未冒称产品红灯；1.3 仍未勾。
  - 2026-11-16：在权限升级后复跑既有真实生产控件对照：收藏主体/菜单/选择 `bookshelf_hit_target_test.dart` **4通过0失败0skip**；独立多栈 `workspace_tabs_test.dart` **1/0/0**；Reader slider `slider_navigation_test.dart` **2/0/0**；Reader 真实 tap 卸载保护 **1/0/0**；Reader `Space`/页进度场景 `progress dispatches image endpoints in galleryLeftToRight` **1/0/0**，合计对照 **9通过0失败0skip**。搜索结果真实场景命令在初始化后停于 `+0`、无新输出，已停止且无残留，计数不纳入通过/失败。上述绿灯证明已有局部行为，不覆盖缺失 Space 卡片预览、所有列表统一主体设置或 D8 唯一进度/漫画区域单击与独立控件不冒泡的完整场景；未改测试制造红灯，1.3 仍未勾。
  - 2026-11-16 第三批1.3闭合：生产卡片Tab→Space缺预览红0/1/0；hover复选框缺失红1/1/0（含Space绿对照）；真实两卡420px→标签栏drop缺后台标签红0/1/0，Escape拖动层缺失另红0/1/0。5.1真实单源/聚合read偏好点击得到ComicPage失配红0/2/0；6.2真实Reader两次漫画单击后隐藏进度缺失、边缘漫画单击翻页失配红1/2/0（独立亮度按钮不冒泡1绿）。后两组只在/tmp执行，完整源码/差异/命令/准确断言存batch-3-baseline-diagnostics.md，未实现5/6、不混常规suite或skip。多栈沿已验收归档delivery-batch-2开篇tabs-red真实缺New tab红→生产接入绿，本轮真实工作区预览/后台/返回/选择现场与拖放合跑37通过0失败0skip，未人为改坏已实现F1。analyze初跑52=既有50+本批两条括号lint，已修待具体集合复验；初始化/半卡裁切定位及IO等待探索均单列，不计产品红灯。日志与保护边界详delivery-batch-3。
- [x] 1.4 明确工作区快照的版本、稳定标签/实体身份、数据目录归属和可靠保存接口；用真实磁盘故障建立损坏、旧回调覆盖、写入失败与恢复红灯，不另造全局存储服务。
  - 2026-11-07：部分：复用Appdata.updateImplicit/updateSettings+SettingsSaveState，dataPath归属检查；真实implicitData.json.tmp目录阻断写入、失败可见/新意图覆盖/磁盘重载通过。标签快照v1稳定身份、损坏恢复、跨目录旧回调尚需3.x真实生命周期落实，不以书架布尔偏好冒称工作区快照契约完成。
  - 2026-11-16：已核对生产契约入口：`WorkspaceRecord.version == 1`、稳定 tab/route/entity identity、directory 校验、`WorkspaceStore.assignment` 的 Appdata 写入归属与过期 owner 防护、`SettingsSaveState` Retry 均存在。权限升级后真实命令 `/tmp/ux1-13-14-storage-protection.log` **10通过0失败0skip**：版本/稳定身份与 malformed/duplicate/foreign-directory 拒绝、真实 `.tmp` 目录写入故障、Retry 最新快照、旧 assignment 与新目录 owner 覆盖防护、A→B→A 目录生命周期、坏 view/unknown route 一次回退及实体保留均通过。日志中的 `FileSystemException` 是测试主动建立的磁盘故障红灯，随后恢复断言通过；新 PID 重启仍属 3.5 范围，不在本项冒称已证。

## 2. A 壳层与收藏视觉切片

- [x] 2.1 实现可收起书架侧栏与右侧工作区，接入 macOS 交通灯旁开关、工作区搜索/历史位置及既有导航；页面不自造窗口框架，不实现分屏。
  - 2026-11-07：实现接入 MainPage/NaviPane、复用 WindowFrame；SafeArea消费既有标题栏留白；全局搜索与收藏内部栏控制分开。WindowFrame真实坐标/无重叠断言与compact菜单复验见/tmp/ux1-titlebar-green.log：31通过0失败0skip，标签本体按阶段归3.x；GUI最终证据归2.4。
- [x] 2.2 实现窄窗口覆盖侧栏、遮罩/Escape 关闭和宽窗口偏好还原；验证进入窄窗不重建当前内容，恢复宽度不丢失选择、滚动和焦点。
  - 2026-11-07：bookshelfExpanded宽窗偏好使用既有updateImplicit/SettingsSaveState；compact覆盖/遮罩/Escape/焦点域单独处理。键盘矩阵发现8项compact Escape红灯后修复，/tmp/ux1-matrix-green.log 26通过；加入真实WindowFrame和compact菜单后/tmp/ux1-titlebar-green.log 31通过0失败0skip。GUI最终证据归2.4。
- [x] 2.3 在收藏首页 + 作者 shelf 小切片实现舒适默认/紧凑可选、封面网格和一致 hover/pressed/selected/focus/disabled；保护 F10 三态与独立排序、F11 分组折叠、B4 命中和 F5 多选。
  - 2026-11-07：舒适/紧凑密度共用token布局，收藏新默认画廊，保留已有显式列表选择；新样式仅收藏网格/作者shelf，通用画廊不提前迁移。/tmp/ux1-regression-final.log 274通过0失败0skip（含F10/F11/B4/F5、真实hover/长按/150%文本行）；多选主体语义按architect确认留4.3，不是最终豁免。
- [x] 2.4 完成本阶段 expanded/medium/compact、浅深主题、150% 大文字、简繁文案、键盘与减少动画测试及 GUI；新增文案 `.tl` + zh_CN/zh_TW，无溢出或业务回退。

  - 2026-11-07：最终源码GUI PID77565；1400×900完整Flutter帧与cropped X11分列；1000×700/600×700浅深、简繁、150%、减少动画及鼠标打开/Escape关闭截图见delivery。24组合生产控件矩阵通过；受控ThemeData不是动态取色实机证明，macOS与GUI全排列未验证。最终analyze raw/unique50=38+12，具体集合零增减。

  - 2026-11-08 补证完成：真实MainPage收藏State/Element/Controller、两卡身份、420px与原FocusNode返回及卸载query绑定测试通过；最终16生产文件冻结，执行者248相关回归通过，architect独立293通过，均0失败0skip。A–F真实GUI保持两实体/同page/controller/214.9585px/精确原焦点，G为最终深色繁体150%完整Flutter帧；正常main重建和fixture清理完成，analyze raw/unique50=38+12具体集合零增减。2.2/2.4恢复勾选；旧14文件与274仅历史阶段。内层Navigator全局Tab可达外层未验证，不冒称通过，详见delivery最新权威段。

## 3. F1 多内容栈与标签

- [x] 3.1 实现稳定标签身份、独立内容栈和当前标签激活；每栈保存页面/实体、来源/方案、关键词、筛选、多选、滚动、焦点返回、详情展开和阅读位置，切换互不重置。
- [x] 3.2 实现当前打开、后台打开、标签内返回和 Alt+Left；验证返回恢复完整原现场且不等于关闭，后台创建不抢占当前页。
  - 2026-11-09 architect 补充 owner 已选边界：封面大图等辅助页运行期保留真实路由/切换现场/返回关系，覆盖时停用父页；仍须生产控件测试，不因裁定勾选任务。
  - 2026-11-16：3.1/3.2 真实红→绿证据已在 delivery-batch-2 分段留存；3.1 覆盖稳定 ID/独立栈、搜索/聚合来源与关键词/筛选、收藏多选滚动焦点、详情展开、Reader 章节页码；3.2 覆盖当前/后台打开、Alt+Left、Navigator.replace、ComicCoverViewer 运行期辅助栈、父页 inactive、返回关系与后台不抢占。未将 3.5 新 PID 恢复、3.6 后台资源计数或 F2 预览并入本勾选。
- [x] 3.3 实现标签横向滚动、「全部 N」列表、稳定关闭命中区和键盘操作；当前关闭常驻，非当前悬停/焦点显现，无滚动箭头和布局跳动。
  - 2026-11-15：标题增量复验补齐Reader标签完整名称；真实双Reader全部N列表、旧v1磁盘标题迁移、缺源保名及本地Reader路由回归4通过，标题请求计数无新增，analyze50具体集合零增减。
  - 2026-11-09：真实MainPage长标题右键后台建栈、1400/1000/600浅色100%与深色150%横向PointerScroll、全部N完整文本/待激活与键盘选择、hover完整Tooltip、非当前Tab焦点显现关闭+Enter正确实体关闭均通过（/tmp/ux1-batch2-tab-input-close-scene-loop.log 2通过0失败0skip）；原两卡/420/同State/controller/焦点返回保留，键盘遍历卡片自然滚动后关闭严格保留动作前offset。真实Reader全局Tab陷阱先红后以正常内容scope parentScope修复，ShiftTab返回原画布并保持页码/一次请求，退出等待scope不变（reader-tab-traversal-loop 1绿；replace-focus-protection 29绿）。600宽150%恢复反馈缺Material文字继承导致504px占高，已只修工作区容器，详情未重排。平台默认/输入不吞键沿keyboard/registry既有绿保护；GUI整批与新PID尚待3.5/7.x，不冒称已验。
- [x] 3.4 实现关闭后最近浏览默认及右侧/左侧设置；未查看后台标签不进入最近浏览，无目标时有可用空态，关闭非当前标签不抢占内容。 备注：2026-11-08 关闭策略/空态真实控件已闭合；Settings→APP选left/right并磁盘重载、三标签CtrlW邻居对照，非当前hover/坐标关闭保留A原焦点/两卡/420px/实例；仅未看后台剩余空态可真实Open favorites且0请求。close-policy红1绿1→修关闭后误记焦点→close-focus-loop3绿，close-regression10绿0失败0skip。曾因save-recovery合跑关闭controller提前dispose异常重新打开；现先卸载子树再帧后释放，close-dispose-green4绿、同一save-recovery-green21绿0失败0skip，已再次闭合。整个F1及7.x GUI、新PID、阅读器退出边界仍待后续。
- [x] 3.5 实现默认恢复上次标签/收藏首页可选策略和可靠快照；真实磁盘重载、损坏回退、快速操作、写入失败、数据目录切换与新 PID 重启通过，修改策略不立即清除当前会话。
  - 2026-11-09 architect 补充 owner 在 executor 问答中选择「运行时保留；重启回父页并反馈」：仅不可序列化辅助页恢复最近可恢复父页、一次反馈且其他标签不丢失；详见 D9 与 workspace/tabs delta spec。实现与恢复证据尚待，不勾任务。
  - 2026-11-16：当前已有真实磁盘/损坏/Retry/目录归属与辅助页同进程恢复绿灯，但 D9 强制的真实终止进程→新 PID restore/fresh 尚未执行；不可序列化辅助页同进程回父页反馈不能替代新 PID。3.5 保持未勾。
  - 2026-11-16 最新闭环：真实 rich PID255580→266168→269207、宿主时序对照275351→277155→281091均经生产关闭exit0（含末281091，全部正常关闭）；同隔离目录5tab/route ID、views/active/recent磁盘等式、收藏book-3/book-4选集159px/focus、Alpha/other搜索212px、book-6 ep-1第2页实际State/解码图及仅当前来源请求通过。真实封面辅助页退出后277155回book-2父页并一次反馈，269207此前证明不重复反馈；设置fresh后五标签未清，281091新PID仅Favorites/零来源请求。时序对照挂载1000×700，新增Flutter异常0，原首帧异常单列为/tmp harness时序；工具42bd1cd8…/7c38817b…已核准，全部截图/JSON与命令详delivery最新段，GUI场景不计作Flutter测试。磁盘/故障保护10通过0失败0skip、设置1通过0失败0skip沿准确日志；正常main构建/清理收尾单独记录，不涵盖F2或最终owner验收。
- [x] 3.6 实现后台详情首次激活加载、后台阅读器休眠和共享缓存；用请求/加载计数证明批量后台打开不立即整批请求，标签切换与关闭不重复加载或丢页码。
  - 2026-11-16：`/tmp/ux1-35-36-background.log` **1通过0失败0skip，6秒**：真实右键菜单创建三后台详情，创建阶段零详情请求/不进MRU，逐一首次激活各请求一次，复访不增请求并保持实体/页面。既有 `/tmp/ux1-batch2-reader-exit-freeze-loop.log` **1通过0失败0skip** 与 `/tmp/ux1-batch2-auxiliary-navigation-protection.log` **15通过0失败0skip** 保留真实 Reader 后台自动阅读暂停、输入/新请求拒绝、章节页码、同 State/viewport、直接关闭资源与一次通知断言；共享图片/请求缓存计数和关闭不重复请求均有现场。Reader state 单跑因 `flutter_memory_info` MissingPlugin 后无最终输出，已停止，不计失败；不影响上述独立计数。3.5 新 PID、F2、5.x/6.x 未并入本项。

## 4. F2 临时预览与多选拖放

- [x] 4.1 实现 Space 临时预览、概览/目录/详情、左右切换及 Space/Escape 关闭；预览不创建标签，关闭后焦点回到原卡片，滚动与多选保持。
  - 2026-11-16 第三批：真实卡片Tab→Space缺入口红0/1/0，生产最小预览与同组目标接入后，`/tmp/ux1-b3-preview-matrix.log` 28通过0失败0skip（24个600/1000/1400×浅深×简繁×150%×减少动画组合、同ID跨来源乱序/卸载晚回调、独立选择、基础左右/Escape和真实MainPage两卡/420px/原焦点/同实例）。预览无新标签/栈/历史，仅按当前目标加载必要详情；Space不吞输入框。GUI归4.5仍待，非整批已验收。
- [x] 4.2 实现预览 Enter 当前标签打开、Cmd/Ctrl+Enter 后台新标签；与漫画主体打开共用历史规则，关闭预览不误触底层卡片。
  - 2026-11-16：同`workspace_preview_test.dart`真实MainPage生产控件（包含上项28绿，不重复累加）：Ctrl+Enter准确新建后台实体/sourceKey，当前选集/420px/焦点不抢占、后台详情0提前请求；Enter在原标签只push一次详情，Alt+Left返回原现场且标签数不减，预览关闭未透到底层。Meta平台与GUI增量归4.5补；旧Enter实现不存在于HEAD，首个Space入口红灯是整条预览提升入口的前置缺口。
- [x] 4.3 实现平铺卡片右上角复选框的悬停/焦点显现、选中常驻、图形与语义状态及 Escape 清空；复选框只选择，主体仍遵循全局点击设置。
  - 2026-11-17：hover/focus显现、离开后选中常驻、真实Tab→Checkbox Space与checked语义、Escape均通过；`checkbox-semantics-green`1/0/0。搜索/聚合复选框Enter隔离`result-checkbox-enter-green`34/0/0；B4主体原全部真实文本行/封面/read与detail/一次路由/实体断言保留迁移，选集不令另一主体变为选择。F1原现场保护24/0/0，continuity单项1/0/0；F10/F11仅旧建场迁移为独立checkbox，80/1历史后F11定向1/0/0。非收藏主体全局设置统一仍属5.1，其现状失配保留1.3诊断，不在本批扩5.x。GUI两卡/滚动/原FocusNode及简繁150%见delivery。
  - 2026-11-17 architect复核：上条仅证明checkbox/收藏行为，单源/聚合read偏好仍打开ComicPage，4.3主体契约尚未闭合，撤销整项勾选。原5.1诊断红灯完整保留；待architect裁定F2卡片沿用既有onClickFavorite的必要最小依赖，不扩搜索布局/详情/设置/阅读工具。
  - 2026-11-17 必要依赖获architect批准并闭合：ComicTile/SimpleComicTile默认主体及普通Enter复用既有onClickFavorite，typed reader builder在原runtime注入；自定义onTap优先，显式Details/预览提升/后台详情保持详情。原真实主体0/2红保留；新路由标题4绿4红后仅补可选已知title及workspace透传，8/0/0；主体/独立控件/B4合跑19/0/0，read偏好预览提升1/0/0，Reader标签/通用B4保护93/0/0，architect独立相关123/0/0。GUI PID836728真实设置read→单源搜索→checkbox选中→标题点击→已解码Reader page1→AltLeft回原选集/焦点/滚动实例，详情/章节各一次且搜索不重发。具体证据见delivery末段；不勾5.1，不改搜索布局或设置文案，不扩6.x。
- [x] 4.4 实现多选拖入标签栏、拖动 Escape 取消及按钮/菜单/键盘等价入口；每部形成后台详情标签，不改变收藏身份、作者顺序或来源配置。
  - 2026-11-17：普通网格真实拖放/释放前Escape取消、菜单和Ctrl/Meta+Enter等价入口通过；当前`workspace-final-green`7/0/0含三宽150%/两来源身份、原两卡420px/同实例/焦点、零后台提前请求。GUI真实drop两后台及取消无新增亦成立；作者栏既有长按重排与选集拖出手势划分仍等待owner，未改该手势，不勾整项。
  - 2026-11-17 owner裁定独立手柄后：作者标题区44px手柄与卡片长按/checkbox物理分离；真实坐标红灯0/1/0（预期3标签实际1）后最小实现。`author-handle-protection.log`58/0/0含原F10/F11；最终`author-handle-final.log`3/0/0覆盖折叠600深繁150%、正常1000浅简150%、展开1400浅英文、手动/系统减少动画条件、跨作者同实体/同ID不同来源、空选集禁拖、点击隔离、Escape取消零新增、drop准确两后台零提前请求、同页/焦点/滚动/成员保持，以及选中卡片原长按只重排Beta、Alpha不变。真实Tab到手柄Ctrl+Enter等价入口通过，原菜单/Meta入口证据保留不重复；本增量GUI/最终分析构建归4.5与delivery待闭合。
- [x] 4.5 完成预览与拖放的键盘、焦点、窄窗、大文字、浅深主题、减少动画及后台请求计数验证；浮层可滚动且关闭入口始终可用。
  - 2026-11-17：预览/普通网格已覆盖三宽、浅深、简繁150%、手动OR系统Reduce motion、真实拖放/菜单/Ctrl与Meta等价入口和请求计数；GUI对应F6实际scale/system值、滚动/实体/焦点、完整Flutter帧与宿主帧分列。普通网格compact拖放保存等待已闭环，混来源拖放1/0/0；作者栏手势仍待owner，故本项及4.4暂不整项勾选，不宣称完整F2。
  - 2026-11-17 作者栏续派闭合：最终作者手柄三宽/三态/简繁150%/手动与系统减少动画条件真实控件3/0/0，含Tab焦点/Ctrl+Enter/取消/长按独立排序，原预览完整矩阵不重复。architect独立相关60/0/0；GUI PID1102014正常1000×700完整X11/Flutter帧，实际checkbox选择book0/book1，标题手柄Escape取消3标签不变、drop3→5准确两后台，F6-1/2/3的页面/选集/原焦点668761396/全部scrollState与offset/active/recent保持，details/chapter均0；三稳定图及JSON已独立抽查。GUI仅受控单作者单来源、offset0，本项跨作者/来源及非零滚动保护见生产控件测试和既有GUI分列，不冒称本图覆盖。analyze新源码raw/unique50=38+12逐条零增减；正常关闭exit0、宿主PID/X11无残留，main恢复构建及最终清单见delivery。
  - 2026-11-17 owner正常启动退回后闭环：未包装main精确复现right15×2/bottom15×1及native900×600等待1×1，trace首帧1×1定位到window_manager原生resize边缘。architect授权仅将既有placement.initialize await移至runApp前；同目录及全新四XDG正常main实际900×600画面均绿，trace首帧900×600。独立启动宿主32通过0失败2既有Windows专属skip，非0skip；analyze50逐条零增减，正常main kernel4100dcba…/入口匹配，五自有诊断PID清理且owner同名窗口保留。当前19生产/31测试/139证据全部独立MATCH，main非零diff仅本次授权顺序两行。完整命令/creator/假设与工具局限见batch-3-startup-diagnostics.md；architect最终启动修复符合，等待owner重试验收，未提交归档push。

## 5. 搜索、详情与设置一致性

- [x] 5.1 将搜索默认结果改为封面平铺，并把现有「点击收藏」设置扩展为所有漫画列表的统一主体行为；独立控件不误触，直接阅读和进入详情均保持正确历史。
  - 2026-11-18：真实SearchResultPage单源结果改为显式gallery平铺；聚合SimpleComicTile封面路径保留。F2主体/返回/选择回归11通过0失败0skip（/tmp/ux1-5x-search-existing.log）；此前1.3主体失配红灯保留为历史。
- [x] 5.2 实现详情信息优先默认与阅读优先可选；两版保留标题、作者、来源、分类、状态、继续阅读、收藏、简介和章节，阅读优先作品详情默认收起且可展开。
  - 2026-11-18 architect批准最小契约实现：DiscoveryPreferences.comicDetailMode（information默认/reading），Explore现有设置入口与双中文文案；ComicPage阅读优先默认收起“作品详情与来源”，可在原页展开，信息优先直接展示，未改收藏/阅读/章节业务。详情页/主体回归10通过0失败0skip（/tmp/ux1-5x-detail-green.log）；现有ComicDetails页面测试未覆盖完整展开文本逐字段断言，作为独立复核局限保留。
- [x] 5.3 实现收藏密度、详情层级、关闭跳转和启动策略的设置入口、可靠保存与重进/重启一致；设置作用范围清晰，不互相覆盖或改写业务数据。
  - 2026-11-18：现有Preference/WorkspaceStore真实持久化回归25通过0失败0skip（/tmp/ux1-5x-234-regression.log）；详情层级由5.2的comicDetailMode实现覆盖，保存/重进仍沿现有SettingsSaveState与WorkspaceStore边界。
- [x] 5.4 实现首次加载骨架、更新中旧结果、无结果恢复和更新失败旧结果/打开/重试；提示靠近上下文且不循环 toast，关键词、筛选和选择保持。
  - 2026-11-18：真实ComicList/SearchResultPage loading/error/empty/retry/过滤/关键词现场回归25通过0失败0skip（/tmp/ux1-5x-234-regression.log）。
- [ ] 5.5 完成搜索/详情真实控件、状态反馈、收藏切换、层级/标签现场保持及 F6/F7/F8 搜索身份回归；所有新文案 `.tl` + zh_CN/zh_TW。
  - 2026-11-18：搜索身份/方案/过滤/键盘焦点/状态反馈及B4/F8相关回归50通过0失败0skip（/tmp/ux1-5x-55-regression.log），与25/11集合不相加；自动化已绿，但本阶段真实正常main GUI尚未取证，故不勾整项。
- [x] 5.6 修复搜索及其他平铺列表的漫画封面比例，完整显示原始封面内容并保持现有列数、密度、标题与交互命中区；覆盖不同宽高比、响应式宽度和大文字场景，避免以裁切或横向固定卡片掩盖问题。
  - 2026-11-18：真实生产 `ComicTile` 以 2×1 与 1×2 受控封面建立红灯：旧 `AnimatedImage` 忽略显式 fit 且平铺调用 `cover`，实际断言 `fit == contain` 失败；最小修复让 `AnimatedImage` 尊重调用方 fit，并使 `ComicTile` gallery/brief 平铺使用 `BoxFit.contain`。`search_cover_ratio_and_single_drag_test.dart` 2/0/0 绿，受影响保护合跑 `/tmp/ux1-5x-567-protection.log` 16/0/0；保留现有列数/标题/主体与独立控件命中。测试覆盖两个纵横比，响应式/150% 仍依赖既有生产矩阵与 GUI 环境，未冒称本轮 GUI。
- [x] 5.7 支持未选择单张漫画主体直接拖到标签栏后台打开；一次仅创建该漫画详情标签，保持当前页、选择、焦点、滚动、来源身份与请求现场，且不冒泡为单击、复选框切换或作者栏排序；保留既有多选拖放、菜单、键盘、Escape取消和正确 id/sourceKey/hero。
  - 2026-11-18：真实生产 `ComicTile`→`WorkspaceTabStrip` 坐标指针拖动旧红灯：未选择时 `ComicSelectionDrag` 没有 routes，标签栏不产生后台路由；最小修复允许无选择主体生成单一 `WorkspaceComicDrag`，多选仍优先使用 selectedGroup。新增生产控件测试 2/0/0，保护合跑 `/tmp/ux1-5x-567-protection.log` 16/0/0；断言单一 comic route、id/sourceKey，未触发主体 tap。已有多选/菜单/键盘/Escape/作者手柄保护分列保留。
- [x] 5.8 修复收藏界面单张未选择漫画拖到标签栏无效的问题；覆盖收藏主网格、网络收藏和作者栏实际入口，保持多选拖放、作者栏独立手柄/长按排序、复选框、菜单、主体点击和正确实体身份不冲突。
  - 2026-11-18：四假设核对：①作者 shelf 的 `ComicTile(enableSelectionDrag: false)` 确认为独立长按排序入口，选集拖出只走独立手柄；② `DesktopWorkspace` 确实提供 `WorkspaceNavigationScope`，主收藏/网络收藏共用 `SliverGridComics → ComicTile`；③ `WorkspaceTabStrip` 已注册 `DragTarget<WorkspaceComicDrag>`；④作者栏长按竞争未改动，F10/F11 保护保留。主/网络共用生产网格真实坐标红灯见 `/tmp/ux1-5x-58-red.log`，未选择时旧 selected gate 无后台路由；沿5.7最小修复后的生产回归 `favorites_single_drag_test.dart` 1/0/0 绿，实体 `favorite-1/network-a`、一次路由、未选中断言保留。相关保护合跑 `/tmp/ux1-5x-58-protection.log` 33/0/0；作者栏单卡主体不作为选集拖出入口，独立手柄/长按排序由既有 F10/F11 测试覆盖，入口边界已记录。
- [x] 5.9 移除普通收藏/网络收藏及其他网格卡片主体旧长按选中与范围选中；统一使用 4.3 复选框、菜单和键盘选择，保留作者栏独立手柄、栏内排序和详情页必要长按行为。
  - 2026-11-18：移除 `local_favorites_page.dart` 与 `local_comics_page.dart` 传给 `SliverGridComics` 的主体 `onLongPressed` 选择/范围选择回调；ComicTile 默认长按菜单、作者栏独立手柄/栏内排序、ComicPage quickFavorite 未改。生产网格长按回归 `/tmp/ux1-5x-59-green.log` 1/0/0，B4 收藏命中 `/tmp/ux1-5x-59-hit-target.log` 4/0/0；ownership 迁移后的 transfer 34/34、confirmation 目标用例 1/1 通过。旧回调路径的红灯由 owner 缺陷现场和本轮前置实现对照确认，最终真实控件断言 selected 集合不变；checkbox、多选菜单/键盘/Escape 与 F10/F11 保护分列保留。
- [x] 5.10 移除工作区首页切换/自动快照保存时的圆形保存进度和“已保存”成功浮层；自动保存继续执行，保存失败提示与重试能力保留，设置页及必要的显式保存反馈不受影响。
  - 2026-11-18：`SettingsSaveState.withSettingsSaveFailureFeedback` 新增失败专用壳层；`BookshelfWorkspace`/`DesktopWorkspace` 自动保存只保留失败 Retry，不显示 pending spinner 或成功 Saved。真实首页 toggle + 阻塞 AppDataOperations 的回归 `/tmp/ux1-5x-510-green.log` 1/0/0；旧 `withSettingsSaveFeedback` 回放红灯 `/tmp/ux1-5x-510-red.log` 可见 CircularProgressIndicator。设置页 `settings_save_feedback_test.dart` 及保存失败/Retry保护保持。
- [x] 5.11 统一桌面卡片交互：漫画卡片主体长按不再触发移动端遗留的上下文菜单，真实 secondary pointer/button 仍可触发；复核 4.4/5.7 单卡与多选后台拖放、5.10 自动保存反馈在搜索、收藏、本地漫画、历史和作者栏入口的一致性，保留作者栏独立排序/选集手柄。
  - 2026-11-18：根因是 `ComicTile._onLongPressed` 在无自定义回调时无平台分支，桌面主体长按仍调用默认 `showMenu`；`onSecondaryTapDown` 已走同一 `showMenu`。最小修复在 `lib/features/comic_widgets/comic_tile.dart` 仅对桌面默认主体长按返回，保留移动端默认长按菜单、secondary pointer 菜单及自定义 `ComicPage.quickFavorite`。真实生产网格红灯 `/tmp/ux1-5x-511-red.log`（修复前主体长按可见 Details，secondary 同菜单），绿灯 `/tmp/ux1-5x-511-green.log` 1/0/0（主体长按无菜单、secondary 仍可见 Details）。F2/F5/F8/F10/F11/B4/5.10 有界保护 `/tmp/ux1-5x-511-protection.log` 91/0/0；作者 shelf 独立手柄/栏内长按排序未改，历史入口 `onLongPressed:null` 与详情页专用长按保持。搜索、网络/本地收藏、历史均复用 `ComicTile` 默认路径；作者 shelf 使用独立拖动语义。GUI 仍受当前 Wayland/X11 输入访问限制，未冒称桌面 GUI 证据。
- [x] 5.12 为搜索结果增加与收藏一致的“画廊/列表”切换；默认画廊，保持关键词、筛选、滚动、选择、标签身份和主体/复选框/拖放语义，复用既有显示控件、持久化和翻译，不重建卡片视觉系统。
  - 2026-11-18：单源/聚合真实入口缺失红灯 `/tmp/ux1-512-entry-red.log`、`/tmp/ux1-512-aggregate-red.log` 各0/1/0；复用参数化 FavoriteDisplayButton 和独立 DiscoveryPreferences.searchDisplayMode（默认gallery），不改 FavoritePreferences.displayMode.key/列数。聚合保留来源分组和进入单源入口，gallery沿原SimpleComicTile、list复用detailed SliverGridComics。真实菜单/checkbox/双向切换、两来源请求、同State/控制器/120px选集、磁盘保存/重载List和MainPage同tab/420px/筛选/返回合跑 `/tmp/ux1-512-state-green.log` 2/0/0；搜索/F2/F8/B4/F10/F11保护 `/tmp/ux1-512-protection.log` 111/0/0（重叠不累加）。analyze `/tmp/ux1-512-analyze.log` raw/unique50=38+12具体集合added=[]removed=[]；正常main构建、diffcheck、OpenSpec通过。当前5生产/2测试SHA与全部命令见delivery-batch-9.md；GUI输入访问局限保留，5.5仍未勾，不冒称GUI或新PID证据。

- [x] 5.13 修复搜索画廊大片留白，严格复用收藏普通画廊的自动列数、卡片/纵向封面槽位、标题、行列间距与外边距；单源及聚合分组均适用，同可用宽度/文字缩放/密度下几何一致，保留完整封面、独立模式记忆及搜索现场。
  - 2026-11-18：真实生产搜索/收藏600/1000/1400×100%/150%×comfortable/compact几何红灯 `/tmp/ux1-513-geometry-red.log` 0/12/0。根因是显式gallery的renderer已为bookshelf，但galleryColumns=null令委托走横向列表布局；600舒适下搜索1列592×144/槽位576×88.8，收藏4列142×264.59/槽位126×209.39。仅为显式gallery传自动列数0后单源12组一致，聚合仍红；聚合gallery复用原SliverGridComics后两者与收藏同几何。最终 `/tmp/ux1-513-geometry-final.log` 14/0/0，含12组实际rect/列数/标题/间距边距、68×100和160×60真实解码四边像素完整性及5.12偏好隔离/磁盘/现场；具体原始值见batch-10-geometry.json。保护 `/tmp/ux1-513-protection.log` 128/0/0（含前14，重叠不累加），保留同State/controller/tab/scroll/selection/请求及F2/B4/F8/F10/F11。analyze50/50=38+12 added=[]removed=[]，正常main构建/diffcheck/OpenSpec/SHA通过；2生产/2测试与命令见delivery-batch-10.md。无新GUI/fixture，5.5仍未勾，未提交归档push。

## 5A. 草稿视觉基线对齐（2026-11-19 新增）

本阶段交付文件与 DOM 证据已移至 `../archive/2026-11-21-ux1-bookshelf-workspace-phase-4-5a-foundation/`；下列文件名均相对于该归档目录。

- [x] 5A.1 对照 `explorations/ux1-directions` A 草稿与正常生产 main，审计壳层、收藏、搜索、详情、临时预览和阅读器的布局、信息层级、控件组合及顶栏行数；覆盖 expanded/medium/compact，以及普通阅读工具隐藏／显示和沉浸阅读，保留真实 GUI 差异证据，不在审计中修改生产代码。
  - 2026-11-20：基于当前 HEAD `d25642a` 完成审计。ego lite 取得探索稿 A 方案 8 组页面级截图与 DOM（`evidence-5a-1-draft-dom.json`，截图留在 `/tmp/ux1-5a-1-draft-*.png`）；当前分支 Debug 产物取得 expanded/medium/compact 收藏、详情、普通阅读器及阅读器点击复核截图（`/tmp/venera-front-2.png`、`/tmp/venera-medium.png`、`/tmp/venera-compact.png`、`/tmp/venera-after-card.png`、`/tmp/venera-reader.png`、`/tmp/venera-reader-tools*.png`）。空壳根因是权限提示/旧安装实例；阅读器点击后工具行未出现的真实差异已记录，交由 5A.2 分类，不代表视觉纠偏通过。详见 `delivery-5a-1.md`。
- [x] 5A.2 architect 将差异按保留、调整、重构分类，提出逐页、单会话可完成的纠偏批次和对应验收场景；owner 确认后方可实施或继续 6.x。既有功能验收记录不得改写为视觉对齐通过，本项勾选只代表纠偏计划已获确认，不代表视觉纠偏已完成。
  - 2026-11-20：完成 `delivery-5a-2.md`。差异已分为保留/调整/重构，提出 Batch A（合并顶栏与断点壳层）、Batch B（收藏/作者/搜索/详情层级）、Batch C（预览浮层焦点）、Batch D（阅读器 chrome 与全局收尾），每批含 expanded/medium/compact 和键盘/主题/大文字/减少动画验收场景。owner 确认前不实施、不继续 6.x；既有功能验收不改写为视觉对齐通过。
  - 2026-11-20：按 owner 指令执行 Batch A 首个实现切片；生产三档 GUI 截图 `/tmp/ux1-batch-a-expanded.png`、`/tmp/ux1-batch-a-medium.png`、`/tmp/ux1-batch-a-compact.png` 已取得，合并顶栏层级与命令中心断点行为可核验。实现与验证记录见 `delivery-batch-a.md`；Batch B–D 仍待后续确认/排期。
  - 2026-11-20：owner 指令执行 Batch B；先完成收藏首屏筛选摘要切片，详情页以真实 GUI 作为基线，搜索 pinned 栏/滚动/焦点保护保持不变。验证与未完成范围见 `delivery-batch-b.md`；Batch B 尚未整体闭合。

## 6. 阅读器与全局可访问性

- [ ] 6.6 修复快捷设置中阅读方案选择无法持久化的问题；沿用现有 ReaderPresetStore/ReaderPreferenceStore 绑定和失败恢复，覆盖关闭面板、切换章节、重新进入 Reader 与 B3/F9 方案排序/继承保护。
  - 2026-11-18：owner新增缺陷，待 executor 建立真实方案选择红灯并验证磁盘/绑定恢复。
- [ ] 6.7 调整精简工具形态：仅保留一条不浮在漫画上方的窄横向进度线，精简形态移除上一章/下一章按钮；完整工具形态保留原进度与章节操作，覆盖主题、150%、减少动画和键盘语义。
  - 2026-11-18：用户复验发现上一版仍以 Stack overlay 覆盖漫画；已取消勾选并保留 `/tmp/ux1-reader-67-layout-red.log`（workspace场景在自动阅读恢复处 timeout）。当前生产修复把精简 `ReaderBottomBar` 放入 scaffold body 的 `Column(Expanded(content), compactBar)`，保留完整/精简相同105px布局基准；精简轨道视觉3px、命中区48px，移除 BlurEffect/背景/边框和章节按钮。独立 A 几何/无模糊测试 `/tmp/ux1-reader-67-ab-green.log` 1/0/0；真实 workspace B 对照 `/tmp/ux1-reader-67-ab-workspace.log` 仍 timeout，故不勾。
  - 2026-11-20 Batch D 追加：精简栏改为真实48px布局槽，完整工具栏覆盖显示以保持漫画内容列几何稳定；沉浸切换改为 post-frame native window 调度并增加 reader 生命周期守卫。GUI 与完整 reader_exit 矩阵仍待复验，暂不勾。
  - 2026-11-21：精简栏进一步收敛为 8px 自绘单线，移除 thumb、overlay、底部安全区及额外命中槽，工具展开时同步保留 8px 底部几何；`bottom_actions_test.dart` 18/0/0、相关 analyze 无新增问题。GUI 与 reader_exit 矩阵仍待复验，暂不勾。
  - 2026-11-21 追加：精简轨道视觉填充及点击/拖动映射均遵循 `reversed`，右向左阅读时从右侧增长；新增方向回归场景，`bottom_actions_test.dart` 19/0/0。


- [ ] 6.1 实现普通阅读保留合并工作区标签行、沉浸阅读隐藏标签及模式切换现场保持；普通阅读工具隐藏时顶部一行、显示工具时两行，不叠加独立标题栏，单击只切换阅读器工具行；保护阅读方案绑定、翻页与 B3/F9/B5 行为。
  - 2026-11-18 当前实现已由真实 workspace Reader 红→绿 `/tmp/ux1-reader-61-green-loop-2.log`、最终联查 `/tmp/ux1-reader-61-63-final-loop.log`（各1/0/0）证明沉浸入口、标签/书架 chrome 隐藏、Escape恢复、同Reader/标签/章节页码/请求及后台休眠现场；完整 reader_exit 保护仍有未迁移断言，故不勾。
- [ ] 6.2 移除闲置 2 秒自动隐藏，接入漫画任意位置单击切换工具；独立按钮、菜单、章节与文本控件不冒泡，底部始终只有一条进度组件，隐藏工具时为精简形态。
  - 2026-11-18 真实边缘 tap 红灯页码2→3 `/tmp/ux1-reader-62-edge-red.log`；改为任意漫画 tap 只切工具、同一 `ReaderProgressSlider` 保留并可命中、3秒不自动隐藏。workspace 联查 `/tmp/ux1-reader-61-63-final-loop.log` 1/0/0；旧 reader_exit 方向断言迁移仍需独立复核。
- [ ] 6.3 实现章节右侧覆盖浮层和 Escape 顺序：先浮层、再沉浸、普通模式可找回工具；不改变漫画尺寸，不一次按键跨越两级。
  - 2026-11-18 章节真实按钮/浮层/画布 rect/两次 Escape 现场已在 `/tmp/ux1-reader-63-green-loop-2.log` 通过；另完成 `_workspacePresentationActive` 边界修复与窗口恢复单项 `/tmp/ux1-reader-window-recovery-loop.log` 1/0/0，完整 reader_exit 仍待迁移保护复核，故不勾。
- [ ] 6.4 核对浅深主题无阅读器深色例外、动态强调色不染封面/整片内容；手动与系统减少动画、150% 大文字、键盘焦点和语义在全部新页面一致可用。
- [ ] 6.5 完成阅读器真实坐标/键盘测试和 GUI：连续单击、工具内点击、普通阅读一行／两行顶栏与沉浸单行工具、单进度、章节 Escape、普通/沉浸标签、后台休眠与页码恢复，逐图核对无第三行独立标题栏或 overflow。

## 7. 整体验收与交付

- [ ] 7.1 按 acceptance-checklist.md 执行完整 owner 场景矩阵；所有项目实施项有生产行为测试和 GUI 证据，不以探索稿、helper 属性或内存重新构建 替代真实动作。
- [ ] 7.2 运行全部受影响既有回归并保留原语义断言；`flutter analyze --fatal-infos --fatal-warnings` 零问题（`ci-quality-gate-recovery` 后基线已从 50 降为 0），新增测试 0 skip，既有失败与基线单列，不借返工修无关问题。
- [ ] 7.3 在 expanded/medium/compact、浅深主题、150% 大文字、简繁、减少动画下完成生产 GUI；真实终止进程并以新 PID 验证工作区恢复，正常 main 构建恢复并精确清理 fixture/进程。
- [ ] 7.4 核查所有新增文案 zh_CN/zh_TW、设计契约与 delta spec 一致、保护文件零非授权 diff、`pubspec.lock` 未重生成、截图不入库、git diff --check 与 `openspec validate ux1-bookshelf-workspace` 通过。
- [ ] 7.5 编写 delivery.md，列出真实命令、通过/失败/skip、analyze 具体集合、改动/SHA、保护范围、GUI/重启/资源计数和局限；architect 独立复核前不提交，owner 验收前不归档、不推送。
- [ ] 7.6 全量 `flutter test --coverage` 归零：修复 `full-suite-baseline.md` 记录的 64 项 HEAD 既有失败（reader-shell 6.x 28、workspace/5A 24、favorites/search/settings 12），逐项对齐 UX1 契约；禁止用 skip、删除断言、放宽 finder 或与契约不符的产品改动掩盖。完成后以 CI 等价并发复跑全量，保留 HEAD 对照与覆盖率报告。
  - 2026-11-25：来源 `ci-quality-gate-recovery` 4.4（5719 通过 / 64 失败 / 150 skip；64 项与 HEAD worktree 逐条一致、零新增）。本项完成前，`ci-quality-gate-recovery` 4.5、`desktop-only-ci-cd` 4.3、`venera-pc-rebrand` 7.3 均不得勾选；证据入口见 `full-suite-baseline.md`，原始逐条日志仍在本地 `tmp/ciqg/4.4-bisect.md`（`tmp/` 不入库）。
