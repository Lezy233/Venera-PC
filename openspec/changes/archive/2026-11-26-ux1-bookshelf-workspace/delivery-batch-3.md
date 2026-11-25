# UX1 第三批：1.3 与 F2（owner已验收）

**最终状态，2026-11-17：owner验收通过，授权1.3＋F2阶段归档提交，未授权此次推送。** 此前待修复/待验收均为历史；显示路由恢复后已验收，产品首帧修复保留。归档目录 `../archive/2026-11-17-ux1-bookshelf-workspace-phase-2-f2/`，整个UX1仍活动，余5.x–7.x，不将阶段归档等同整项完成。

## 开局与边界

2026-11-16 executor核验：HEAD `5548f5fedf1d40c28e1bcaefb41653a65106bd78`、分支redesign-2026，开局status干净；随后出现的dispatch-batch-3.md为architect授权文档，保留。已读AGENTS/ROADMAP、活动proposal/design/四份spec/tasks和design-spec相关契约。使用diagnosing-bugs、tdd、ui-ux-pro-max；测试入口为派工授权的真实生产卡片/键盘/工作区路由/来源请求，不另造模型验收。只实施1.3与4.1–4.5，5/6只建立可重放诊断红灯；不提交/归档/push，不编辑契约或历史阶段归档。

## 第一小循环：真实Space入口红→绿（尚未完成4.1整项）

命令：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/features/comic_widgets/comic_preview_test.dart --reporter expanded`。

红灯 `/tmp/ux1-b3-preview-red.log`：0通过/1失败/0skip。初始化零异常，真实点击TextField再Tab，验证primaryFocus所属ComicTile实体alpha，再按Space；可见Comic preview为0而预期1。不是初始化或错误焦点失败。根因：ComicTile无Space入口，SliverGridComics也未传递同组目标。

最小实现：ComicTile键事件提供临时预览，SliverGridComics传递同组目标；独立comic_preview.dart只请求当前作品loadComicInfo，不挂载ComicPage或执行其关联业务。按sourceKey/id缓存本次浮层请求，按目标key隔离异步结果；Space/Escape关闭归还原焦点，左右切目标。Dialog头部关闭常驻，正文可滚动，尺寸走新token、语义角色；新增Comic preview文案zh_CN/zh_TW。Enter/后台提升代码已接既有路由，尚未测，不当成完成。

同命令绿灯 `/tmp/ux1-b3-preview-green.log`：1通过/0失败/0skip；真实Space、右键方向、Escape，概览/目录文本、alpha→beta必要详情请求各一次、原FocusNode恢复通过。当前测试还未覆盖完整生产工作区标签历史、多选/滚动、大文字/窄窗、异步竞态或作者shelf；4.1/4.2/1.3保持未勾。4.3/4.4/4.5尚未实施。

analyze尚未跑；正常main产物仍开局版本，本轮未构建/启动GUI，无新fixture。下一小循环：真实工作区预览Enter/后台提升与原多选滚动保护，然后独立复选框红灯/迁移；未来5.1/6.2诊断单列/tmp，不混常规失败suite。

## 当前权威进行中：1.3闭合，预览与普通网格拖放（后续覆盖开篇续点）

1.3真实生产缺口证据已齐，tasks即时勾选；全部未来5/6预期失败的原始命令/源码/可重放差异见batch-3-baseline-diagnostics.md。本轮不实施5/6。多栈历史红→绿引用已验收归档delivery-batch-2开篇tabs-red（缺真实New tab而非初始化错误），当前真实独立栈/后台/返回为本轮生产工作区绿对照。

真实复选框缺失 `/tmp/ux1-b3-checkbox-red.log` 1通过1失败0skip；接入后点选成功但Escape未清空 `/tmp/ux1-b3-checkbox-green.log` 1通过1失败0skip，实际触摸tap未给卡片焦点。修为独立点选后请求卡片FocusNode，`/tmp/ux1-b3-checkbox-focus-green.log` 2通过0失败0skip。收藏选集仍由LocalFavoritesPage持有，主体不再在multiSelectMode切换选择，而是沿既有read/viewDetail设置打开。两份B4命中测试按4.3阶段迁移：原每行真实glyph/封面坐标、准确一次路由、实体/sourceKey、read/detail分支、菜单隔离、Escape/选集断言均保留；选中后主体逐点打开且保留旧选集，选择改走真实hover+Checkbox，不直接调用回调。

`workspace_preview_test.dart`真实MainPage/WindowFrame两卡420px/同State-controller/焦点下验证预览标签数/栈/recent不变、概览目录、Ctrl+Enter后台正确身份且0提前详情请求、Enter只push一次及AltLeft完整返回。首版fixture选中部分裁切卡顶部checkbox无法命中，只修为顶部可见卡，仍420px；进入真实详情的异步保存需沿既有waitForSettingsSave队列等待，不靠扩大动画超时，原超时不当产品红灯。`/tmp/ux1-b3-preview-workspace-io.log`1通过0失败0skip。

预览24组合（600/1000/1400×浅深×简繁×150%×系统减少动画开关）正文真实拖动/关闭始终可命中、精确原focus返回；同id跨三来源乱序及关闭后晚完成不串作品、输入框Space不被卡片吞。`/tmp/ux1-b3-preview-matrix.log`28通过0失败0skip（含基础2、竞态1、工作区1），tasks4.1/4.2已勾，GUI和平台键增量仍归4.5。

普通网格真实drop红 `/tmp/ux1-b3-selection-drop-red.log`0通过1失败0skip：选择及420px建场已过，实际鼠标拖到WorkspaceTabStrip释放后标签1、要求3；`selection-drag-red`另记录拖动Escape在缺失拖动层时误清选集。最小实现WorkspaceComicDrag只携稳定路由身份，无收藏/来源写入；实际Draggable+TabStrip DragTarget按实体后台打开，取消标记在accept处再验。首次合跑 `/tmp/ux1-b3-drag-preview-protection.log`36通过1失败0skip，新增拖动层仅selected时插入导致卡片重挂/FocusNode丢失，使首次Space失效；改稳定包装层，仅切maxSimultaneousDrags。`/tmp/ux1-b3-drag-focus-protection.log` **37通过0失败0skip**，真实两卡drop建两个后台、Escape取消不建新标签且不清选择、原页420px/同实例/实体保留、预览矩阵/B4全部通过；不把重叠各轮相加。

作者栏长按重排冲突已报architect，并由architect转owner异步选择；尚未收到裁定。作者栏原LongPressDraggable手势未改，新增选择拖动在该路径明确暂不开启。4.3/4.4/4.5未勾：仍需F1旧场景建场迁移后相关保护、菜单/Cmd/Ctrl等价入口验证、作者栏按裁定补证、手动减少动画入口与GUI完整取证。

当前analyze `/tmp/ux1-b3-progress-analyze.log` raw52，两条新增均comic_preview.dart curly_braces_in_flow_control_structures；已最小补括号但未复验，不报50。正常main产物仍开局，未构建/启动任何本轮GUI，无自有fixture。下一有界循环：独立卡片菜单/键盘多选后台打开与保护场景迁移；源码仍进行中未冻结。protected未改，git diff --check目前通过。

## 2026-11-17恢复权威续点（覆盖上段进行中状态）

HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78，保留全部授权脏改。当前源码/测试SHA见batch-3-progress-production.sha256（15文件）及batch-3-progress-tests.sha256（26文件），尚非最终冻结。

最新生产控件增量：`/tmp/ux1-b3-result-checkbox-enter-green.log`34通过0失败0skip（预览32、搜索/聚合2）；`/tmp/ux1-b3-result-motion-preview-loop.log`43通过0失败0skip（与前项重叠，不累加）。真实Appearance开关磁盘保存/重载1绿，手动/系统四组合独立动画测试绿。该最小Reduce motion依赖已获architect授权，仅新预览读取OR，其他动效留6.4。真实菜单、Ctrl/Meta+Enter、拖放及Escape反馈取消在`/tmp/ux1-b3-selection-equivalent.log`4绿；后续精确焦点修复的`/tmp/ux1-b3-popup-focus-return-loop.log`6绿，保留420px/同实例/原FocusNode。F1迁移全组上次22通过2失败，两个剩余焦点失败已在上述6绿闭环，但全组尚未重跑，不称全组最终绿。

最新analyze `/tmp/ux1-b3-analyze-fixed.log`raw/unique50=38tool+12，具体集合added=[]removed=[]见batch-3-progress-analyze-comparison.json；该次分析早于最后Checkbox Enter优先级小修，最终源码仍须复验。早前52/51均为已修本批lint，不替代最新结果。

GUI构建`/tmp/ux1-b3-gui-build.log`成功，当前bundle为临时F2 harness，**正常main尚未恢复**。已核准harness8b9a04d2fbe7a5a35c4fd359317d1a593ed9fc8e3fb09a1f1bdf96761f512911、helper fa9ee5fc037cd08b0bb56a9c7739e8b527e40ed968850177ba7cd65196cc883a，恢复时SHA一致。旧PID487144曾READY、physicalSize900×600；identify因自动审查用量耗尽未执行，未输入/截图。恢复时本地ps已无此PID，需宿主身份检查后复用现有构建启动新PID；不将该审批故障当产品红灯。

4.3/4.4/4.5仍未勾；作者栏手势owner裁定尚待，不改既有长按重排。继续独立GUI、相关保护及最终分析/正常main清理，不提交归档push。

## 恢复后验证增量（2026-11-17）

宿主identify证明PID487144仍存活，沙箱ps不可见不代表退出；直接复用既有构建/窗口，无重建。GUI真实滚轮164.325030078125px、hover复选框book-3/book-4、Space预览book-4→Right切book-5→Escape，F6-1/2/3证明同页面367469035、控制器898127722、原focus1012199551返回、实体/offset保持、标签/recent未增。真实drag取消F6-4仍1tab；真实drop F6-5恰3tab，后台book-3/book-4准确source=ux1-fixture，active/recent仍原tab，details未新增。截图selected-scrolled/preview-dark-medium/drag-cancel-live/drag-drop-live/drag-drop-result在/tmp/ux1-f2-captures；图片为受控本地已解码PNG，不代表外部来源。

compact600×700预览完整关闭与操作可见，F6-6；实际Enter后F6-7原tab栈加comic，AltLeft后F6-8回原现场。真实Appearance开启Reduce motion、主题选Light、APP语言选简体；正常窗口关闭PID487144 exit0，helper确认无窗口。复用同bundle新PID801876，受控text150/system参数仍须由F6实际previewMedia验证，尚未当绿。当前bundle仍harness，main未恢复。

`/tmp/ux1-b3-f1-final-protection.log`19份F1 **24通过0失败0skip**，完整原现场断言均保留。architect独立合跑历史225通过1失败0skip，唯一旧continuity建场；仅将长按/主体建场迁移为真实checkbox和可命中卡顶部、焦点标签迁移，保留两实体/420px/同实例/精确原FocusNode。executor `/tmp/ux1-b3-continuity-checkbox-loop.log` **1/0/0**、architect单项同绿，不冒称一次226全绿。

`/tmp/ux1-b3-author-selection-migration-red.log`0/1/0：F10旧同作品第二作者栏主体点击因D4打开ComicPage（fixture未初始化local manager异常单列），路由数量1→2；只迁移此独立checkbox动作，保留同实体去选/零业务路由/三态及请求语义。`/tmp/ux1-b3-author-series-protection.log` **80通过1失败0skip**，作者UI和原长按拖动/独立排序/F5通过，唯一F11旧主体建场期望两选但实际一选；只迁移两次真实checkbox，`/tmp/ux1-b3-f11-checkbox-loop.log` **1/0/0**，原选集/滚动/筛选/实例/折叠/Escape均保留。上述回归不累加重叠。新增三份迁移测试纳入最新progress manifest（15生产/29测试）；生产未因这些fixture修正变化。architect的review-batch-3.md保留。

## 最新权威交接：独立部分可复核，4.3必要依赖及作者手势待定

HEAD保持5548f5fedf1d40c28e1bcaefb41653a65106bd78；未提交/归档/push。源码自上述GUI构建以来未变；当前15生产/29测试/65工具GUI清单均已由architect独立核为MATCH。源码路径与完整SHA见batch-3-progress-production.sha256，全部新增/迁移测试见batch-3-progress-tests.sha256；工具/JSON/截图/运行与构建日志/kernel见batch-3-progress-gui.sha256。正常main/runner源码零改。

当前任务状态：1.3、4.1、4.2已勾。**4.3已按architect复核撤销整项勾选**：已有checkbox/收藏绿灯不能覆盖全局主体契约；单源/聚合在read偏好下仍打开ComicPage，原1.3/5.1两条真实红灯及源码继续保留，未抹历史。4.4与4.5仍未勾：普通网格已验证，但作者栏选集拖出与原长按重排划分等待owner，未自行选/改手势。手动Reduce motion最小依赖已获architect授权，与作者手势问题独立。

新增根因/边界：拖动包装只在选中时插入会重挂焦点，已改稳定包装；compact/expanded正文路径切换会重挂卡片，已保持稳定Stack路径；收藏build每次强制选集FocusScope抢原卡焦点已移除，仅保留明确进入多选的焦点动作；All N弹层临时焦点会覆盖页面记忆，现仅记录本页binding内焦点。真实复选框Space/Enter优先级与原生控件隔离，聚合SimpleComicTile复用原renderer并补卡片焦点/预览层。未修改reader工具/阅读进度或搜索默认布局。

最后增量与局限（原始命令索引见batch-3-validation-commands.md）：

- executor `/tmp/ux1-b3-workspace-final-green.log` **7通过0失败0skip**：真实工作区预览/三宽拖放/混来源/菜单/Ctrl与Meta，原两选/420px/同实例/精确焦点/后台请求计数保留。
- compact首次等待超时，探针确认420px已到达、唯一CircularProgressIndicator来自SettingsSaveFeedback；新视口post-frame注册再安排防抖保存，补其实际磁盘等待后单项1绿，保留3秒动画上限。探针代码已移除，探针日志保留，不当产品红灯。
- `/tmp/ux1-b3-preview-final-loop.log`历史37通过1失败0skip，唯一新增SemanticsHandle在测试结束后才释放；改finally当场释放，`/tmp/ux1-b3-checkbox-semantics-green.log` **1/0/0**，checked真假、真实Tab/Space/Escape和零路由断言均通过。最初枚举Tristate/CheckedState用错亦单列为测试问题。
- `/tmp/ux1-b3-layer-hit-protection.log` **115/0/0**（作者hover/长名/布局/存储、通用B4真实命中），F1原场景24/0/0，continuity1/0/0如上；不累加重叠。
- architect最终独立增量四文件 `/tmp/ux1-b3-architect-final-increment.log` **42/0/0，13秒**；F10/F11四文件 `/tmp/ux1-b3-architect-author-sidebar-protection.log` **57/0/0，7秒**。历史225/1与continuity后续1绿分列，未冒称一次226绿。architect review文件由其维护，executor未覆盖。

最终分析 `/tmp/ux1-b3-final-analyze-fixed.log` **raw/unique50=38tool+12**，逐条added=[]removed=[]；current_log已更新至该日志。前次final-analyze51唯一新增测试super参数lint已修。具体集合见batch-3-progress-analyze-comparison.json。固定protected零diff、git diff --check、OpenSpec validate均通过；architect亦已独立核对。不修无关50基线。

GUI逐图场景及实际F6对应见batch-3-gui-evidence.md。PID487144 medium深色原场景：164.325px、book-3/book-4、focus1012199551、真取消仍1tab、真drop新增两后台且0新请求；compact Enter/AltLeft回原栈。PID801876实际scale1.5/system true，浅简及深繁、600/1000/1400预览与正文滚动；PID809100实际scale1.5/system false，磁盘手动reduceMotion=true。系统值由受控MediaQuery注入，不冒称真实OS设置入口；手动/主题/语言为真实生产设置操作。expanded窗口截图1060×740裁截，完整Flutter帧1400×760另列，未在不可达宿主区域鼠标操作。图片为受控本地已解码PNG，非外部真实来源。

三个PID均正常关闭exit0；升级权限ps三PID无记录、:1固定F2标题无窗口，未kill其他程序。正常main恢复构建成功，kernel83d1c7a…匹配正常app.dill，depfile含lib/main.dart；harness缓存kernel99b061da…对应/tmp入口，未混称。/tmp证据/隔离数据保留审计，运行fixture已清理。正常构建后没有生产源码变化。

### 4.3待architect裁定的最小依赖（尚未实施）

**续记：architect已批准下述依赖，现已实施并验证主体增量；本标题和下文保留裁定前历史，最新状态见本段。** 不扩5.1布局/设置/详情或6.x。原单源/聚合红灯复跑`/tmp/ux1-b3-body-preference-red.log`0/2/0；最小默认主体函数与typed reader builder接入后，新路由级测试4绿4红，唯一失败均已知标题丢失。ReaderWithLoading无title，最小增可选元数据与workspace描述/恢复透传（不改加载逻辑、不增加请求）；`/tmp/ux1-b3-body-preference-green.log`8/0/0。后补显式Details保持详情及custom onTap优先，与结果独立控件/B4合跑`/tmp/ux1-b3-body-hit-protection.log`19/0/0；真实主体tap/Enter、挂载原生产加载界面、平台back返回后选集/同State、id/source/title/一次路由/hero均保留。此组控制来源详情pending，仅证明路由/加载入口，实际解码Reader及shell AltLeft由GUI补证。read偏好下预览提升仍详情/后台详情与AltLeft原现场`/tmp/ux1-b3-preview-read-promotion.log`1/0/0。

当前生产增量18文件、测试30文件progress manifest已更新；旧15/29/65清单另保留为batch-3-pre-body-*.sha256，旧GUI为改前局部证据，非新主体最终证据。四个受影响源码SHA：comic_tile.dart `bf74d48453be260ae8ba74e4ebb2e57ac79045deaaedc04e0fd46a46ce3bb48a`，app_runtime/init.dart `0a4a62f9579928505abaf355e4efeb5bcfde877b23fe0920041a25f50fbf2faf`，reader/loading.dart `2e5239473dde2d248392c4d4e8803fd5240152948047ae90c41813c39f7b9216`，workspace_pages.dart `008afe05f17f452f9626939b03fef9e47409225ba933fbecbf32e39df5cea50f`。旧GUI缓存kernel路径会被新构建覆盖，旧清单该缓存项只保留旧hash历史，不能继续称全MATCH。

已核准工具SHA未变（8b9a04d2/fa9ee5fc），当前按同一harness构建新GUI`/tmp/ux1-b3-body-gui-build.log`；尚未启动新PID。当前增量analyze/Reader标签保护/GUI read→返回及正常main再恢复待做，4.3仍未勾；4.4/4.5作者栏手势独立待owner，不自行选。

已证入口：普通ComicTile._onTap默认硬编码_openComicPage；SimpleComicTile内AnimatedTapRegion默认也硬编码_openComicPage，所以单源/聚合真实主体在read时走详情。收藏LocalFavoritesPage已有onClickFavorite read/viewDetail分支，通过自定义onTap接入，不需改业务分支。

建议仅在comic_tile.dart提取共享“默认主体打开”函数，读取现有FavoritePreferences.onClickFavorite：viewDetail沿既有ComicPage builder；read沿既有ReaderWithLoading（正确id/sourceKey及可用已知title，不额外详情请求）。复用configureComicWidgets现有启动注入模式，为reader补typed builder并在app_runtime/init.dart接既有ReaderWithLoading，避免漫画卡片层直接依赖完整reader实现。ComicTile默认主体、SimpleComicTile默认主体与其普通Enter共用；自定义onTap优先级不变，收藏回调不重写。显式菜单Details、预览Enter/Details、后台详情保持明确详情语义，复选框/菜单/拖放不透传。

影响边界是使用默认ComicTile/SimpleComicTile主体的F2列表（含普通网格、单源、聚合）；不改搜索默认renderer/排序、详情布局、设置文案/名称/默认值，不新增偏好、不扩6.x工具。现有5.1诊断保留原红灯历史；裁定后将相同真实主体断言纳入生产控件回归，覆盖read/viewDetail、键盘/文本封面命中、准确一次/实体/返回、选集不变及独立控件隔离，并按实际影响复验B4/F1。实施将使当前生产manifest/GUI源码冻结失效，必须更新SHA、analyze及正常构建，明确旧GUI仍属改前阶段证据。此依赖等待architect裁定；作者手势仍独立等待owner，不重复问owner。

## 最终权威交付：4.3必要主体绑定已闭合，等待作者栏手势裁定

本段覆盖所有前述进行中状态。HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78、分支redesign-2026；保留授权脏改，未提交/归档/push。1.3、4.1、4.2、4.3已勾；4.4、4.5仍未勾，5.x/6.x生产任务未开展。architect review-batch-3.md保留且未覆盖。

4.3按architect批准实施既有onClickFavorite必要绑定：ComicTile/SimpleComicTile默认主体及普通Enter共用read/viewDetail；typed reader builder在app_runtime/init.dart注入既有ReaderWithLoading。自定义onTap优先；显式Details、预览提升与后台详情保持详情，不冒泡。ReaderWithLoading仅补可选已知title及workspace描述/恢复透传，不改加载/请求/工具。新增实际路由测试挂载生产Loading页面，并用平台back返回；完整解码Reader由下述GUI证明，不扩阅读器测试体系。

红绿：原真实单源/聚合read主体红灯/tmp/ux1-b3-body-preference-red.log 0通过2预期失败0skip，原1.3/5.1源码/日志历史保持；新路由4绿4标题红仅缺已知title，补元数据后body-preference-green 8/0/0。补自定义onTap与显式Details后body-hit-protection 19/0/0；read偏好下预览提升/后台详情/AltLeft保护1/0/0；既有Reader标签及通用B4/hero合跑93/0/0。该93组日志含既有flutter_memory_info测试平台MissingPlugin捕获警告，未当产品新增异常或新增红灯，未修改基线；真实GUI无该Flutter异常。architect独立主体依赖/tmp/ux1-b3-architect-body-dependency.log 123/0/0，20秒。上述集合重叠，不累加为虚构总量。原5.1诊断行为已因本次必要绑定转绿，但搜索默认布局/设置整项仍未做，不勾5.1。

GUI增量PID836728：真实生产设置点击收藏=read→SearchPage自己的可见输入框提交Alpha→单源请求一次→真实checkbox选book-0→点真实标题→Reader已解码第1页→Alt+Left返回。rich-836728-1/2/3.json及同名完整Flutter帧，body-before-read/body-reader-real/body-read-return窗口图逐项对应。Reader id/source=book-0/ux1-fixture、chapter1/page1；原focus323739778与各scrollState/offset逐项相等，checkbox仍checked、active/recent/3标签不变。搜索、详情、章节各一次，返回不重发。此前误点搜索目标栏/壳层入口是取证定位错误，未记产品故障或绿灯。1200×700完整Flutter帧与宿主裁截截图分列；受控来源及本地PNG，不冒称外部站点。细节见batch-3-gui-evidence.md新增末段。

当前最终清单：batch-3-progress-production.sha256 **18项**、batch-3-progress-tests.sha256 **30项**、batch-3-progress-gui.sha256 **87项**；当前清单已刷新为实际新源码/工具/证据/正常main产物。旧15/29/65清单保留batch-3-pre-body-*.sha256仅作历史，其中旧65的harness缓存app.dill与bundle kernel两项因构建替换预期不匹配，**不再声明旧清单MATCH**。旧GUI仅改前预览/拖放局部证据；新绑定GUI kernel525a8444…有操作前fixture-binary记录，与harness缓存一致。

当前正常main已再次构建成功/tmp/ux1-b3-body-main-build.log；bundle kernel7d0b8074e134f720d030c7c96a97ba00b77d7dcebc2f216f8d1c0e7de35585b4，匹配正常main app.dill。main/runner零改。PID836728正常关闭exit0，宿主精确ps及:1 X11固定标题均无残留；旧三个PID此前亦已清理。未kill其他程序，/tmp静态审计资料保留。

最终analyze /tmp/ux1-b3-body-analyze-fixed.log raw/unique50=38tool+12，逐条added=[]removed=[]，comparison current_log已同步。先前body-analyze51唯一新增测试括号lint已修，不改50既有基线。architect最新独立analyze亦50/50零增减；18/30 SHA、GUI、正常main和宿主清理已独立核对。protected零授权外diff、diffcheck/OpenSpec通过，相关源码在此之后未变化。

唯一待owner：作者栏选中卡片“拖出到标签栏批量建后台详情”与现有LongPressDraggable“每作者栏独立重排”的手势分工。当前作者栏原长按重排保持，enableSelectionDrag=false，故其选集拖出尚未启用；普通网格真实拖放、取消和菜单/Ctrl/Meta等价入口已通过。裁定影响作者卡片拖动/长按的触发与优先级，不影响已完成的复选框选择、正常主体、Space预览或既有身份/独立排序。executor不默认任何选项；4.4/4.5整项等裁定后补该路径证据，当前停止等owner，不继续扩功能或重复测试/GUI。

## 2026-11-17 作者栏续派：当前进行中权威段

owner已选择独立手柄拖出选集，卡片原长按排序保留；architect更新design D4、browse-and-preview两个场景及dispatch首条续派边界，executor只读取，未修改契约。HEAD5548f5fedf1d40c28e1bcaefb41653a65106bd78，保留全部授权脏改。此前18/30/87冻结已因本增量失效，原清单保存为batch-3-pre-author-{production,tests,gui}.sha256，均为改前历史。

真实生产MainPage/WindowFrame作者栏测试test/app_shell/workspace_author_handle_test.dart：以checkbox选择Alpha栏同ID不同来源两作品，Beta栏同实体同步选中，从标题箭头左侧独立44px区域真实鼠标拖至WorkspaceTabStrip。/tmp/ux1-b3-author-handle-input-red.log：0通过1失败0skip，Expected3 tabs/Actual1。前序必填存储参数/ValueKey可空泛型/鼠标指针生命周期及展开态滚动定位问题均为fixture纠正，不计产品红灯。沙箱SDK只读单列，升级权限原命令可运行，未改SDK。

最小生产改动：author_shelf.dart标题区加ComicSelectionDrag手柄，按(id,sourceKey)去重当前选集，复用现有后台route，空选集/失效绑定禁拖；Tooltip、Tab焦点、hover、语义色描边和Ctrl/Meta+Enter等价；不嵌入卡片长按排序区，卡片enableSelectionDrag仍false。tokens.dart新增44px尺寸；translation.json新增手柄文案双中文。没有改收藏、作者顺序算法或来源配置。

最小原循环/tmp/ux1-b3-author-handle-green.log为1/0/0。三态扩展/tmp/ux1-b3-author-handle-matrix.log为3/0/0。随后实际卡片长按排序也加入三态强断言，与原F10/F11必要保护合跑/tmp/ux1-b3-author-handle-protection.log为58通过0失败0skip（19秒）；含真实手柄空选集/点击隔离/取消/一次drop/正确两来源/零提前详情请求/原页实例、焦点、滚动及Beta独立排序，Alpha不变、收藏成员不变。原故障注入打印保存失败为既有测试预期，不计新增异常。三日志存在覆盖关系，不累加。

准确合跑命令：env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_author_handle_test.dart test/features/favorites/author_shelf_drag_test.dart test/features/favorites/author_shelf_ui_test.dart test/features/favorites/sidebar_sections_test.dart --reporter expanded。单项命令只保留新test路径，同环境。

仍进行中：作者手柄600/1000/1400宽/150%有界增量测试/tmp/ux1-b3-author-handle-responsive.log；本轮最终analyze尚未跑，旧body-analyze50不能代替新源码。4.4/4.5暂不勾，待响应式/新源码GUI手柄取证与analyze/main恢复/自有fixture清理后闭合。工具SHA未改：harness8b9a04d2fbe7a5a35c4fd359317d1a593ed9fc8e3fb09a1f1bdf96761f512911，helperfa9ee5fc037cd08b0bb56a9c7739e8b527e40ed968850177ba7cd65196cc883a；均已全文复核并获准复用。当前尚未启动本轮新fixture，磁盘bundle仍为上一轮正常main，尚未包含新手柄；不冒称本轮GUI通过。
## 最终权威交付：作者栏手柄完成，1.3 + F2 待独立复核（2026-11-17）

本段覆盖此前“等待owner手势裁定”及“作者栏进行中”，保留旧证据历史。owner已决定独立拖动手柄，卡片原长按排序保留，architect已落design D4/browse两个场景/dispatch。没有剩余手势选择。HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78，未提交/归档/push。

根因：作者卡片原LongPressDraggable专属栏内排序，enableSelectionDrag=false，无选集拖出入口。新生产MainPage/WindowFrame真实坐标红0/1/0：正确两卡checkbox选择后，从标题箭头前手柄区域拖至WorkspaceTabStrip，预期3标签实际1。原始/tmp/ux1-b3-author-handle-input-red.log保留；前序fixture参数/可空ValueKey/测试鼠标生命周期和展开态可见定位问题单列，不冒称产品红灯。最小修复仅author_shelf.dart标题区44px手柄，复用ComicSelectionDrag与workspace后台route，(id,sourceKey)去重当前跨栏选集；不碰卡片长按排序路径。空选集/失效绑定不拖，手柄点击不改选择/不打开/不排序，tooltip/hover/Tab焦点语义与Ctrl/Meta+Enter等价；原菜单/卡片键盘入口保留。新尺寸tokens、.tl双中文已补。

增量验证（各日志有覆盖，不累加）：最小绿1/0/0；三态扩展3/0/0；新手柄+原作者拖动/UI/F11合跑58/0/0；最终三宽/语言/150%增量3/0/0（/tmp/ux1-b3-author-handle-final.log）。最终新测试保留跨作者同实体同步选择、同ID不同source准确两后台、空选集不拖、点击与checkbox物理隔离、Escape取消零新增、原页实例/焦点/滚动/成员保持、零提前详情请求、真实Tab到handle后Ctrl+Enter。三态选中卡片真实长按只重排Beta，Alpha顺序不变，不新建标签；原28拖动等完整业务断言保留。architect独立手柄/F10独立排序/UI/F11为60/0/0（/tmp/ux1-b3-architect-author-handle.log），与58不累加。此前主体独立123/0/0和其他已核矩阵保持历史，本轮未重复无关集合。

GUI已闭合并被architect独立抽查：PID1102014，实际1000×700 premount先初始化，固定F2 title/exe/marker/arg/四XDG/:1 x11逐次验证；工具SHA未变。实际生产排序菜单切到作者栏，真实checkbox选book0/book1，标题handle954,226→620,130，Escape取消3标签不变；第二次drop3→5仅book0/book1，来源正确，active/recent不变。rich-1102014-1/2/3与author-selected-before/cancel-stable/drop-stable图一一对应，页753090468、原焦点668761396、checked2及所有scrollState/offset保持；details/chapter为[]，原启动搜索仅一次。/tmp/ux1-b3-author-handle-gui-comparison.json比较通过，图已view_image。完整宿主与Flutter帧均1000×700无裁截；live图仅拖动中间帧。局限：本次单作者/单受控来源，本次offset0；跨作者/异来源/原长按三态及响应式/大文字由真实生产控件测试补，既有非零滚动/简繁/预览矩阵保留分列，不冒称所有场景均同一GUI。受控本地PNG不代表外部来源成功率，GTK Atk/DRI初始化警告单列，无新增Flutter异常。

任务状态：1.3、4.1、4.2、4.3保持已完成；4.4在实际三态/等价路径闭合后即时勾选，4.5在GUI与焦点/响应式证据闭合后即时勾选。5.x/6.x/7.x均未提前勾；1.3原5.1/6.2诊断红灯历史保留，已批准主体绑定转绿不抹旧红，不授权5/6其余功能。F2实现完成待architect独立最终复核，非owner整个UX1验收。

当前本增量变化3生产文件与1新增测试，SHA：
- author_shelf.dart 6aab0836de56a0042560a9cc467870b15a205bc846fae6c9df7e3a159494c851
- tokens.dart 2f86f08b9f40814ee0bae727dc723acf41281fee2b52d68e3f347c24f194bc76
- assets/translation.json c539685bd9bb986af265d123915c5dabb25665195af3b10583353422ba196a67
- 新workspace_author_handle_test.dart 473fe45e9e27ef7085645bbc108d0ec73b105145b2d40425cb3d618a91fe4497（最终格式化及三宽/语言设置后冻结）。
本阶段当前batch-3-progress-{production,tests,gui}.sha256为18/31/119项，全部MATCH；改前18/30/87保留pre-author清单。旧87里harness缓存app.dill与bundle kernel因重建有两个预期替换，不声明旧清单继续MATCH。旧15/29/65同样仅改前历史。

当前analyze /tmp/ux1-b3-author-handle-analyze.log raw/unique50=38tool+12其他，比较JSON current_log已更新且具体added=[]removed=[]；未清理任何原基线。git diff --check及OpenSpec validate change通过。固定保护文件零diff；仅planner已授权design D4和browse-spec场景增量非零，dispatch为其派工文档，executor未改契约，不伪称所有protected零diff。其他三个delta spec、proposal/design-spec/正式spec/pubspec/main/runner/归档/AGENTS/BACKLOG/ROADMAP未改。review-batch-3.md保留architect原文。

收尾：fixture kernel ecf2a509456c349f1af41a3dc986db47edde5a6b4eba9eef4450378418ca5593，记录于/tmp/ux1-b3-author-handle-fixture-binary.sha256；正常窗口按钮退出exit0，升级权限宿主精确ps1102014无记录、X11树仅qq/clipboard，无F2残留。正常main --no-pub构建成功（/tmp/ux1-b3-author-handle-main-build.log），bundle kernel与正常main app.dill均1f2eeebdb7ec768a0b1766056d04fb2a8b09a48295b238a6fc3762bfaa11518a，正常depfile含lib/main.dart、不含临时harness。/tmp工具/静态图/隔离业务审计资料保留，正常main/runner未作fixture修改，没有停止其他程序。至此等待architect独立复核，不再扩大测试或GUI，不自行提交。

### architect最终独立复核已通过，等待owner人工验收

architect已在review-batch-3.md记录本阶段“1.3+F2符合”：独立60通过0失败0skip、当前analyze50具体集合零增减、GUI取消3/drop5及准确实体/原焦点/零提前请求、正常main入口与PID/X11清理、18生产/31测试/119证据全部MATCH均通过。以上为独立阶段符合，不替代owner人工验收。收到该结论后仅补本交付文字，未再改源码/测试/工具或重复验证；当前停止，等待owner人工验收，不提交、不归档、不push，不启动5.x/6.x。
## owner正常入口验收阻断：当前权威诊断进度（覆盖此前符合状态）

owner补充：fvm flutter run -d linux后没有任何应用窗口出现，并非已可用页面内部overflow。当前批次退回待修复；旧测试/GUI通过事实保留，不能据此认定正常启动通过。HEAD5548f5fedf1d40c28e1bcaefb41653a65106bd78，全部授权脏改保留；尚未为本故障修改生产源码，当前构建/诊断进行中，旧main清单不能冒称正在验证的启动场景已通过。

真实未包装生产循环：env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 DISPLAY=:1 GDK_BACKEND=x11 XDG_CONFIG_HOME=/tmp/ux1-startup-diagnostic-config XDG_DATA_HOME=/tmp/ux1-startup-diagnostic-data XDG_CACHE_HOME=/tmp/ux1-startup-diagnostic-cache XDG_STATE_HOME=/tmp/ux1-startup-diagnostic-state RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter run -d linux --no-pub > /tmp/ux1-b3-normal-startup-red.log 2>&1。新鲜隔离业务，无owner配置读取/修改。PID1383929精确复现两条right15、一条bottom15/null，随后原生WARNING Timed out waiting for OpenGL frame of size900x600 (have1x1)。进程仍活，X11窗口0xc00002、title VeneraNext-Dev、最终900×600+10+10且IsViewable；另同名0xa00002属于PID1377349，未操作。IsViewable只证明映射，不证明Flutter画面可用。VM Service/DevTools/dynamic_color正常日志不视作根因。

获准只读VM工具/tmp/ux1_startup_probe.py SHA8074e654328947aa7584fee4a86440b469c220221038281c370bc1483554ec48，仅固定本次PID/exe/四XDG/:1/x11及本地日志地址、RPC白名单；运行成功，输出/tmp/ux1-startup-normal-render-diagnostics.json SHA8066e43f338c73e80de85b12cbe96f0ba55f62461eb6c2195e8e4daa23c995a0。派生只读render/widget树在/tmp/ux1-startup-{render,widget}-tree.txt：停滞后RenderView已900×600、当前无OVERFLOWING。尚未捕获异常发生帧creator，不能把瞬态overflow未经验证当成无画面唯一原因。原flutter run session53258为非TTY且stdin关闭，内建dump输入未执行；改只读VM后取得树，不改产品。

按优先级可证伪假设（开始下一个单变量前记录）：
1. 正常runApp早于原生窗口初始化，1×1挂载与随后show/restore产生首帧握手停滞。预测：保持原主入口/后端/默认设置，仅将窗口初始化放在挂载前的对照应消除同一组15px与1×1原生超时；需先捕获首帧creator及尺寸，再报告最小生产修复边界，不擅改protected main。
2. Linux/Impeller尺寸变更停滞独立于挂载顺序。预测：同样后端在正确挂载顺序对照仍出现原生1×1超时；若仍在，假设1不足。暂不改display服务/renderer或SDK。
3. 恢复几何异常。预测：有效默认900×600与恢复矩形对照产生不同结果。fresh目录已复现，排除仅owner损坏配置必需条件；仍核实际恢复阶段，不改owner保存值。
4. 主题/文字缩放只引发布局overflow，无画面另有原因。预测：相同正确物理约束下只改变textScale仍可改变Flex失败但不应改变native绘制尺寸；需把两种现象分开验证，不能缩字掩盖。

下一观察单变量获architect全文核准：/tmp/ux1_startup_trace.dart SHAa395e80ae248dda3fb998cd56fe529d640ed3bba9f3a2c236c36dc38b397bd85。仅自定义binding.drawFrame前后记录physicalSize/DPR并完整记录details.toString后继续原FlutterError handler；最终调用未改production.main(args)，不设窗口title/show/size、不提前placement、不种业务fixture。固定marker ux1-startup-trace-20261117、参数--ux1-startup-trace、四XDG /tmp/ux1-startup-trace-*、:1/x11。该包装只诊断，不替代最终未包装正常main验证。正在准备构建/启动，正常旧PID只精确身份清理，绝不操作另一同名窗口。最终仍待真实red→最小修复→同输入green、相关60保护/analyze集合/正常入口/精确清理和更新SHA；不提交归档push。
## 最终权威交付：owner正常启动阻断已修复并独立复核（2026-11-17）

此段覆盖上一“启动阻断/尚待修复”状态，旧红灯与所有F2历史事实保留。完整诊断、原始命令、creator/constraints和假设证伪见batch-3-startup-diagnostics.md。HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78，保留当前授权脏改，未提交/归档/push。

本次唯一新增生产修改为lib/main.dart既有await placement?.initialize()移到runApp(MyApp(host:host))前，精确两行交换，architect已明确授权protected例外；不改其他main/runner、不新造抽象、不变更显示后端/窗口偏好/主题/字体、不吞异常或裁剪缩字。main SHA433fff080a42c3f22301e5269f19074a5fc0b21b1219611e2df5198435210cf0。

真实正常入口红灯/tmp/ux1-b3-normal-startup-red.log：PID1383929 fresh隔离目录启动仍活，right15×2/bottom15×1/null及native等待900×600而持有1×1。仅X11 IsViewable不足以证明应用画面可用。获准只读诊断后捕获原样trace：首帧1×1，window_manager-0.5.2 drag_to_resize_area.dart:80/127两个Row最大宽1、边缘共16，:78 Column最大高1、边缘共16，均精确15px；之后Dart尺寸恢复但原生帧等待停滞。没有把dynamic_color/VM端口当根因。已列四项有排名可证伪假设，单变量只移动初始化顺序；同后端/主题/恢复几何转绿支持启动时序根因，不依赖owner数据损坏。HEAD原main已有该顺序，未声称F2卡片引入或伪称完整HEAD运行对照。

修复后两次未包装normal实际画面均900×600、已view_image且获architect独立核：
- 同原四XDG/数据/后端/几何、原fvm flutter run -d linux --no-pub：PID1395945，/tmp/ux1-b3-normal-startup-order-green.log及同名png；15px、原生1×1超时、Zone mismatch均0，TTY q退出exit0。
- 排除状态混杂：最终正常main bundle在全新四XDG /tmp/ux1-startup-fresh-* 冷启动PID1403769，/tmp/ux1-b3-normal-startup-fresh-green.log及png；空data目录启动前不存在，未经fixture包装/种业务；同组三项均0，真实完整收藏首页可用。此为最终正常main产物实际运行，不是仅build通过。
- 原样已核准trace一次对照PID1400269：frame1即900×600、错误与原生超时0；原trace自身Zone mismatch在修前修后各1，明确为观察binding局限、未吞掉，不计产品故障或宣称wrapper全无异常。最终normal无此异常。/tmp/ux1-b3-startup-order-comparison.json已按原日志assert上述精确计数与首帧对照通过。

相关回归为architect独立四文件/tmp/ux1-b3-architect-startup-protection.log：32通过0失败2既有skip，不能报0skip。两项均!Platform.isWindows：真实WindowFrame等待placement再准备服务的Windows集成测试，以及加载Windows DLL的ApplicationHost真实核心关闭集成测试；本轮未新增/修改skip或弱化断言。按architect边界复用既有真实初始化/失败恢复/生命周期保护和正常入口冷启动，未新增搬语句抽象/源码镜像测试、未重复旧60或无关全矩阵。旧60/0/0仍是F2已核组件保护历史，与32不累加。

最终独立analyze /tmp/ux1-b3-architect-startup-analyze.log raw/unique50=38tool+12其他，具体added=[]removed=[]；comparison current_log已更新。最终正常main构建/tmp/ux1-b3-startup-final-main-build.log成功，kernel与正常main app.dill同为4100dcba44f44167d5b4559eff7c65443fff003627248eba1a83067829cc9acd，正常depfile含lib/main.dart、不含两种临时harness；fresh绿色实际运行此bundle。

五自有诊断PID1383929/1391810/1395945/1400269/1403769均已精确清理，最终宿主ps无记录，X11只保留另同名owner1377349/0xa00002及qq/clipboard。红灯normal经即时exe/参数/四XDG验证后SIGINT；两个trace和直接fresh由自身PTY CtrlC退出exit1，属有界诊断停止，不冒称全部正常UI关闭；normal绿色q退出exit0。没有操作owner窗口/配置/显示服务，/tmp静态审计工具/日志/隔离目录保留。所有诊断工具先全文SHA核准，仅固定本轮PID读取，截图前后身份与root边界重验、拒绝覆盖，无窗口输入。

当前batch-3-progress清单19生产/31测试/139证据全部MATCH并经architect最终独立确认；改前18/31/119保存pre-startup，仅历史，构建缓存替换不再称旧清单继续MATCH。固定protected零授权外diff；main只本次授权两行，design/browse-spec为此前planner手柄授权改动，dispatch/review保留其文档，不伪称main零diff。diffcheck及既有OpenSpec通过事实保留，本修复未改契约。没有将截图入库、没有改依赖或lock。

architect已追加review-batch-3.md最终启动修复符合：fresh实际窗口/无15px或1×1超时、正常main产物、五PID清理及owner窗口保留、19/31/139、32pass2既有Windows skip与analyze50零增减均核对通过。当前恢复待owner人工重试验收，不等于owner已验收；仅完成交付文字后停止，不再检查/测试/GUI，不提交归档push，不启动5.x/6.x。
## 第二次owner“无窗口”：显示路由证据与交付（覆盖此前无窗口已全部解决的表述）

owner第二次正常运行PID1414688仍无桌面窗口，但已没有三条15px/原生1×1超时。首帧顺序修复保留；它只解决已复现的首帧故障，不能称owner桌面可见性已全部解决。HEAD仍5548f5fedf1d40c28e1bcaefb41653a65106bd78，授权脏改未还原；本轮显示诊断未改任何产品代码/测试/依赖。pubspec.yaml/lock经只读git diff/status核对均无变化，未擅自清改，也未pub get/upgrade。

### 固定owner PID的直接只读证据

读取仅针对owner明确提供的PID1414688，白名单环境、完整exe及有限入口标记，没有输出完整environ或敏感参数；没有向其窗口输入/移动/关闭。证据文件：
- /tmp/ux1-owner-1414688-display-probe.json
- /tmp/ux1-owner-1414688-display-servers.json
- 读取脚本/tmp/ux1_owner_pid_probe.py（只读；SHA90a22c6d38603a264b009b38c2a497fa581f69ff5fffba32f9fc97c2e3896848）

PID1414688当时仍活，exe为项目正常bundle/venera-next，argument_count=0、无fixture参数。白名单结果：DISPLAY=:1、GDK_BACKEND=x11，同时WAYLAND_DISPLAY=wayland-1、XDG_SESSION_TYPE=wayland；XDG_CONFIG_HOME=/tmp/ux1-f1-run/xdg/config、XDG_DATA_HOME=/tmp/ux1-f1-run/xdg/data、XDG_CACHE_HOME=/tmp/ux1-f1-run/xdg/cache，XDG_STATE_HOME未设置。前三项为测试目录继承，未读取或改写其业务配置。

在该进程指定的:1显示上，xprop确认0xa00002的_NET_WM_PID=1414688、WM_NAME=VeneraNext-Dev；xwininfo为900×600+10+10、Map State IsViewable，位于1080×760根窗口内。因此不是进程已退出、未创建窗口、隐藏或离屏；但这只证明在:1映射，不能推成owner真实桌面可见。辅助InputOnly窗口0xa00001未映射属于正常辅助项，不误当应用主体。

显示服务器归属读取仅限已枚举的790/1496/1871三个显示进程，输出过滤为显示号/exe/监听X11 socket，不输出其他命令参数或认证路径：
- PID1496 argv0=Xvfb、exe=/usr/bin/Xvfb、显式显示号:1，监听/tmp/.X11-unix/X1及其abstract socket。:1根_NET_SUPPORTING_WM_CHECK与_NET_CURRENT_DESKTOP均不存在。它是本轮此前使用的1080×760虚拟显示。
- PID1871 argv0=Xwayland、exe=/usr/bin/Xwayland、cmdline显式显示号:2，监听/tmp/.X11-unix/X2及其abstract socket。
- 跨用户Xorg790的exe/fd读取被OS拒绝，单列局限，未提权绕过；可读Xvfb/Xwayland关联已足够判断，不全/proc遍历。

直接核实真实桌面:2的有界只读命令及返回（原工具调用保留）：
1. env DISPLAY=:2 xprop -root _NET_SUPPORTING_WM_CHECK → window id #0x200002。
2. env DISPLAY=:2 xwininfo -root → root0x38a、5120×1600、Depth24、IsViewable。
3. env DISPLAY=:2 xprop -id 0x200002 _NET_WM_NAME WM_NAME → _NET_WM_NAME(STRING)="xwayland-satellite"；WM_NAME未设置。

这证明owner应用当前被路由至Xvfb :1，而Wayland可见桌面使用Xwayland :2；此前:1隔离截图只证明虚拟显示有画面，不能等同owner桌面可见。当前无依据再改布局、首帧修复或显示服务，也未以MESA/Atk/Impeller/dynamic_color正常提示推断新故障。

### 一次性恢复建议（未代owner执行）

```sh
env -u XDG_CONFIG_HOME -u XDG_DATA_HOME -u XDG_CACHE_HOME -u XDG_STATE_HOME DISPLAY=:2 GDK_BACKEND=x11 fvm flutter run -d linux --no-pub
```

命令只对本次进程移除测试XDG继承，并使用已证实的真实桌面Xwayland :2；不改永久配置、不删除测试目录或owner数据。保留会话原有代理；若FVM需要代理，沿已定环境设置，不升级依赖或生成lock。未要求owner删除配置，未在此执行命令或启动任何新GUI。

architect要求证据落盘后停止：PID1414688未退出/未清理，owner窗口和配置未操作；本轮没有新建自身GUI进程需清理。此前19/31/139为上一启动修复独立冻结历史，本次新增只读路由证据路径单列，未假称这些新证据已包含于旧139项清单或重新复验。产品唯一启动变更仍是此前明确授权的main两行顺序，源代码未再变化。等待architect据此回复owner恢复显示路由，仍不认为owner已经验收；未提交/归档/push，当前停止，不再检查或扩测试/GUI。
