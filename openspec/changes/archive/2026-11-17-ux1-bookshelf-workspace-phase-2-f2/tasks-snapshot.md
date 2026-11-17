# UX1 A 书架型工作区实施任务

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

- [ ] 5.1 将搜索默认结果改为封面平铺，并把现有「点击收藏」设置扩展为所有漫画列表的统一主体行为；独立控件不误触，直接阅读和进入详情均保持正确历史。
- [ ] 5.2 实现详情信息优先默认与阅读优先可选；两版保留标题、作者、来源、分类、状态、继续阅读、收藏、简介和章节，阅读优先作品详情默认收起且可展开。
- [ ] 5.3 实现收藏密度、详情层级、关闭跳转和启动策略的设置入口、可靠保存与重进/重启一致；设置作用范围清晰，不互相覆盖或改写业务数据。
- [ ] 5.4 实现首次加载骨架、更新中旧结果、无结果恢复和更新失败旧结果/打开/重试；提示靠近上下文且不循环 toast，关键词、筛选和选择保持。
- [ ] 5.5 完成搜索/详情真实控件、状态反馈、收藏切换、层级/标签现场保持及 F6/F7/F8 搜索身份回归；所有新文案 `.tl` + zh_CN/zh_TW。

## 6. 阅读器与全局可访问性

- [ ] 6.1 实现普通阅读保留标签、沉浸阅读隐藏标签及模式切换现场保持；保护阅读方案绑定、翻页与 B3/F9/B5 行为。
- [ ] 6.2 移除闲置 2 秒自动隐藏，接入漫画任意位置单击切换工具；独立按钮、菜单、章节与文本控件不冒泡，底部始终只有一条进度组件，隐藏工具时为精简形态。
- [ ] 6.3 实现章节右侧覆盖浮层和 Escape 顺序：先浮层、再沉浸、普通模式可找回工具；不改变漫画尺寸，不一次按键跨越两级。
- [ ] 6.4 核对浅深主题无阅读器深色例外、动态强调色不染封面/整片内容；手动与系统减少动画、150% 大文字、键盘焦点和语义在全部新页面一致可用。
- [ ] 6.5 完成阅读器真实坐标/键盘测试和 GUI：连续单击、工具内点击、单进度、章节 Escape、普通/沉浸标签、后台休眠与页码恢复，逐图核对无 overflow。

## 7. 整体验收与交付

- [ ] 7.1 按 acceptance-checklist.md 执行完整 owner 场景矩阵；所有项目实施项有生产行为测试和 GUI 证据，不以探索稿、helper 属性或内存重新构建 替代真实动作。
- [ ] 7.2 运行全部受影响既有回归并保留原语义断言；flutter analyze raw/unique 50=38+12 零新增，新增测试 0 skip，既有失败与基线单列，不借返工修无关问题。
- [ ] 7.3 在 expanded/medium/compact、浅深主题、150% 大文字、简繁、减少动画下完成生产 GUI；真实终止进程并以新 PID 验证工作区恢复，正常 main 构建恢复并精确清理 fixture/进程。
- [ ] 7.4 核查所有新增文案 zh_CN/zh_TW、设计契约与 delta spec 一致、保护文件零非授权 diff、`pubspec.lock` 未重生成、截图不入库、git diff --check 与 `openspec validate ux1-bookshelf-workspace` 通过。
- [ ] 7.5 编写 delivery.md，列出真实命令、通过/失败/skip、analyze 具体集合、改动/SHA、保护范围、GUI/重启/资源计数和局限；architect 独立复核前不提交，owner 验收前不归档、不推送。
