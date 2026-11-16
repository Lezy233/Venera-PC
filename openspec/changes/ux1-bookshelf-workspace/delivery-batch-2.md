# UX1 第二批 F1 进行中

基准HEAD6f1f1bc01ce69be91e62b9474a0b95f83a752d73；第一批授权脏改保留，review-batch-1符合但非owner最终验收。范围tasks3.1–3.6，逐步闭合1.3/1.4对应部分；未提交、不归档/push，不做F2/后续页面重排或阅读工具新交互。所有3.x保持未勾，当前不是交付完成。

已重读review、proposal/design、全部四spec、tasks、acceptance、design-spec v0.2和最新delivery。入口基线batch-2-entry-baseline.sha256是第一批通过后本批扩展前SHA，不覆盖第一批冻结。

拟复用：现有AppPageRoute/Navigator/NavigationAdmission、每标签独立焦点域与chrome绑定、Appdata.updateImplicit原子事务/SettingsSaveState反馈。快照v1绑定目录，以稳定tab/route ID、sourceKey+业务id及原方案id引用，视图状态不替代业务数据。未激活后台栈只建记录，首次激活才挂载；阅读器需真实休眠适配，不以TickerMode冒充停止请求/输入。

真实红灯/tmp/ux1-batch2-tabs-red.log：生产MainPage初始化有效但缺New tab入口，1失败0通过，非初始化异常。新workspace_record/store与测试尚在循环，未接UI。测试初稿throwsFileSystemException matcher不存在，日志/tmp/ux1-batch2-record-loop.log是测试编译问题，不计产品红灯。修matcher后/tmp/ux1-batch2-record-initial-green.log 3通过（含真实文件故障），随后加强目录边界以禁止旧回调对新目录任何写入，循环见/tmp/ux1-batch2-directory-red.log；不以仅字段未变冒称目录隔离。

后续待完成：修正目录零写入边界；接每标签Navigator/路由状态scope和真实收藏/搜索/详情/阅读现场；焦点parentScope全局Tab陷阱验证；标签栏/MRU/设置/可靠快照及新PID恢复；后台请求/加载/阅读活动/关闭残留计数。GUI尚未构建/启动，正常main产物仍第一批恢复版。原第一批harness/helper不能自动当第二批已核准工具，新增fixture先报全文SHA。


## 2026-11-08 额度提醒后的权威进行中交接

本批未完成，3.1–3.6全部未勾，不能把4绿当独立栈完整验收。已实现：workspace_record v1稳定tab/route ID、来源实体arguments/view、目录归属、MRU排除未查看后台标签；workspace_store复用updateImplicit，assignment冻结、revision/owner与目录双重校验；obsolete在事务中抛内部中止以实现真实新目录零文件写入。/tmp/ux1-batch2-directory-red.log 2通过1失败（新目录出现文件），修后/tmp/ux1-batch2-record-green.log 3通过0失败0skip。真实tmp目录阻断写入、重试最新、旧回调、磁盘解码均在测试内。

已接生产UI（不再是“未接UI”）：MainPage desktop进入DesktopWorkspace；NaviPane可承载workspace与导航委托；每tab独立Navigator/chrome/SelectionTaskRegistry、默认lazy mount，AppPageRoute可安装route-local scope；标签条有New tab/All N/hover-focus稳定关闭区域；有当前push/pop与后台记录的初步内部接口、全局chrome当前栈镜像；收藏页面/本地收藏已开始显式capture/restore folder/筛选/选择/滚动/焦点接点。

最新/tmp/ux1-batch2-first-frame.log **4通过0失败0skip**（3记录/存储+1真实MainPage新标签入口）。此前State.activate同名编译冲突与初始化IO等待超时均已明确分列：observer初始安装只sync、不当用户写；binding首帧只capture、不发用户变更保存；真实交互仍自动保存并有反馈，测试在保存时用有界真实IO等待。

当前未满足：独立栈真实收藏现场往返尚未测试；搜索/详情/阅读适配与完整恢复未实现；后台详情生产入口/请求计数未测；阅读器真实休眠未实现；Alt+Left/Ctrl快捷键注册未接；全部列表/关闭/MRU真实命中未验；close/openCurrent接口仅骨架，关闭事务与未知辅助route的恢复边界仍须审核；startup/close策略生产设置尚未接；损坏反馈尚未GUI验证；focus parentScope已放Navigator但内外Tab陷阱尚无真实红绿证据；真实新PID恢复、资源计数和最终GUI未开始。缺失快照当前回收藏，但尚需一次可理解反馈与严格view/args损坏边界验证。不要勾3.x。

下一小循环：扩展test/app_shell/workspace_tabs_test.dart，真实滚轮420、长按/点击选两卡→New tab→返回原tab，核对同page/controller/实体集合/offset，并在每次真实保存使用bounded settleSidebarWork。命令：指定env前缀+fvm flutter test --no-pub test/app_shell/workspace_tabs_test.dart test/app_shell/workspace_record_test.dart --reporter expanded，下一日志/tmp/ux1-batch2-stacks-loop.log。随后运行analyze获得准确新增集合。

截至本段：第二批analyze尚未跑（不能沿用第一批50），第一批相关回归尚未复验。新骨架可能影响MainPage旧初始入口、chrome生命周期和真实IO测试等待，需保留业务断言审核迁移，不称第一批已保护。正常main产物仍第一批恢复版kernel37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8，不是本批构建；本批未构建/启动fixture，未改/tmp已核工具，无本任务GUI运行。额度提醒后不启动来不及收尾的GUI。

当前进度SHA：batch-2-progress-production.sha256（新模块及已扩展生产接点）、batch-2-progress-tests.sha256（2新增测试）。仅进行中快照，非最终冻结。第一批16文件清单保留，因授权扩展必然部分不匹配，不覆盖历史。无提交/归档/push，不做F2或后续工具交互。


## 恢复后最新权威进行中状态（替代上一段未测试/未分析）

/tmp/ux1-batch2-stacks-scope.log：**4通过0失败0skip**。真实收藏A滚轮420px、长按/点击两卡→生产New tab进入B（独立页面且无选择）→真实点击标签栏返回A，核同页面State、同ScrollController、420±0.01px、正确(local,id)两实体集合及同一原FocusNode。首次点击定位同时命中_Tab/内容Positioned同key，/tmp/ux1-batch2-stacks-loop.log 3通过1定位失败；限定生产WorkspaceTabStrip后完整业务断言保留，scope日志通过。

首次analyze /tmp/ux1-batch2-progress-analyze.log为74=50基线+24新增curly_braces提示；已仅修这24项，/tmp/ux1-batch2-progress-analyze-fixed.log **raw/unique50=38tool+12其他**，具体集合added=[]removed=[]；完整集合batch-2-progress-analyze-comparison.json。当前进行中生产/测试SHA已刷新，仍非最终冻结。

已首次复验第一批局部保护，不再称“未复验”：/tmp/ux1-batch2-first-regression.log **4通过3失败0skip**，新增栈/记录4通过；chrome_binding_lifecycle两项因旧fixture未初始化App.dataPath，第一批bookshelf_favorites_continuity一项在新自动快照真实IO下pumpAndSettle超时（line148）。没有删弱原断言，没有冒称293仍保护。待补足旧fixture必要初始化/有界IO，继续核回调稳定性/仅当前栈绑定及同现场。

3.x全未勾。下一最小生产循环为Alt+Left标签内返回（保留原收藏页面/控制器/两卡/offset/焦点且标签不关闭），快捷键应注册既有F3 resolver，输入框不吞键。先修本次已发现的chrome绑定/测试初始化必要接点，不能把局部绿当F1完成。搜索/详情/阅读现场、关闭/MRU/设置、完整坏数据边界、后台请求/休眠计数、新PID/GUI均未闭合。正常main仍第一批构建、第二批未构建fixture，无本任务GUI或临时测试进程留待运行；所有输出均/tmp。


## F1 导航与焦点最新权威增量（进行中，3.x仍全未勾）

真实详情返回 /tmp/ux1-batch2-history-content.log **1通过0失败0skip**：生产收藏420px/两卡→右键Details→真实ComicPage，核sourceKey/id和实际loadComicInfo恰好1次；真实Alt+Left回同标签、同收藏State/controller/offset/实体集合/原焦点，返回不关闭。仅覆盖此路径，不足以完成3.2（后台生产入口等仍缺）。错误fixture返回Res.error时原生产重试4次，已区别于成功请求计数；不改原重试策略。

F3迁移由architect确认：原15动作身份、默认键、自定义/冲突断言保留，逐项核新增5动作。总动作20/全局13；mac新建/关闭Command+T/W，循环Control+Tab及Control+Shift+Tab，其他平台Control+T/W/Tab，返回Alt+Left。design.md D5平台澄清是**planner授权保护diff**，executor未改设计，不称保护零diff。/tmp/ux1-batch2-navigation-green-loop.log 19通过1失败，其中F3和真实Alt+Left通过；唯一失败为chrome绑定回调实例，后用稳定late final回调修复，后续chrome两项已绿。

第一批连续性回归所需fixture目录与真实保存等待已补，业务断言未删弱。/tmp/ux1-batch2-focus-f11-binding.log **28通过1失败0skip**：F11原26和chrome生命周期原2均通过，焦点测试当时因真实保存IO未等待超时；加入既有有界IO等待后/tmp/ux1-batch2-focus-io.log是实际焦点红灯（0通过1失败，14秒结束）。临时[DEBUG-ux1-f1-focus]仍在测试，删除前保留日志。

焦点已证两层真实陷阱：最初F11分组anonymous closedLoop（日志focus-scopes），改为parentScope后遍历推进；随后宽窗bookshelf overlay scope closedLoop再次截住（focus-io）。窄窗覆盖层应保持约束，当前仅宽窗允许退出。本轮误用FocusScope不存在的参数导致focus-wide-scope编译失败（非产品红灯），已改现有FocusScopeNode.traversalEdgeBehavior API，下一单变量命令与日志 /tmp/ux1-batch2-focus-wide-node.log。未增加Tab次数、未删重复焦点检测或收藏实体断言。

进行中SHA已刷新（18生产/7测试，含首批扩展与旧测试适配），不作最终冻结。上一份analyze-fixed为50且集合零变化，但**早于最新快捷键/焦点/生命周期修复，最新analyze尚待跑**。第一批293仅历史；当前未全面复跑相关保护。正常main仍第一批构建；第二批没有build/GUI、未改已核/tmp工具、未启动fixture。后台入口/请求计数、搜索详情阅读完整现场/休眠、关闭MRU设置、可靠快照完整坏数据边界、新PID恢复和GUI均未完成。


## 导航/焦点合跑与后台菜单红灯

/tmp/ux1-batch2-navigation-focus-regression.log **66通过0失败0skip**，含record/真实收藏栈/Alt+Left/外层Tab、原bookshelf shell/matrix/continuity、chrome生命周期、F11和F3。宽窗Scope修复后 /tmp/ux1-batch2-focus-wide-node.log 1绿；临时DEBUG probe已从测试删除，其两层作用域证据留于focus-scopes/focus-io日志。窄窗closedLoop及Escape原覆盖保留合跑。

/tmp/ux1-batch2-background-menu-red.log **0通过1失败**：生产卡片真实右键菜单缺Open in background tab。新workspace_background_test复制真实来源成功加载fixture，从两卡/420px现场逐卡菜单创建3后台记录→All N激活，要求创建零请求/未进MRU，激活各一次且复用页面；不是回调测试。当前正在最小添加WorkspaceNavigationScope记录端口与生产ComicTile菜单，独立Details/主体/选择不改；scope只在工作区暴露，不扩移动/旧独立页面入口。本轮ComicTile为首批基础上的授权F1扩展，最终须更新SHA并复跑B4原语义。

3.1–3.6仍全未勾，后台尚未绿；搜索/详情/阅读现场和阅读器休眠、关闭MRU设置、可靠快照完整边界及新PID/GUI均未完成。下一可运行命令：指定env+fvm flutter test --no-pub test/app_shell/workspace_background_test.dart --reporter expanded，输出/tmp/ux1-batch2-background-menu-loop.log。本批最新analyze待跑，main/fixture状态未变。


## 后台菜单绿与当前analyze权威结果

/tmp/ux1-batch2-background-menu-loop.log **1通过0失败0skip**：三次真实卡片右键菜单建三后台详情，当前收藏同State/controller/两正确实体/420px保持；0请求且未进MRU；All N依次激活各请求1次，正确sourceKey/id，复访同ComicPage State且不增请求。/tmp/ux1-batch2-background-b4.log **101通过0失败0skip**，原comic_hit_target/favorite_hit_target/bookshelf_hit_target断言均保留，含重复后台测试；与前述单跑不累加。66项导航焦点合跑为独立历史轮次，也不累加为本轮总数。

/tmp/ux1-batch2-navigation-analyze.log最初**53raw/unique**，added三条：desktop_workspace.dart的curly_braces(168:7)、prefer_function_declarations_over_variables(43:27,45:27)，removed=[]。已将命名闭包改方法并由late final持有稳定回调，if补block，未修基线。/tmp/ux1-batch2-navigation-analyze-fixed.log最新**raw/unique50=38tool+12其他**，具体集合added=[]removed=[]，比较JSON已刷新。此结果早于后续新实现时须再复验。

当前进行中SHA更新为20生产/8测试；非最终冻结。3.x均未完成未勾：特别未实现阅读器休眠及完整现场、生产关闭/启动策略设置、坏快照/未知route全部边界及真实新PID/GUI。当前下一小循环是实际Ctrl+T/W/Tab/Shift+Tab与输入框不吞键、真实关闭命中/MRU；先以生产键盘/鼠标测试验证，不以F3注册表绿替代。main仍第一批恢复产物，本批无GUI/fixture进程、无/tmp工具变化。不提交。


## 10%余量前权威交接：真实快捷键已绿，继续有界设置循环

/tmp/ux1-batch2-keyboard-loop.log **3通过0失败0skip**（新真实键盘1+原chrome2，不累加既有重复结果）：选两卡/420px→Ctrl+T建C→Ctrl+Tab回A→Ctrl+Shift+Tab回C→Ctrl+W关闭C按MRU回A，同页面/控制器/实体集合/滚动；真实点击TextField后逐个Ctrl+T/W/Tab不新增/关闭/切栈。mac映射逐项由F3注册表测试覆盖，Linux宿主真实键盘不冒称macGUI。

进行中SHA现20生产/9测试，最新可审核源在progress manifests；未最终冻结。最新analyze navigation-analyze-fixed=raw/unique50，38+12，added=[]removed=[]。下一最小循环：在既有APP设置接关闭目标recent/right/left、启动restore/fresh，读取走typed preference，保存复用SelectSetting已有事务，不立即清当前会话。先实际Settings页面点击APP的缺入口红灯，再最小实现与真实磁盘重载/策略未清场景验证。计划命令 env(既定代理/LD_LIBRARY_PATH) fvm flutter test --no-pub test/app_shell/workspace_settings_test.dart --reporter expanded；首次日志/tmp/ux1-batch2-settings-red.log。

3.1–3.6仍全未勾：搜索/详情展开/阅读位置与返回完整适配未做完，后台阅读休眠和资源关闭边界未闭合；关闭真实非当前命中/overflow完整验证与策略设置未完；快照参数/view强校验、未知route/replace、安全回退与一次反馈/真实写入失败UI/新PID恢复未闭合。第一批293仅历史，本批66导航/101B4/3键盘为不同范围轮次不相加。正常main仍第一批产物、无第二批构建/GUI/fixture，/tmp已核工具未改。无提交/归档/push。


## 设置循环现场与有界清理（未报整轮绿）

/tmp/ux1-batch2-settings-red.log实际进入Settings→APP，缺After closing a tab为产品红灯，但当时新fixture缓存清理也卡住，故不冒称已正常退出。已添加desktop APP的关闭目标/启动策略SelectSetting，WorkspacePreferences纳入原默认注册，host typed读取并保留默认recent/restore；中文繁中已补，设置不清当前会话。/tmp/ux1-batch2-settings-loop.log停+1（业务断言含磁盘和重载已走完）未终态，不能报2绿；settings-regression停+20也不报整轮完成。

卡住位于新增fixture teardown：CacheManager队列在fake-async创建，但runAsync直接await dispose导致无法泵原区域。当前单变量修为已有settleSidebarWork(tester, cache.dispose)，保留保存/磁盘/现场全部断言。先前尚未确认退出就启动第二轮回归是本轮过程缺口；已停止重复跑，先单测清理完成再回归。宿主即时/proc核固定Flutter路径和精确参数后SIGINT自身665182/669951/671626，三项匹配均已执行；沙箱ps视图与宿主不等同，不沿用空ps判断，不操作其他程序。

下一命令 env(指定代理/LD_LIBRARY_PATH) fvm flutter test --no-pub test/app_shell/workspace_settings_test.dart --reporter expanded > /tmp/ux1-batch2-settings-cleanup-loop.log。最新analyze50仅在此设置增量之前，须更新；设置/偏好新增后尚无最终保护回归。当前3.x全未勾，GUI/main/fixture状态未变，本批无GUI启动。


## 2%余量时最新权威 handoff（替代前文所有当前状态，仍未完成/未提交）

**当前可恢复实现**：稳定记录/目录/所有者事务骨架、每tab独立Navigator/chrome/tasks、真实收藏现场、Alt+Left、外层Tab逃逸、真实后台详情菜单与延迟加载、F3新5动作及输入框排除已接生产；APP新增desktop工作区设置：关闭recent/right/left（默认recent）、启动restore/fresh（默认restore），WorkspacePreferences纳入原defaults，host typed读取，SelectSetting复用原可靠事务，文案简繁齐全，修改不清当前会话。

**最新设置与清理证据**：settings-red为真实Settings→APP缺入口红灯；settings-loop停+1/settings-regression停+20均因新fixture teardown死锁而无通过终态，不能计绿。原因是CacheManager队列建于fake-async区域，runAsync await dispose阻止原区域泵帧；只改fixture为settleSidebarWork(tester,cache.dispose)，不动生产保存或删现场断言。settings-cleanup-loop **1通过0失败0skip，5秒完整退出**。settings-regression-fixed **24通过0失败0skip，6秒完整退出**（application_preferences/application_behavior_preferences/application_behavior_persistence/settings_page/workspace_settings/workspace_record/workspace_keyboard/chrome_binding_lifecycle）。包含真实选右/左/fresh、appdata.json磁盘内容、loadDataForTesting重新读取且当前栈ID/标签数不变、Alt+Left同收藏State/controller/420px/两实体保持；它不是新PID重启。原故障注入retention denied日志是既有测试预期，不计失败。24/101/66/3/1各轮范围重叠，绝不相加。

**最新analyze** /tmp/ux1-batch2-settings-analyze.log **raw/unique50=38tool+12其他**，与原50具体集合added=[]removed=[]，batch-2-progress-analyze-comparison.json已更新；之前navigation-analyze53的3条新增已明确修复。

**当前SHA**：batch-2-progress-production.sha256为22生产文件，batch-2-progress-tests.sha256为10测试文件（7个F1新测试record/tabs/history/focus/background/keyboard/settings，及3个既有/首批测试适配）。这两份是当前进行中权威快照，不是最终冻结；第一批16/6清单仍留历史，不冒称全MATCH。design.md D5平台映射为architect授权保护diff，独立单列，不报保护零diff；其余保护不得动。无提交/归档/push。

**3.x逐项未满足，全部未勾**：
- 3.1：收藏State/controller/选择/420px及活焦点已绿；搜索方案/关键词筛选、详情展开、阅读位置/章节、跨重启稳定焦点目标等完整适配待做，不能以收藏绿替代。
- 3.2：真实当前详情→Alt+Left保留栈/实体/现场已绿，后台菜单不抢页已绿；搜索/阅读路径及未知辅助route/replace可靠记录仍待闭合。
- 3.3：真实CtrlT/W/Tab/ShiftTab和输入排除、全局Tab两层闭环已绿；全部列表键盘/横向溢出/悬停与稳定关闭坐标/非当前关闭完整真实控件矩阵及GUI待做。mac平台映射注册表已核，Linux输入不冒称macGUI。
- 3.4：MRU默认真实CtrlW返回A已绿；生产设置左右持久化已绿，仍需三标签下左右关闭目标差异、非当前关闭不抢页/不丢焦点、仅未看后台剩余的可用空态真实输入验证。
- 3.5：目录零写入/旧回调/磁盘故障重试记录3绿，设置不清会话已绿；args/view强类型坏数据、未知route/replace边界、缺失记录反馈、生产保存失败重试、快速切换/重载、fresh和restore实际启动、真实终止后新PID恢复尚未闭合。
- 3.6：三部后台创建零请求/首次激活各一次/复访同State无增请求已绿；真实阅读器休眠/输入/自动阅读/请求与共享资源计数、关闭保存退出边界及页码恢复未做完。
- 1.3/1.4仍未勾，红绿仅按上述具体部分，不以书架偏好代替工作区快照。

**下一有界小步**：扩充生产Settings测试为三标签关闭策略对照（真实设置选left/right后实际CtrlW，保留两卡/420px/相同实例），再补非当前悬停关闭和空态。可运行命令 env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_settings_test.dart test/app_shell/workspace_keyboard_test.dart --reporter expanded，建议新日志/tmp/ux1-batch2-close-policy-loop.log；当前设置测试尚未扩充左右目标对照，不能据已有绿冒称覆盖。实际失败再按一个变量修；不盲增Tab/等待，不无差别重跑。

**环境/产物/清理**：本批无GUI构建/启动，正常main仍第一批恢复产物kernel37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8；不是F1源码构建。/tmp原已核harness/helper未改，第二批GUI矩阵/新PID尚未准备，勿直接启动。宿主核/proc精确Flutter路径与完整测试参数后SIGINT自身665182/669951/671626（含最初red清理残留），命令三项matched输出；当前设置单测/回归已正常退出，无无限等待测试；最后应再宿主ps核残留，不能用沙箱ps当宿主。被中断旧fixture可能留/tmp测试临时数据，不能当业务数据或GUI运行，不泛删/tmp。


## 10:47恢复后关闭行为小循环（新权威增量，尚未整项完成）

HEAD复核仍6f1f1bc，保留原授权脏改，3.x全未勾。上次handoff后已宿主ps复核，无匹配自身settings/keyboard主进程和已核BVWOMT/ZSZFLT/MHQROE子进程，diffcheck通过、除D5外保护零diff、当时22生产/10测试SHA全匹配。

新workspace_close_policy_test实际Settings→APP选择left/right→磁盘重载→三标签A/B/C中激活B→CtrlW，核正确邻居及A原State/controller/两实体/420px和原FocusNode；另鼠标hover非当前C，核tab几何不动、真实关闭按钮坐标关闭不抢A/原焦点。/tmp/ux1-batch2-close-policy-loop.log **1通过1失败0skip**：right通过；left正确页面/实体/滚动通过但焦点是已销毁B ModalScope，line377精确原FocusNode断言红。未删除焦点断言。

根因假设按优先级：record.close先更新activeId，activateTab读“previous”已成目标A，将仍在B的primaryFocus覆写A已记目标；其次卸载恢复时序；定位错误可能性较低（right手动回同A节点通过）。当前最小修复activateTab可跳过rememberPrevious，关闭当前时以false激活model已选目标；关闭非当前时不重复激活当前A、不改MRU/不重写焦点。新workspace_empty_test通过真实菜单建三未看后台，CtrlW关两个已看标签后要求可用空态与0请求，再真实Open favorites恢复操作，不调用回调设置现场。

当前/tmp/ux1-batch2-close-focus-loop.log正在运行上述2文件，预计3场景，未出终态前不报绿。22生产/12测试进行中SHA已刷新。最新analyze50为本次close修复之前settings-analyze，close改后待复验；上一24设置保护不重复全跑，按关闭影响范围补keyboard/record/chrome/focus。无GUI/main构建或工具变化，不提交/跨F2。下一命令本轮指定env+flutter test --no-pub test/app_shell/workspace_close_policy_test.dart test/app_shell/workspace_empty_test.dart --reporter expanded，输出close-focus-loop。


## 关闭策略任务3.4生产测试闭合

/tmp/ux1-batch2-close-focus-loop.log **3通过0失败0skip**（left/right+空态）；/tmp/ux1-batch2-close-regression.log **10通过0失败0skip**（追加keyboard/focus/record/chrome范围，和前3重复，不相加）。第一假设已证：关闭model先选目标后，误将仍在被移除栈的焦点记进目标；跳过该次rememberPrevious后left返回原节点。关闭非当前标签不再重新激活当前，保留内容/焦点且不重排MRU。原两卡/420px/控制器State/真实坐标断言全保留，无新诊断probe。

依据上述完整3.4自身范围，已即时勾3.4并备注；其余3.1/3.2/3.3/3.5/3.6及1.3/1.4仍未勾。7.x GUI/真实PID与阅读器关闭退出边界后续单独闭合，不把3.4局部任务通过冒称F1完成。下一小循环：记录args/view强校验的真实恢复失败反馈，先用缺失/损坏快照启动生产MainPage得到红灯，再安全回退并保留收藏数据；未知route/replace和搜索/阅读现场仍待处理。


## 恢复强校验/反馈小循环已绿（3.5仍未完成）

recovery-red初稿四个恢复失败因fixture准备插入teardown且loadDataForTesting只读appdata而非implicit，不能计产品红灯；独立record错误title类型被接受为真实解析红灯。修fixture为挂载前写真实implicitData/appdata并清内存后调用生产doInit载入，/tmp/ux1-batch2-recovery-startup-red.log **5通过3失败**：missing无反馈、bad-view静默接受及record类型不校验；bad-version/unknown-route既有回退已绿。

最小修复只校验既有工厂/收藏capture使用的已知字段（来源/id、title/cover/profile、keyword/options、chapter/page、focus、收藏嵌套view标记/offset/选择实体id+sourceKey+type等），错误则FormatException在工厂挂载前回退；未知惰性JSON字段不改写。missing按D9新增一次可Dismiss反馈并补简繁，不改fresh策略。/tmp/ux1-batch2-recovery-loop.log **8通过0失败0skip**（4真实磁盘启动+4record存储/解析）；四场景均安全首页、60收藏实体集合与无关key保持，真实Dismiss/New tab后提示不循环。生产doInit加载不是新PID，后者仍待GUI。

22生产/13测试进行中SHA已刷新。close-analyze为raw/unique50但早于这次record/feedback修改；当前analyze待跑。3.4已完成，其余3.x仍未勾。下一有界测试是生产工作区自动保存真实目录阻断→可见Retry→实际点击修复最新磁盘快照；不能以record unit故障替代UI反馈。正常main/无GUI/工具状态未变。


## 保存失败UI真实红灯已修复（待去probe复验）

/tmp/ux1-batch2-save-feedback-loop.log **0通过1失败**：真实目录阻断→可见Retry、旧磁盘完整保留、点击Retry成功均通过，但完整磁盘快照与host比对失败，第三新tab的view={}缺favorites/local-favorites，不是定位问题。Timer在新tab首帧前freeze，Retry正确重放了不完整快照。改保存捕获等待endOfFrame，配saveRevision排除旧等待/flush回调。

/tmp/ux1-batch2-save-frame-loop.log仍0通过1失败，但提前于故障注入的A/B/A原FocusNode断言；新增临时[DEBUG-ux1-save-focus]证据 /tmp/ux1-batch2-save-focus-probe.log：remembered正确、restore canRequestFocus=false。原因activateTab仅经chrome postFrame setState更新UI，restore在同postFrame时A仍被ExcludeFocus；旧保存额外rebuild掩盖该时序。最小改激活动作立即setState，先解禁当前栈再帧后归还焦点。

/tmp/ux1-batch2-save-activate-loop.log **1通过0失败0skip，3秒完整退出**：原全部反馈/原磁盘/重试后完整当前快照/快速两次New tab最新磁盘快照/同A State/controller/两实体/420px/原FocusNode断言均保留。probe已从生产删除，日志保留，下一单跑save-feedback-green与相关activation/close/recovery回归后再更新权威。这次生产改动仅desktop_workspace，scope因probe移除恢复原逻辑。当前3.4已勾，其余3.x仍未完成。最新analyze50早于本次保存/强校验修改，待跑。无GUI/main新构建或fixture。


## 保存/恢复合跑暴露关闭释放回归及修复

去probe后原保存失败UI单跑 /tmp/ux1-batch2-save-feedback-green.log **1通过0失败0skip**，原完整强断言已闭环，不借后续矩阵绿替代。随后save-recovery-regression **18通过3失败0skip**：原保存/恢复通过，left/right/empty在末尾takeException零异常断言捕获DesktopChromeController used after disposed。已即时重新打开3.4，历史通过不冒称当前通过。

/tmp/ux1-batch2-close-dispose-probe.log精确栈 ChangeNotifier.notifyListeners→DesktopChromeController.setRightSidebar→LocalFavoritesPage.dispose→StatefulElement.unmount。被关栈只经postFrame安排下一帧rebuild，controller却在本帧postFrame提前dispose。最小改close删除_tabs后立即setState确保下一帧先卸载子树，再释放其chrome/bindings；保留全部dispose通知，未改业务页面或吞异常。probe已移除。close-dispose-green **4通过0失败0skip**（原保存UI+三关闭场景）。当前save-recovery-green重跑同13文件21场景，未出终态前不回勾3.4。

recovery-analyze初次**51raw/unique**新增仅recovery_test.dart:134:11 curly_braces；已补block，recovery-analyze-fixed在运行。进行中manifest已更新22生产/14测试。所有3.x此刻仍未勾（3.4因上述回归已重新打开），搜索/阅读尚未开始写生产适配。GUI/主产物/工具不变。


## 保存/恢复本轮最终权威绿与下一搜索适配入口

/tmp/ux1-batch2-save-recovery-green.log **21通过0失败0skip，17秒正常退出**，与先前18绿3红同一组合，包含原保存失败UI强断言以及全部失败关闭场景；未删弱takeException、真实焦点、两卡/420px/同实例断言。3.4已在完整复验后重新勾上，并保留回归与修复历史。其余3.x及1.3/1.4仍未勾。/tmp/ux1-batch2-recovery-analyze-fixed.log当前**raw/unique50=38+12**，具体集合added=[]removed=[]；JSON已更新。probe均移除，证据分别留save-focus-probe/close-dispose-probe，22生产/14测试进度SHA已刷新。

接下来才开始搜索现场适配：复用WorkspacePageScope，SearchPage保存每tab关键词/临时来源与方案/选项/焦点/滚动，SearchResultPage保持来源/options和页码滚动，聚合保留profile引用，既有F8仍负责本机新入口默认记忆，不能让B的选择通知改写A现场。先在生产MainPage真实搜索路径构造A/B不同来源/选项/关键词的红灯；F2搜索多选新交互仍不提前。还未写这些页面，下一条可运行命令待workspace_search_state_test新增。正常main/无GUI/工具状态不变，无提交。


## 搜索入口独立现场最小红绿（3.1仍未闭合）

/tmp/ux1-batch2-search-entry-red.log **0通过1失败**：生产MainPage→Settings后顶栏搜索提交打开SearchPage，A选Platform A/Other/Alpha，B选Platform B/Normal/Beta，回A被B显式记忆通知改成Platform B。根因SearchPage旧settings listener每次从F8全局选择重读。新增WorkspaceViewState仅工作区实例保留本tab_selection，仍检查来源/方案可用性；无workspace旧F8监听行为原样，新入口仍读全局记忆。capture/restore query/source/profile/options/scroll和稳定焦点锚，search nested view强类型校验；未改结果布局、普通单源接口或提前F2多选。

search-entry-loop **25通过1失败0skip**：原F8全部25绿；新增测试在B来源保存后pumpAndSettle超时，未到独立性断言。原因F8保存完成通知后新排工作区快照，原helper只排空一段IO。改为bounded SearchSelection.isSaving真实事务完成后再泵debounce并排空工作区IO；不增加动画等待、不删来源/焦点/磁盘现场断言。search-save-phases **1通过0失败0skip，8秒正常退出**，A/B来源/临时选项/输入/原FocusNode及记录view通过，编辑入口0请求。

正在扩同一测试：新增C入口应仍读F8的B默认、query/options临时值不漏；真实Back返回A下层Settings再原收藏，保留原两卡/420px/State/controller/焦点。下一命令指定env flutter test --no-pub test/app_shell/workspace_search_state_test.dart，日志search-entry-final。SearchResult/aggregate详情阅读现场仍未实现，3.1/3.2不勾，3.4保持上一21绿完成。新增source文件search_page已在入口baseline记录扩展前SHA；最新analyze50早于本次SearchPage修改，需复验。


## 搜索入口当前权威绿

search-entry-final **1通过0失败0skip，11秒**：新增C仍读F8 B默认、临时query/options不漏；真实Search Back→Settings Back回A收藏同State/controller/两实体/420px/原FocusNode。search-entry-protection **14通过0失败0skip，10秒**（新增入口+F6/F7方案flow/model+record）；F8原25通过已在search-entry-loop记录，不因新测试helper/断言扩展无差别再跑。search-entry-analyze **raw/unique50=38+12，added=[]removed=[]**，集合JSON刷新。23生产/15测试进度SHA均已更新。

下一结果页小循环计划：真实Alpha单源Other查询→Next第二页→滚轮420→记录分页/滚动与正确source/options→详情→真实返回及跨tab不重复请求。现SearchResultPage还没有workspace view，ComicList当前页仅State/PageStorage；先实际控件产生现场红灯，再最小接页码/scroll并显式限定普通ComicList默认不变。聚合/详情展开/阅读现场和休眠、真实PID/GUI仍未闭合，3.1/3.2/3.3/3.5/3.6保持未勾。main仍首批旧构建，本批无GUI。


## 结果页现场适配当前进行中（不冒称全栈完成）

搜索入口上一轮14保护绿/50零新增保持历史。结果页新增workspace_search_results_test真实单源Alpha/Other→Next第二页→滚轮420→跨tab→真实右键Details→AltLeft回结果再入口。search-results-red先因Dart record内List身份比较误报相同请求，属fixture matcher；改深内容断言后search-results-view-red **0通过1失败**，实际第1/2页精确请求与420均通过，但route.view['search-result']==null，为真实生产缺口。

现在SearchResultPage接WorkspaceViewState捕获/恢复keyword/input/source/options/page/scroll与查询焦点锚；ComicList仅加initialPage默认1和可选onPageChanged接口，原renderer/布局opt-in及默认行为不变。源/source+options变化重置该结果位置，nested view校验已补。第一个loop已过快照/实际420，失败在测试错误要求ScrollPosition身份，实际physics由Bouncing切NeverScrollable时现有SmoothScroll会替换position并保留offset。依lib/components/scroll.dart既有契约，修为**同外部生产ScrollController+当前真实offset**，页面State/实体/请求次数/详情返回强断言全保留，不改physics生产行为。

当前search-results-controller运行中，未出最终绿；25生产/16测试进度SHA已刷新。本轮结果/ComicList修改后的相关paging/lifecycle/B4和analyze均待复验，不沿用上一50。3.4已勾，其余3.x仍未勾；聚合/详情展开/阅读现场/休眠、新PID/GUI及未知辅助route/replace等仍待闭合。正常main仍首批旧构建，无本批GUI/fixture启动。


## 结果页本轮最新权威交接（替代前文结果页进行中状态）

search-results-controller **1通过0失败0skip，17秒完整退出**，真实Alpha/Other单源精确第1/2页、Next/420px，结果view含page/source/options/keyword/offset；跨B再回A同SearchResult State/外部ScrollController及当前420px。真实卡片右键Details仅正确来源a/实体id请求1次；Alt+Left回原结果不重载，再Alt+Left回原搜索关键词Alpha/Other；未调用导航回调建现场。其前view-red是真实缺口；record内List matcher误报、physics更换ScrollPosition的定位修正均按前文分列，不伪称产品根因。

/tmp/ux1-batch2-search-results-protection.log **100通过0失败0skip**（同结果测试+普通ComicList/paging/lifecycle、B4 comic_hit_target、bookshelf_density_isolation）。共享列表仅initialPage默认1和可选page通知，原独立普通列表默认尺寸/renderer/分页业务断言均保留；不与单跑1绿累加。/tmp/ux1-batch2-search-results-analyze.log **raw/unique50=38tool+12其他**，具体集合added=[]removed=[]，比较JSON刷新。

最新权威进行中SHA：batch-2-progress-production.sha256 **25生产**，batch-2-progress-tests.sha256 **16测试**，均已重算；第一批历史manifest保留，不作当前冻结。3.4已勾，其余3.1/3.2/3.3/3.5/3.6及1.3/1.4未勾。下一小步补结果页实际磁盘重载的初始分页/scroll工厂路径，当前绿只证明保留State切换+捕获view，不能冒称initialPage从磁盘已验；之后再聚合/详情展开与阅读现场休眠。未知辅助route/replace、完整存储/目录切换、新PID/GUI仍待闭合。

本批无GUI或fixture启动，正常main仍首批旧kernel；工具无改。没有提交/归档/push，D5仅planner已授权映射差异，其余保护仍不得改。


## 10%余量时当前权威handoff：结果磁盘已验，聚合仅真实红灯

/tmp/ux1-batch2-search-results-disk.log **1通过0失败0skip，17秒退出**：先真实当前页快照与implicitData.json全等，卸载旧MainPage/清implicit内存，经生产doInit从同目录文件重载后挂载新Workspace；稳定tab顺序/activeID恢复，新Result State和新ScrollController恢复第二页420px，正确Alpha/Other仅额外请求第2页1次，两个未激活搜索栈零请求，60收藏保持；真实返回搜索Alpha/Other保持。此为**同进程实际磁盘重载/新State，不是新PID**，不得替代后续GUI重启。前述100保护绿与50具体集合零增减是该新增磁盘断言之前的生产源码同一版保护，当前只有测试扩展。

/tmp/ux1-batch2-aggregate-red.log是新fixture局部saved重名编译错误，不计产品红灯；已改名。/tmp/ux1-batch2-aggregate-view-red.log **0通过1失败，16秒退出**：真实设置方案Plan ABCDE、GroupQuery聚合→滚轮420实际成功，但view['aggregate-search']==null（line427），为生产现场缺口。**此刻聚合生产文件未改**。

当前权威进行中SHA：25生产/17测试（包括已扩磁盘结果测试和未过的聚合测试），progress manifests已重算，非最终冻结。3.4已勾；3.1/3.2/3.3/3.5/3.6及1.3/1.4仍未勾。阅读位置/章节、详情展开、后台阅读休眠与资源计数、未知辅助route/replace、完整标签键盘/溢出、新PID/GUI仍缺；本批没有GUI构建/启动，正常main仍第一批旧kernel，工具未改，不提交。

下一最小修复：AggregatedSearchPage接WorkspaceViewState保存实际keyword/input、profileID及已应用sourceKey/options上下文、scroll/focus；恢复不因别标签选择或方案变化重写已应用来源，不修改来源/方案业务记录。缺失源须保留身份、显示不可用且不回退发给别源。先跑指定env fvm flutter test --no-pub test/app_shell/workspace_aggregate_state_test.dart --reporter expanded > /tmp/ux1-batch2-aggregate-loop.log，再按影响范围跑F6/F7/F8/profile与相关workspace、analyze具体集合。当前analyze50来自search-results-analyze，聚合改后须再验。


## 4%余量优先持久化：聚合1绿，保护/analyze收尾中

/tmp/ux1-batch2-aggregate-loop.log **1通过0失败0skip，15秒正常退出**，真实Plan ABCDE聚合GroupQuery，420px非零滚动、sourceKey/options/keyword/profileID快照，以及切B再回A同聚合State/ScrollController/420px且不增请求；普通源各至多一次，已请求者核GroupQuery/1/该源方案options，未以回调建现场。

聚合最小改动：WorkspaceViewState保存input/keyword/profileID、实际应用的sourceKey/options列表与scroll/focus。恢复用捕获的来源上下文，不写方案/来源业务数据；缺失源保留ID/选项并显示不可用，不发给其他源。该缺源显示路径目前尚未独立实际删除源验证，聚合磁盘恢复亦未验，不能把capture/restore实现冒称完成验收。nested aggregate view字段强校验已补，简繁新文案已补。

当前权威进行中manifest已更新**26生产/17测试**。/tmp/ux1-batch2-aggregate-protection.log（F6/F7/F8/profile/record+聚合）与aggregate-analyze运行中，不能提前报计数或沿用前50。最终将补具体集合差异；如额度阻断从此精确日志继续，勿重做首批。

任务状态：仅3.4当前已勾；3.1/3.2/3.3/3.5/3.6及1.3/1.4未勾。剩余：聚合真实磁盘恢复和缺源边界；详情展开/焦点适配；阅读位置/章节、后台休眠/请求/加载/输入/资源计数与关闭保存退出边界；未知辅助route/replace及eager builder风险；标签横滚/全部列表键盘/稳定关闭命中/长标题/溢出完整矩阵；完整快照快操作/损坏/数据目录切换与fresh/restore生命周期；真实新PID恢复与最终GUI。已有21保存/恢复、100结果保护、14入口保护、25F8等不同范围轮次重叠不累加。

本批从未GUI构建/启动，正常main仍第一批kernel37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8（非当前F1源码构建）；/tmp已核工具未改，不启动fixture，不提交/归档/push。后续GUI必须先报全文SHA核准；当前保留所有授权脏改。


## 17:01恢复后的权威状态校正：聚合保护已结束

上一节运行中状态已过时：/tmp/ux1-batch2-aggregate-protection.log **39通过0失败0skip**；/tmp/ux1-batch2-aggregate-analyze.log **raw/unique50=38+12，added=[]removed=[]**，具体集合见batch-2-progress-analyze-comparison.json。现26生产/17测试manifest均核对MATCH，保留授权脏改，HEAD仍6f1f1bc。此轮不重复已核39项。

下一有界循环仅扩聚合真实磁盘恢复：实际文件全快照对照→卸载MainPage→清implicit内存→生产doInit→新MainPage，核新State/controller、稳定标签ID、方案/来源/options、420px及未激活栈零请求。此为同进程实际磁盘，不代替新PID。仅3.4已勾，其余3.x及1.3/1.4未勾。阅读/详情/未知route/完整输入矩阵/新PID/GUI仍待完成。无本批GUI/main构建，已核工具未改，未提交。


## 聚合实际磁盘恢复闭环

/tmp/ux1-batch2-aggregate-disk.log **1通过0失败0skip，15秒**。保留原收藏两卡/420/State/controller/焦点与聚合跨tab断言后，比较实际implicitData.json全快照，卸载MainPage、清implicit内存、生产doInit重载；新host/aggregate State/ScrollController恢复原tab顺序/activeID、完整aggregate view（keyword/input/profileID/五来源/options/420px）。新增请求只为当前聚合GroupQuery/1/准确来源选项，每源至多一次，未激活Alpha/Beta搜索栈不提交；60收藏仍在。此为同进程磁盘重载，非新PID。无需生产修改；26生产SHA不变，17测试manifest已刷新。

下一循环详情真实展开控件→快照/跨tab/磁盘恢复；已有AltLeft/收藏保护断言保留。仅3.4完成，其余未勾，analyze50仍为本轮生产相同源码，测试扩展后尚未再analyze。GUI/main/工具状态不变。


## 详情展开现场有界循环：普通详情已绿，分组对照进行中

详情真实红灯 /tmp/ux1-batch2-details-view-red.log **0通过1失败**：点击Show all (80)已展开、滚动非零，但comic-chapters view为null。ComicPage接既有WorkspaceViewState存scroll；普通章节存expanded，分组章节存expanded与实际group名称；record补对应类型校验。未改布局/章节排序/阅读入口。新增源文件扩展前SHA已追加entry-baseline。

初接入details-loop与details-update-loop在详情打开后的pumpAndSettle超时。/tmp/ux1-batch2-details-change-probe.log只出现加载开始/完成两次通知，不足以证循环。临时probe已删除。真正阻塞在加载完成后新排的第二段工作区保存，fixture改为debounce后等待实际host.waitForSettingsSave，details-save-loop **1通过0失败0skip，7秒**。曾猜测普通章节didUpdateWidget必须去setState，随后仅恢复旧同步点作单变量对照 details-old-update-control **1通过0失败0skip，7秒**，排除此必要性，生产保留原同步点，未借故清理。

完整普通详情绿保留原收藏两卡/420/State/controller/原FocusNode、实体/来源、一次详情请求、AltLeft不关闭断言；新增展开/非零详情滚动、跨tab同详情State/controller不增请求，实际文件快照全等→卸载清implicit→doInit→新State恢复展开/offset/实体且仅当前详情新增一次请求。非新PID。现details-groups运行中，额外覆盖真实切Volume B与组身份恢复，未出最终计数。28生产/18测试进度manifest已刷新；本轮生产修改后保护/analyze待验，不能沿用上一50当最终。仅3.4已勾。GUI/main/工具无改。


## 详情当前权威闭环：原失败保护已复验，不以新矩阵替代

首次details-groups **1通过1失败**仅因fixture用Flutter TabBar查找生产AppTabBar，真实Volume B点击已完成；修为生产AppTabBar.controller索引断言且保留group身份。随后details-protection **13通过1失败**，分组/普通详情均绿，唯一旧workspace_history在详情打开后pumpAndSettle超时；仅给该旧fixture补第二段debounce后有界waitForSettingsSave，不删改其任何AltLeft/正确实体/两卡/420px/同State/controller/原FocusNode/一次请求断言。**同一六文件组合** /tmp/ux1-batch2-details-protection-green.log **14通过0失败0skip，13秒**，闭合原失败。测试中chapter_order_persistence的预期注入保存故障日志不作新增失败。

详情生产修改最终仅ComicPage scroll、普通章节expanded、分组章节expanded+group名称、record字段强校验；didUpdateWidget原逻辑保留，probe全删除。新增详情测试两场景均真实输入/跨tab不重请求/实际磁盘doInit新State恢复；不是新PID。/tmp/ux1-batch2-details-analyze.log **raw/unique50=38+12，added=[]removed=[]**，JSON具体集合已更新。最新28生产/18测试manifest重算，非最终整批冻结。

仅3.4已勾，3.1/3.2/3.3/3.5/3.6及1.3/1.4仍未勾。下一阅读器有界循环：先真实读入/翻页→标签后台切换，用自动阅读/章节与图片加载计数构造休眠红灯，不把Offstage/TickerMode当休眠证据。未知route/replace、完整标签输入矩阵/存储边界/新PID/GUI仍待完成。正常main仍第一批旧产物、本批从未GUI构建启动，工具未改，无提交。


## 阅读入口循环进行中：真实Read离栈红灯与一次加载缺口

reader-entry-red为测试ReaderState导入编译错误；reader-stack-red暴露fixture缺正常main提供的ReaderSessionScope，均非产品根因。补正常scope/类型resolver后 reader-owned-stack-red **0通过1失败**，实际Read使用rootContext.to覆盖工作区，完成过渡后WorkspaceTabStrip为0；同时ReaderScaffold.didChangeDependencies→setReaderActions触发build-phase通知异常，原堆栈保留。

最小改ComicPageActions.read仅WorkspacePageScope存在时使用本页context入当前Navigator，并保持同onClosed/then(onReadEnd)；普通路径仍root。workspace_pages新增直接Reader的实体/source/initial位置描述。ReaderScaffold将chrome绑定延迟post-frame（含旧绑定身份清理、控制器替换检查），未改任何工具交互。reader-current-stack-loop已过标签栈身份，失败于同book-4/ep-1加载两次。reader-position-red补先初始化正常ComicSourceManager仍两次，排除此假设。

/tmp/ux1-batch2-reader-double-load-probe.log确认同会话ReaderImages先init239070693后init910678750并dispose旧，均请求同实体同章节。生产thumbnail初载前无panel，加载后插入panel改变内容子树位置；仅ReaderScaffold添加稳定KeyedSubtree保持原阅读内容，reader-stable-content-loop **0通过1失败**但一次章节加载断言已通过，当前失败推进到真实方向键翻页仍1期望2。此时尚无ReaderState workspace view/activation适配，后台休眠未完成，不能报绿。probe已删除，lib/features/reader/images.dart无diff。下一reader-focus-position-red先核真实reader.focusNode.hasPrimaryFocus并使用默认PageDown，区分焦点/输入与页码capture；不放宽一次请求断言。

最新30生产/19测试进度SHA已刷新。详情14保护绿与analyze50零集合差异是阅读修改前历史，本增量未跑保护/analyze；B3/F9/B5/主题回归仍待。仅3.4已勾，其余保持未完成。无GUI/fixture/main新构建，工具未改，无提交。


## 阅读当前权威handoff（28%提醒时）：初始焦点已定位，卸载捕获待复验

reader-focus-position-red **0通过1失败**：真实reader.focusNode.hasPrimaryFocus=false。/tmp/ux1-batch2-reader-focus-probe.log具体节点 primary=FocusNode#62873(local-favorites-selection PRIMARY FOCUS)，reader=FocusNode#13b98、canRequest=true、所属Reader content Scope。根因下层收藏仍多选，onRead更新触发其rebuild，旧build postFrame无active判断抢焦点；不是增加Tab或测错ancestor。LocalFavoritesPage仅在WorkspacePageScope.active路由允许canRequestFocus及两处主动requestFocus，选择/实体/原返回节点不变。

ReaderState现已接WorkspaceViewState记录源图片page、chapter和chapterId，并按binding.active与平台foreground组合驱动既有ReaderSession.setForeground；后台hold ImageWork新任务、停止键盘持续输入并清快捷键会话，暂停平台/native窗口效果；激活释放hold并帧后还焦点。此为实现，后台自动阅读/输入/新加载/关闭计数尚未验证，不冒称休眠通过。reader-activation-loop在下层抢焦点修复前仍0绿1红；reader-focus-owner-loop后真实焦点/实际PageDown到2/reader view2+chapter1/准确一次章节加载已过，但最终卸载发生Null check：ReaderState.captureWorkspaceView→pageLayout→isPortrait→MediaQuery.of，在失效Element上读取。

最小修复：capture在布局仍有效且图片已加载时缓存源图片索引；_stateDisposed时仅读缓存，不在detach期间读MediaQuery。/tmp/ux1-batch2-reader-position-green.log当前运行中（需读最终退出，不能提前报绿）。一次加载稳定子树key已由之前2次→1次断言证明；ComicSourceManager预初始化没消除2次，排除该原因。方向键未翻页归因真实焦点已证，不以换PageDown代替焦点修复。所有临时probe已移除，reader/images.dart无diff。

当前31生产/19测试SHAmanifest已重算（含reader_page/local_favorites_page/scaffold/actions/workspace_pages/record变化），非最终冻结。旧details-protection-green14与details-analyze50仅阅读改动前证据，当前阅读保护/analyze均未跑。仅3.4已勾，其余3.x及1.3/1.4未完成。剩余：后台真实自动阅读/输入/新请求与关闭资源计数；阅读真实磁盘/章节身份与缺源恢复；B3持续绑定/跟随默认、F9排序、B5图片尺寸与主题保护；未知route/replace、完整标签矩阵、新PID/GUI。无本批GUI/fixture启动，正常main仍首批旧产物，工具未改，未提交。

下一准确命令（先读当前position-green，若绿再扩后台真实工具输入）：env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_state_test.dart --reporter expanded；日志用新的/tmp/ux1-batch2-reader-dormancy-loop.log，不覆盖上述红灯。


## 13%余量权威handoff：后台强断言已过，退出一次仍红

/tmp/ux1-batch2-reader-position-green.log **1通过0失败0skip，4秒**，真实焦点/PageDown2/一次章节请求/view及卸载零异常已闭环。随后扩真实canvas打开已有工具→点击Start or stop automatic reading→切B。reader-dormancy-loop **0通过1失败**：此前所有强断言已过：actual自动阅读后台status=paused；imageWork.start()==null拒新请求；后台键盘PageDown+2秒后页码不变、source章节请求数不增、reader无焦点；回A同ReaderState/ReaderGalleryViewState、第2页、primaryFocus、自动阅读恢复且总章节请求仍1。真实停止工具后AltLeft退出，唯一业务失败readerClosed期望1实际2，并有ReaderScaffold.dispose→setReaderActions树锁定通知异常。未减少计数/页码/零异常断言。

reader-retire-loop仍0通过1失败，仅退出通知2，树锁定异常已修：DesktopChromeController.setReaderActions立即撤销动作，persistentCallbacks内通知延postFrame且dispose后不通知；不丢动作清理。猜测路由inactive→session.foreground修订曾加guard，但/tmp/ux1-batch2-reader-session-notify-probe.log已证实际通知revision7 finalize=false/held1，随后revision8 finalize=true/held0；两者间无setForeground或scheduleProgress新调用，排除此猜测，须移除该无证guard。真正线索ReaderExitGuard子dispose先release准备hold，ReaderSession.duration恢复，再父ReaderState.dispose发现duration正在running产生revision8。下一单变量：仅工作区已失活route释放已准备退出hold时，先_closeSession完成冻结，防止子卸载短暂恢复计时；正常返回失败/仍活跃route仍可释放恢复。尚待此对照证实，不能现在称根因最终闭合。

现31生产/19测试SHA已重算，但reader_session.dart有临时DEBUG探针（不在生产manifest，不能冒称冻结完整）；需在该文件移除foundation导入及setContentReady/setForeground/scheduleProgress/_drain探针，恢复原逻辑并核零diff，日志保留。reader/images.dart探针已移除零diff。当前阅读源码保护/analyze仍未跑，旧详情50不作当前证据。仅3.4完成，3.6及其他未勾。

下一准确命令：env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_state_test.dart --reporter expanded > /tmp/ux1-batch2-reader-exit-freeze-loop.log 2>&1。出绿后仅最必要workspace返回/关闭/focus+reader B3/F9/B5/主题保护与analyze；不开新磁盘/GUI大循环。main仍首批旧构建，无本批fixture，工具未改，无提交。


## 2026-11-09 00:06恢复：最新权威绿与进行中边界（替代末尾旧退出红灯状态）

/tmp/ux1-batch2-reader-exit-freeze-loop.log **1通过0失败0skip，7秒**，已修退出一次通知：工作区已离开的route释放准备hold前先_closeSession冻结；未关闭route/失败恢复仍保留释放恢复语义。原retire-loop红与session-notify-probe均保留。探针全删除；reader_session.dart与images.dart均核git零diff，排除过的foreground guard也已移除。真实后台自动阅读/输入/请求/同State与viewport/页码2/焦点及返回原收藏两卡420px断言全保留；AltLeft后onClosed=1、controller disposed、imageWork拒新任务与takeException零异常已绿。

/tmp/ux1-batch2-reader-protection.log **272通过0失败0skip，16秒**，包含原workspace_history/详情普通与分组/焦点/关闭/保存/chrome生命周期、B4真实命中、B3绑定/继承/恢复、F9排序、gallery_viewport_rendering（B5完整比例视口）、page_layout/session/浅深shell。不能冒称B5实际ReaderScaffold全组合及全部reader_exit_integration已跑。/tmp/ux1-batch2-reader-analyze.log初为55；具体新增5条均本批四文件curly_braces（reader_page两条、scaffold一条、local_favorites_page一条、新reader测试一条），已补block。/tmp/ux1-batch2-reader-analyze-fixed.log **raw/unique50=38+12，added=[]removed=[]**；JSON具体集合已更新。272后仅这5处花括号/format变化，未无差别重跑。

最新31生产manifest SHA63a708f506148a8bae959d4aa5bed9788f9b745fe96b5b08e80f861c1f3098d5；19测试manifest SHA90fd4dac5c41721200dd052787873820b2c901f9ab6e0e15264004c802b2f4b6，恢复时均逐文件MATCH，非整个F1最终冻结。protected除planner D5外零diff，D5 SHA15614692095a360b465b7e3a167cc2be9d78f1a239ad9dbb605d7d5e3a50ab78保持；git diff --check通过。HEAD仍6f1f1bc，保留授权脏改。

仅3.4已勾，其余3.1/3.2/3.3/3.5/3.6及1.3/1.4未完成。剩余逐项：阅读实际磁盘恢复（含源图片页/章节ID及章节重排）、缺失/卸载来源保身份零替代请求；多个reader同时存在仅当前活动、直接关tab的保存/资源/准确通知计数；B5真实ReaderScaffold完整回归；未知辅助route/replace与eager builder风险；标签完整键盘/横滚/全部列表/关闭命中矩阵与全局Tab陷阱；完整目录切换及快照边界；真实新PID恢复与GUI。第一步从真实阅读第2页文件保存/卸载清implicit/生产doInit再挂载新MainPage补证，不以模型重建代替磁盘。

本批无GUI构建启动，正常main kernel仍37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8，为第一批旧构建。现核/tmp/ux1_gui.dart与/tmp/ux1_x11.py均已不存在（未重建、不冒称当前可执行已核工具；其历史SHA仅历史证据），新GUI必须提供全文SHA重新批准。未提交/归档/push，不跨F2。


## 阅读实际磁盘/章节身份/缺源恢复闭环（仍非新PID）

reader-disk-red **0通过1失败**，前段全部阅读/后台/退出保护仍过，磁盘全等/标签重载已过，但ReaderWithLoading恢复调用全局HistoryManager而非已挂载HistoryScope，报History database is closed。这是隔离视图store归属问题；正常main全局已初始化，不称所有正常启动必坏。最小仅loading.dart改late final入口loader并findHistory经HistoryScope.read(context)，无scope时沿既有fallback全局，不改历史业务存储。新增生产入口baseline记录扩展前SHA。reader-disk-scope-loop **1通过0失败0skip，9秒**。

/tmp/ux1-batch2-reader-disk-identity.log **1通过0失败0skip，9秒**：真实详情Episode 2控件→实际PageDown2→当前真实implicitData文件全快照对照→卸载清内存doInit→新host/ReaderState；中间仅受控来源返回章节映射由ep-1/ep-2换为ep-2/ep-1，仍恢复ep-2（新index1）与源图片page2，新增准确一次(first.id,ep-2)，非当前tab不发请求。再从真实文件恢复但移除原source、安装another-source：原tab/id/sourceKey/ep-2/page2保持，实际ReaderWithLoading不可用反馈comic not found，原请求数不增，another-source详情/章节0请求，60收藏保持。当前scope修复不允许向其他源改写身份。旧两卡/420/同State/controller/原FocusNode及后台自动阅读/准确一次退出断言全保留。测试中的flutter_memory_info MissingPlugin为可选缓存定容日志，非框架异常；未称真实插件计数已验。

当前32生产/19测试进行中SHA已刷新；上轮50分析/272保护早于仅loading.dart新改，当前待跑对应入口/恢复保护及analyze。仅3.4已勾，其余3.x未完成；下一多reader并存/直接关tab资源计数。B5真实shell全矩阵/未知route与replace/标签完整输入/新PID/GUI仍待。main仍旧构建，本批无GUI，无可执行已核/tmp工具，未提交。


## 多reader与直接关tab资源计数已绿，当前保护/analyze收尾中

/tmp/ux1-batch2-reader-tabs-loop.log **1通过0失败0skip，8秒**：两个不同实体真实Details→Read，真实PageDown建立A第2页/B第3页；分别通过已有工具启动自动阅读，仅当前运行，后台status=paused/Focus无归属/imageWork拒绝新请求。切回A同ReaderState及Gallery viewport State，B独立页码保持，准确章节请求总计2、每实体/ep-1一次。真实mouse hover使非当前B关闭按钮显现，坐标点击关闭B，A仍active/原焦点/第2页；B controller disposed、viewport卸载、自动阅读停止、拒绝新任务，onClosed总1。再真实CtrlW关闭A，进入No tabs open，A同样完全释放，onClosed总2，章节仍2，60收藏保持；takeException零异常。测试未调用关闭回调或设置页码建现场。此轮无额外生产修复。

32生产/20测试进行中manifest已刷新。当前/tmp/ux1-batch2-reader-disk-b5-protection.log运行中：按归档B5完整148项原命令集合（11文件）+reader_entry_loader/loading_history+两新阅读集成；不是只宣称renderer分支覆盖。reader-disk-analyze同时运行中，不能提前沿用上轮50。当前仍仅3.4已勾；3.6还需跨完整F1边界与新PID/GUI复核，不以两项局部绿勾全项。下一工作为未知辅助route/replace/eager builder边界真实红灯与标签完整输入矩阵；GUI尚无harness/helper可运行，需先全文SHA批准。


## 阅读本增量权威保护收尾

/tmp/ux1-batch2-reader-disk-b5-protection.log **159通过0失败0skip，12秒**：B5归档完整148项原11文件集合，加reader_entry_loader/loading_history与两项生产MainPage阅读集成。真实ReaderScaffold/thumbnail约束/PhotoView最终像素、浅深×左/右/底固定栏×单双面、chrome开关/折叠浮动/不同方向resize等均在原B5集合同断言；不是重新设计shell。新source Scope适配与磁盘身份/缺源、双reader直接关tab计数也在此次同跑。159与此前272有重叠，分列不累加。

/tmp/ux1-batch2-reader-disk-analyze.log **raw/unique50=38+12，added=[]removed=[]**，最新具体集合JSON已更新。当前32生产/20测试manifest均MATCH；没有临时probe。仅3.4已勾；3.1/3.2/3.3/3.5/3.6仍需剩余路由/完整输入/存储边界/新PID和GUI闭合，不以局部保护勾全项。下一先用真实导航builder调用计数/辅助页/replace测边界，契约未定义的辅助页跨重启策略须报告architect，不自行发明。工具/GUI/main状态同上，无提交。


## 导航builder准确一次已绿；辅助恢复边界授权来源待architect核实

/tmp/ux1-batch2-route-builder-red.log **0通过1失败**：真实收藏卡右键Details命中→详情请求1次，但生产comicPageBuilder执行2次，期望1。根因为observer提前调用route.builder(navigator.context)识别页面。最小沿既有workspaceWrapper在真实路由build得到child后登记，移除提前执行；先在didPush记原焦点并停用旧binding。route-builder-loop **1通过0失败0skip，3秒**，原AltLeft/正确实体/两卡420px/同实例/焦点均保留。

route-builder-protection **11通过1失败0skip，21秒**，唯一workspace_background首次激活详情后pumpAndSettle超时；旧helper没等待加载后第二段快照保存。仅补debounce后有界host.waitForSettingsSave，原后台3实体/零提前请求/准确首次请求/MRU/返回实例全部保留；/tmp/ux1-batch2-route-background-green.log **2通过0失败0skip，6秒**（原失败后台+builder）。其他11项未无差别重复。route-builder-analyze **raw/unique50=38+12，added=[]removed=[]**，具体集合JSON更新。

异步问答user回包逐字为「运行时保留；重启回父页并反馈」。该回包未包含答复者身份，executor不能确认owner身份；architect于恢复监听时表示尚未收到回复，要求依赖新增恢复边界的实现先确认授权并由architect落工件。因此此答复**待architect确认，尚非受保护工件变更授权**。生产没有restoreParent标记/辅助页恢复反馈实现。新workspace_auxiliary_route_test仅预写该期望，不计完成，不以测试预期替代契约；依赖新增边界的实现暂停，运行期栈/返回可独立继续。

/tmp/ux1-batch2-auxiliary-route-red.log **0通过1失败**且有多条框架异常：真实详情封面打开ComicCoverViewer，PhotoViewCoreState._onLoadEnd报LateInitializationError imageSize already initialized；之后runtime跨B再回A覆盖父页binding.active实际true期望false。前者来源尚未证，不冒称HEAD基线、不忽略异常、不改依赖。后者是运行栈活动归属缺口，独立于恢复策略可继续修。当前未写此runtime修复，replace边界仍未实现。

最新32生产/22测试SHA已刷新（含新增红灯测试），非最终冻结；analyze50早于仅新auxiliary测试追加，下一应重验。仅3.4已勾，其余均未闭合。原阅读磁盘身份/缺源1绿、多reader关tab1绿、B5整集合合跑159绿和前272分列不累加。main仍首批旧产物，无本批GUI/fixture，无可执行已核/tmp工具；不提交。


## 辅助页当前权威闭环：裁定已由architect落盘，Hero阻塞已9绿（增量保护/analyze待跑）

此前“授权来源待核实”段已被本段取代，保留历史。异步user回包逐字为「运行时保留；重启回父页并反馈」。architect随后明确确认此回包并亲自更新本change的proposal.md、design.md D9、specs/workspace/tabs/spec.md、tasks.md 3.2/3.5备注，且报告OpenSpec validate通过；executor已重读四处。此四工件为planner授权protected例外（design另含此前D5平台映射澄清），不是executor自行改约，不能将全部protected称零diff；本时点四工件SHA见batch-2-planner-contracts.sha256。

实现仅将ComicCoverViewer显式列为可恢复父页辅助类型，不泛化至主要页面或损坏数据。运行栈记录全部真实route，覆盖时父页binding inactive，跨标签保留同辅助页与真实返回关系；版本1 tab记录添加可选bool restoreParent（缺省false、坏类型拒绝）。磁盘仅存既有可恢复父栈及标记；重启恢复该父页并一次翻译反馈，保留其他标签/栈；消费标记后可靠写盘。没有序列化Widget/ImageProvider。运行期replace仍待实现与真实验证，其他未知route边界未闭合。

真实辅助页红灯 /tmp/ux1-batch2-auxiliary-route-red.log 0通过1失败：生产详情封面Hero进入ComicCoverViewer，PhotoViewCoreState._onLoadEnd的late final imageSize重复赋值，另有跨tab父页错误active。HEAD隔离对照 /tmp/ux1-batch2-cover-head-control.log 0通过1失败：只读提取HEAD AppPageRoute，并核cover/provider/PhotoView相关文件逐字HEAD一致，无Workspace也在匹配Hero下复现同异常；因此这是旧同步缺陷被授权辅助页必经路径触发，不是推测HEAD失败。

/tmp/ux1-batch2-cover-hero-isolation-probe.log 3绿1红对照：无Hero真实route与两种直接挂载均绿，仅匹配Hero失败。最初假设是同image State异步once标记太迟；仅前移image.dart标记后 auxiliary-hero-loop仍失败，已排除并完全撤回，image.dart恢复HEAD无diff。状态探针 /tmp/ux1-batch2-cover-state-probe.log记录三个不同image子State向同一个Core State重报100×150；因此初始化once归属必须在持有late final尺寸的Core。最终最小修复路径为packages/photo_view/lib/src/core/photo_view_core.dart：仅在_onLoadEnd入口增加Core实例级首次初始化guard，重复子图回调不再重赋值。保留原尺寸/scale计算、Hero tag与路由，不改pubspec/lock、不用pub-cache补丁冒充交付。临时生产debugPrint/probe已清除，永久回归保留真实Hero两对照与尺寸、居中、真实关闭返回、takeException零异常。

/tmp/ux1-batch2-auxiliary-core-loop.log 3通过2失败：辅助恢复及直接挂载已绿，两Hero测试在比例/居中/Hero断言通过后，仅误找BackButton（产品为Icons.close IconButton）；修真实控件定位，保留前述断言。最新 /tmp/ux1-batch2-auxiliary-green.log **9通过0失败0skip，7秒**：4个封面挂载/真实路由对照、1个真实辅助页现场+两次磁盘恢复、4个record验证。辅助测试保留收藏两卡/420px/同State/controller/原FocusNode、正确实体与AltLeft；验证覆盖父页inactive、跨tab同辅助页、返回原父/收藏；真实implicitData.json重载回正确父页一次反馈，再落盘重启反馈不复发。仍为同进程磁盘重载，非新PID。record测试增加坏restoreParent类型且保留原坏数据断言。

最新进行中manifest：33生产（含vendored PhotoView Core）/23测试，已全部按当前源码重算；不是整批最终冻结。当前最新50分析仍早于本辅助增量，不能冒称当前analyze已绿。下一有界命令为此增量导航/现场/休眠回归及归档B5完整148测试集合，再当前analyze具体集合对照。仅3.4已勾；3.1/3.2/3.3/3.5/3.6及1.3/1.4仍未完成：replace、未知route边界、完整标签输入/溢出/全局Tab焦点矩阵、新PID恢复、GUI与最终正常main构建/清理均待。builder准确一次局部已绿但完整路由矩阵未完成。无本批GUI/fixture启动，/tmp核准工具当前不存在，正常main仍第一批旧产物；本轮不启动来不及收尾的GUI，不提交。


## 本轮停止点／最新权威handoff：辅助增量保护与分析已闭环，F1未完成

本段取代上一段“增量保护/analyze待跑”，保留全部历史证据。HEAD仍6f1f1bc01ce69be91e62b9474a0b95f83a752d73；保留授权脏改，没有提交/归档/push。本轮仅完成辅助route生命周期、一次恢复反馈和阻塞Hero的最小修复，不等同3.x整项完成。

当前结果分别记录，不累加重叠测试：
- /tmp/ux1-batch2-auxiliary-green.log：9通过0失败0skip，7秒（封面4、真实辅助运行/磁盘1、record4）。
- /tmp/ux1-batch2-auxiliary-navigation-protection.log：15通过0失败0skip，23秒。真实历史/后台/焦点/关闭/保存故障、搜索/单源结果/聚合/详情现场、阅读磁盘与多reader休眠/关闭、builder一次和辅助route均通过，原两卡420px/正确实体/同实例/原焦点/AltLeft断言保留。
- /tmp/ux1-batch2-auxiliary-b5-protection.log：152通过0失败0skip，5秒。归档B5原完整148项11文件+生产封面4项；保留真实ReaderScaffold像素/viewport/主题及B3绑定继承/F9排序保护。
- /tmp/ux1-batch2-auxiliary-analyze.log：原始51，唯一新增packages/photo_view/lib/src/core/photo_view_core.dart:585:32 always_put_control_body_on_new_line。导航测试结束后仅为guard补花括号，无逻辑更改。
- /tmp/ux1-batch2-auxiliary-analyze-fixed.log：raw/unique均50=38 tool+12其他，逐条added=[]、removed=[]；batch-2-progress-analyze-comparison.json的current_log已更新至此日志，而非旧route-builder日志。现有folder_order_ownership等基线保留。

最终进行中SHA：batch-2-progress-production.sha256 33项，manifest SHA 6ee7a88996ea92acf8df470ef61c90e1d56d2c9ea086c4be1f116349880afc72；batch-2-progress-tests.sha256 23项，manifest SHA faab95f11ca6cf2137d721a5f4f81a66c42fc52fb391dda9fceebb5c6a3c1612。Core当前SHA d805180804f310c9a2b75c3d4d8bc0a517ee63042bb93466239bc4f607c04e61；image.dart与HEAD一致零diff。本轮结束重新核对manifest全部MATCH。四planner工件例外及旧D5详见前段与batch-2-planner-contracts.sha256；固定protected范围AGENTS/ROADMAP/BACKLOG/design-spec/正式spec/归档/pubspec/lock零diff，git diff --check通过。没有把planner授权改约伪称零diff。

清理：生产临时debugPrint/probe已移除；仅删除本轮自建/tmp/ux1_cover_probe_test.dart（SHA568c5ad8f11c45ccbe2fd4acbf01ef799f4ff874dfe25c561a007b4d11879888）、/tmp/ux1_head_cover_probe_test.dart（93029624d277d52c89390c06880b2872c04cae2ee274246318ff8800ee2556f1）、/tmp/ux1_head_app_page_route.dart（655a0fd66f4c2642a7db85dce4b98381794181446b54eb532e41cc96f96eef47）。对应HEAD红灯/3绿1红/Hero身份probe日志均保留；永久test/features/comic_details/cover_viewer_route_test.dart保留实际控件、零异常、尺寸/居中/Hero语义及返回保护。本轮两次保护与analyze进程均已正常退出，无需kill。

逐项未完成（仍仅3.4勾选，不批量补勾）：
- 3.1：各主要页面局部现场已有真实跨tab/磁盘绿，但完整标签身份与全场景矩阵、真实新PID恢复未闭合。
- 3.2：真实AltLeft/当前与后台打开/builder准确一次/封面辅助运行和返回已绿；replace与其他未知route完整边界仍缺真实红绿，不将局部builder绿等同整项。
- 3.3：横向滚动、全部N完整标题/当前/待激活、关闭hover/focus及全部输入/溢出矩阵未完整；特别reader内层FocusScope的全局Tab出栈问题尚待真实验证/必要修复，不沿用旧局部焦点绿宣称全局通过。
- 3.4：此前真实设置left/right、MRU、后台不抢焦点与空态已勾；本轮关闭相关保护仍通过。
- 3.5：主要页与辅助页同进程真实磁盘重载/保存失败/坏记录/目录ownership已有局部绿；真实新PID、最终目录生命周期/损坏边界全集及GUI仍未闭合。
- 3.6：后台详情首次请求、阅读自动阅读/输入/新工作休眠、多reader切换与直接关闭资源已有强计数绿；仍须与完整F1矩阵/真实新PID及GUI总闭环，不提前勾选。
- 1.3/1.4继续部分完成；不以局部快照绿覆盖其他阶段预览/主体语义/进度等未建立完整红绿的要求。

下一有界循环应先为runtime Navigator.replace构造真实生产栈/准确一次builder/父页active/返回现场红灯，再最小修复，保留原AltLeft/实体/两卡420px/实例/焦点。可先复用test/app_shell/workspace_route_lifecycle_test.dart，不直接开启大GUI；执行命令：env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_route_lifecycle_test.dart --reporter expanded，新增日志另名/tmp/ux1-batch2-route-replace-red.log，不能将现有仅builder测试的绿冒称replace覆盖。

GUI/main状态：本批尚未构建启动fixture；原核准/tmp/ux1_gui.dart与/tmp/ux1_x11.py当前不存在，新工具须重新全文SHA核准；没有大GUI证据。正常main仍第一批旧kernel，SHA37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8；不是当前F1源码构建，最终main正常构建/新PID/隔离GUI与自身fixture清理仍待。main/runner未为fixture修改。本轮至此停止，不接F2，不提交。


## owner继续后进行中：replace与Reader全局Tab真实红绿，标签溢出验证中

owner要求继续直至书架/F1可独立验收，撤销此前停止点，保持同change/HEAD及脏改，不提交。本轮重新沿用diagnosing-bugs单变量反馈和既定A交互检查，不另起视觉系统。

/tmp/ux1-batch2-route-replace-red.log 1通过1失败：原真实详情builder一次/AltLeft收藏现场对照绿，真实fixture按钮驱动生产Navigator.pushReplacement替换成另一ComicPage后，旧binding.active仍true。不是初始化异常，原observer缺didReplace。仅修改lib/app_shell/workspace/desktop_workspace.dart：共享实际route build登记路径，替换保留liveRoutes位置，删除旧可恢复记录并停用旧binding，新记录按真实位置插入；不提前执行builder。route-replace-loop 3通过0失败0skip（原对照+replacement+辅助）。保留正确新实体、准确一次replacement builder、两层可恢复栈、旧route身份移除、AltLeft回原两卡/420/同State/controller/原焦点和零异常断言。下层非可见route replace仍需独立覆盖，不以此局部绿泛称完整replace矩阵。

/tmp/ux1-batch2-reader-tab-traversal-red.log 0通过1失败：实际Reader画布出发逐次Tab在FocusNode循环，尚未触及外层WorkspaceTabStrip。基于真实已挂载Focus图限一次遍历且禁止重复节点，没有无限Tab或增加等待。lib/features/reader/exit_guard.dart最小仅didChangeDependencies依据WorkspacePageScope，将正常_contentFocus边界设parentScope；非Workspace reader仍closedLoop，保存_waitingFocus和等待遮罩锁键完全保留。reader-tab-traversal-loop 1通过0失败0skip，8秒，正Tab达外层、ShiftTab回同Reader画布，页码1/一次请求保持，随后原两reader/page2/page3、后台暂停/新工作拒绝、精确关闭资源与收藏现场强断言全部通过。已扩展生产文件entry-baseline。

/tmp/ux1-batch2-replace-focus-protection.log 29通过0失败0skip，15秒（exit_guard、favorites全局焦点、Reader跨Scope、多route、辅助与record保护）。/tmp/ux1-batch2-replace-focus-analyze.log当前51，新增仅test/app_shell/workspace_route_lifecycle_test.dart多余non-null assertion，已删除，尚待最终分析复验；不以旧50冒称当前通过。

新增workspace_tab_input_test.dart保留原真实收藏两卡/420/同实例/正确实体与后台零请求，通过右键后台菜单建立3个长标题标签；测试宽1400/1000/600真实横向PointerScroll、全部N完整标题/待激活图标和键盘选中正确实体/首次一次请求，再回原收藏现场。tab-input-red在横向滚动已过后误把侧栏chevron计入标签箭头，已只将该定位限定WorkspaceTabStrip，未改生产；tab-input-loop进行中，需读取最终结果，不能先记绿。

当前34生产/24测试进行中manifest已刷新；最新JSON仍auxiliary-analyze-fixed的50（早于本轮），有意未伪更新。仅3.4已勾，其他3.x及1.3/1.4未完整；reader全局Tab观察已被真实红绿闭合，但完整标签focus/overflow、下层replace/未知route、最终目录生命周期/新PID/GUI/正常main当前构建仍待。无本轮GUI/fixture/工具启动；main仍首批kernel，不提交，不因低额度提示提前停工。


## 3.3已闭合；目录/新PID与GUI准备中的最新权威进度

真实宿主与排除结论短记：600×900、150%时，实际内容Column592×784；标签66、恢复反馈Row504，导致详情loading子树仅592×214，Column(comic_page.dart:977)溢出200。/tmp/ux1-batch2-loading-head-constraints.log 1通过1失败：只读HEAD提取的占位类与当前逐字一致（类体SHA8903317e60b776998d2a1ce7190ad451705c5503bfd45660c83bd0ecb495026a），同592×214也溢出200，592×800通过。不是HEAD完整应用启动对照，也不是新标签66px单独造成；实际新增工作区恢复反馈缺Material文字继承，使用fallback大字占高。单变量仅DesktopWorkspace内容补主题shellSurface Material，tab-input-material-loop 2绿，详情文件未改、不进入5.x。诊断host/parent probe日志仅定位证据，不重复计产品红灯；临时error handler/RenderBox探针已从测试删除。原600宽150%零异常与新内容视口>=窗口60%断言保留。

被覆盖route replace-loop初2绿1红：数据/延迟请求/返回正确，但新路由build时反复停用再激活可见页触发build-phase通知；只限制顶层传入route才停用binding，route-covered-replace-green 3通过0失败0skip，10秒。覆盖replacement保持原栈位置、原覆盖页活动、下层首次零请求、AltLeft后才请求一次并返回原两卡420/同实例/焦点。当前/被覆盖replace与builder局部矩阵已成立，仍需本地阅读自动redirect等入口最终核验，不提前勾3.2。

/tmp/ux1-batch2-input-shell-protection.log **100通过4失败0skip，33秒**：两项原desktop_chrome纯controller无SchedulerBinding失败（本轮阅读时序新增框架依赖，非HEAD基线）；另两项新hover计数错误（收藏卡+标签+Tooltip共3文本误期望2）。生产改为Controller默认同步通知，UI Scope显式提供帧调度：reader callback立即撤销，build期通知post-frame，_disposed禁止延迟通知。原desktop_chrome_test完整保留，未加binding初始化。/tmp/ux1-batch2-controller-notify-green.log **4通过0失败0skip**：原纯controller3项+新增构建期即时撤销/严格post-frame通知/disposed不通知精确回归。controller-input-loop 5通过2失败，仍是先前文本总数定位（首次脚本替换未命中，已明确纠正），不伪称该次全绿；现在精准定位Tooltip完整富文本，tab-input-tooltip-loop **2绿0失败0skip，10秒**，原hover动作/完整名称/稳定尺寸保留。

最后非当前标签键盘关闭场景：close-focus初pumpAndSettle超时，改用既有settleWorkspace等待真实快照IO后动作已成功；close-io-loop因Tab真实遍历收藏卡自然scrollIntoView，关闭后offset3377.7059/3959.7059误期望仍420。保留原跨tab返回420断言，关闭前另冻结实际offset，验证关闭不改变此现场；不重设offset/选择、不增加无界Tab。/tmp/ux1-batch2-tab-input-close-scene-loop.log **2通过0失败0skip，36秒**（浅100/深150、每项1400/1000/600、完整长名hover/列表、键盘选对实体/请求一次、Tab焦点显现非当前关闭/Enter关闭正确目标/不抢当前页及选集/实际滚动）。3.3即时勾选并备注；3.4此前已勾，3.1/3.2/3.5/3.6与1.3/1.4仍未完成。不是F1完成。

最新分析/tmp/ux1-batch2-controller-input-analyze.log raw/unique50=38+12、added=[]removed=[]，JSON current_log已更新；该次早于新增desktop_reader_notification测试及最后键盘关闭断言，最终测试扩展后还须分析复验。进行中SHA清单34生产/25测试已刷新，tasks3.3更新后的四工件SHA清单已重算；proposal/design/delta本轮executor未改，planner例外仍按前段列明。

GUI工具现已准备并由architect全文核准：/tmp/ux1_f1_gui.dart SHAd0f1dfaa6be51859474d6e8caf60815b1cd2f541c479f15e55c0ea4af1004f12（原稿5b8a66仅一行翻译类名纠正）；/tmp/ux1_f1_x11.py SHA54051aadb6003e2e5e64e7b31e51421c317df607214a0898a04727e088f151bf。helper尚未运行。harness构建命令env代理+RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub --target /tmp/ux1_f1_gui.dart，日志/tmp/ux1-f1-gui-build.log进行中；不是正常main产物，下一启动须先读构建结果，DISPLAY=:1 GDK_BACKEND=x11、独立XDG与UX1_FIXTURE=ux1-f1-20261109、--ux1-f1-fixture，1000×700有界窗口。F6仅记录完整Flutter帧/实际实体选集/滚动/焦点/快照与请求计数，X11宿主图单列；不得把F6当业务动作。F12仅卸载自身与保存清理。harness使用受控ColorScheme.fromSeed主题，非动态色真实主题证明；不直接写GUI选择或offset。真实重启必须新PID/同隔离业务目录，尚无本批GUI/新PID证据。

下一推进：目录ownership补实际MainPage卸载/新目录重挂载场景；本地ComicPage自动阅读redirect仍调用replaceWithRootPage根Navigator，需先真实控件红灯检查是否逃离工作区，再依D5最小适配；未知辅助类型不得自行泛化parent恢复。原阅读后台/缺源/磁盘/多reader计数保护仍在。正常main当前最终构建/自身fixture清理必须待GUI完成后恢复；不提交、不归档、不push，不开F2。


## GUI取证候选冻结（构建已结束，可独立复核；仍非F1最终验收）

新增目录真实MainPage A→B→A生命周期 /tmp/ux1-batch2-directory-lifecycle-loop.log **1通过0失败0skip，1秒**：A两标签真实磁盘快照→第三标签待保存时卸载→B独立实体/标签及磁盘→旧A assignment零写入B→回A创建新owner后旧assignment仍不能覆盖A；实体与两目录快照均保持，非模型重建替代UI生命周期。

本地ComicPage自动redirect真实红灯 /tmp/ux1-batch2-local-reader-owned-route-red.log **0通过1失败**：生产收藏卡右键Details进入已在LocalManager真实存储的本地漫画，Reader被replaceWithRootPage推向root，WorkspaceTabStrip消失。初local-reader-route-red仅因helper默认查可见host出现No element，不当作另一产品红灯；允许helper读仍挂载offstage host后才得到准确可见性失败。最小comic_page.dart仅当WorkspacePageScope存在，保留同Reader构造/历史/onClosed，改当前Navigator.pushReplacement；普通路径仍replaceWithRootPage。local-reader-route-loop **4通过1失败**，路由/焦点已过，PageDown后fixture未固定Reader模式导致等待超时；沿现有reader fixture固定画廊/关闭动画及预加载，未删PageDown2。/tmp/ux1-batch2-local-reader-gallery-loop.log **4通过0失败0skip，4秒**（本地场景+普通root替换3项）：Reader当前栈、正确local实体、焦点/第2页、AltLeft原两卡420/同实例/原焦点均通过。编译与fixture等待不充当独立产品缺陷计数。

当前冻结：batch-2-progress-production.sha256 34生产，manifestSHA 81858d37e9392a3d5d0212d23817dec66bb8de4ebe82cc34f208c56ebf2f6276；batch-2-progress-tests.sha256 27测试，manifestSHA c3a77396b14a76d5a0413bebbcb07abc172d856be38241d86fd9b96e941b0b50（下文脚本以实际值替换）。/tmp/ux1-batch2-f1-candidate-analyze.log当前raw/unique50=38+12，具体added=[]removed=[]，JSON current_log已更新。相关回归完整可运行命令在batch-2-candidate-regression-command.txt，对应/tmp/ux1-batch2-f1-candidate-protection.log正在执行；尚未读取最终计数，不提前报绿。原100通过4失败与后续闭环均保留于前段，不重复累加。

GUI候选已用当前生产源码重构建：/tmp/ux1-f1-gui-final-source-build.log成功，kernel SHA4dd480178c8781dee035ff39803f08e372fb77c2bb8aca7fbb37ff667e4cc72b；harness528dbe.../helper54051a...均已全文获准，启动前再次MATCH。先前kernel3e2c...早于本地阅读适配，仅阶段产物；当前候选冻结后如GUI需源码变动，必须立即声明失效并重验/重构建。正常main尚未恢复，不能冒称当前main构建已验。GUI尚未启动，下一使用固定隔离XDG与业务目录、1000×700窗口（完整Flutter帧与X11宿主图分列）开展真实输入/新PID恢复。构建已结束，architect可独立复核；无提交授权。


## 标题增量权威handoff（额度提示后持续工作；旧冻结已失效）

architect发现多个阅读标签都显示Reader，违反D5全部N完整名称。/tmp/ux1-batch2-reader-titles-red.log **0通过1失败，8秒**：真实两部不同Reader第2/3页、请求及焦点均已成立，点击生产全部N列表，完整reader.widget.name找不到。原34/27冻结（81858d.../c3a773...）、独立206与相关256保护及其50分析均为标题前历史，不能替代本增量复验；已明确声明冻结失效，并将3.3恢复未勾。3.4仍已勾，其他3.x及1.3/1.4未勾。

仅三生产文件变更：workspace_pages.dart描述直接Reader时保存page.name为title；reader_page.dart在ReaderWithLoading既有元数据加载后复用widget.name更新同route arguments并走原快照保存，不另发详情请求；workspace_tab_strip.dart对尚未知名的旧reader记录使用既有实体id作暂时识别，已有实际title仍优先。没有新增读取接口/网络请求、没有改业务身份或主要页恢复边界。/tmp/ux1-batch2-reader-titles-loop.log **3通过0失败0skip，10秒**：真实全部N两部完整名称不同且详情请求仍准确两次，原双reader后台/页码/关闭资源、本地返回和阅读磁盘/缺源保护保留。

当前追加更强真实磁盘验证：workspace_reader_state_test保留原beforeRestart完整文件等式，再只从真实implicitData.json的reader arguments删除title模拟旧v1记录，清内存doInit后以既有一次Reader加载补回实际名称并可靠落盘；缺源时保留已知title且不向其他source请求。/tmp/ux1-batch2-reader-titles-disk-loop.log运行中，命令为env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_tabs_test.dart test/app_shell/workspace_reader_state_test.dart test/app_shell/workspace_local_reader_route_test.dart test/features/reader/loading_history_test.dart --reporter expanded。必须读取最终结果，不提前称绿。当前标题生产源码尚未analyze，上一candidate50不是本次结论；紧接运行/tmp/ux1-batch2-reader-titles-analyze.log具体集合对照。

当前34生产/27测试进行中manifest已按标题改动重算，非最终冻结；变化SHA如下：
- lib/app_shell/workspace/workspace_pages.dart: 0652b908ed99f78889d5e58ee5873d787db4ff54b03ae4e83b2bfed9a400e2b3
- lib/app_shell/workspace/workspace_tab_strip.dart: 67dc744775364f61bae5286594d2559cabb4d0a58d18c91034f9953d97648463
- lib/features/reader/reader_page.dart: 9db2675381770d93de9822491b2188bd960cb92ffa7461a3ceabb7c37ee83d0b
- test/app_shell/workspace_reader_tabs_test.dart: 3d725b9567d66a2f558999bca0c9221bc179b0a895c872f99883b8b135c3a195
- test/app_shell/workspace_reader_state_test.dart: 7d3e220a69b0622522d833c7064efa4854d7e756343cbf5a3684d7b7527758c8

GUI阶段证据：PID48226真实A(两卡book-4/book-5，offset163.581389，controller707174300，focus1014165734)→CtrlT新B（独立controller947209422，offset0、选集空）→CtrlTab回A，原grid396740543/scrollElement448037623/controller/选集/offset/精确FocusNode均一致。图和JSON为/tmp/ux1-f1-gui/pid-48226-frame-{2,3,4}.{png,json}；不冒称420px（420来自widget测试），不冒称图片解码。覆盖窗口1000×700在1080×760宿主内，host-initial.png与完整Flutter帧分列。旧PID经核身份F12，日志UX1_EXIT pid=48226，exec正常exit0；其GTK/引擎退出警告日志保留，无kill其他程序。

封面占位根因为/tmp harness漏接正常启动的tileImageProviderResolver，返回null，非生产解码回退。只在/tmp补CachedImageProvider导入与既有tile resolver；新harness /tmp/ux1_f1_gui.dart SHA913c2f24486603590970549737d145a7c6b4f094493ccdbf4d3029da50c2b396已由architect全文核准构建/隔离启动；helper /tmp/ux1_f1_x11.py SHA54051aadb6003e2e5e64e7b31e51421c317df607214a0898a04727e088f151bf未改、仍获准。此新版尚未构建/启动，现bundle kernel4dd480...不含标题增量，仅历史候选，必须新源码重构建后再取证。正常main亦未恢复；当前无活fixture。

下一准确次序：读titles-disk-loop最终结果→必要单变量修复→当前analyze逐条归50→恢复3.3勾选与刷新34/27及四工件manifest→env代理+RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub --target /tmp/ux1_f1_gui.dart（新日志/tmp/ux1-f1-gui-titles-build.log）→同固定/tmp业务目录、独立XDG、DISPLAY=:1 GDK_BACKEND=x11、UX1_FIXTURE=ux1-f1-20261109、--ux1-f1-fixture新PID启动，恢复A/B并核选集/滚动/焦点，真实详情/Reader图片与两部标题/休眠计数及新PID阅读恢复→最终正常main构建/fixture清理。其余未知route/完整阶段验收仍按契约；不提交/归档/push，不开F2。实际额度阻断时以本段续接，不以低提示自行结束任务。


## 2026-11-15 续点：标题增量保留，临时证据与额度阻断

从持久交接恢复后，仓库脏改仍保留，HEAD仍6f1f1bc，未提交。标题增量源码变化及上一轮3测试绿历史保留；此前标题增量将旧冻结明确作废，3.3尚未重新勾选。

当前可持久核对：batch-2-progress-production.sha256与batch-2-progress-tests.sha256已按工作区重算；测试清单仍27项，生产清单仍34项，SHA以文件内容为准。标题源码变化仍为workspace_pages.dart保存Reader.name、reader_page.dart复用ReaderWithLoading已获取的name写入当前route参数、workspace_tab_strip.dart对旧Reader记录使用id作为临时可识别标题。该实现未新增详情请求。

尚未闭合且不得冒称：标题磁盘回归最终读数、标题增量analyze50具体集合、标题后manifest独立复核、harness 913c2f新构建、新PID GUI图片/Reader页码/标题证据、正常main构建与fixture清理。此前3标题测试绿不替代磁盘迁移和analyze。/tmp标题磁盘日志、/tmp/ux1-batch2-reader-titles-analyze.log、/tmp/ux1_f1_gui.dart、/tmp/ux1_f1_x11.py及旧GUI截图已不在当前/tmp，不能引用为本次可重放工件。

额度状态：尝试运行当前analyze时，工具自动审批返回“usage limit… action was not executed”，因此没有静默重试，也没有把旧50集合冒称当前。下一准确命令（额度恢复后）仍为：
`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_tabs_test.dart test/app_shell/workspace_reader_state_test.dart test/app_shell/workspace_local_reader_route_test.dart test/features/reader/loading_history_test.dart --reporter expanded > /tmp/ux1-batch2-reader-titles-disk-loop.log 2>&1`；随后`fvm flutter analyze --no-pub`写`/tmp/ux1-batch2-reader-titles-analyze.log`并逐条比较50基线。需重新提供并核准harness/helper全文及SHA，再以当前标题源码重构建、隔离新PID GUI；不得沿用旧kernel或旧临时SHA。

本续点不提交、不归档、不push，不改契约，不跨F2。


## 2026-11-15 标题增量已闭合，GUI工具需重新准备

标题磁盘/阅读回归最终结果：`/tmp/ux1-batch2-reader-titles-disk-loop.log` **4通过0失败0skip，10秒**，包含双Reader完整标题/全部N、Reader状态与旧v1无title快照迁移、缺源保留身份/标题、本地Reader路由及既有loading_history。标题请求计数保持既有准确次数，无额外详情请求；Reader后台页码、焦点、关闭资源和本地AltLeft现场断言保留。

标题当前analyze：`/tmp/ux1-batch2-reader-titles-analyze.log` raw/unique=50，38 tool+12其他，具体`added=[] removed=[]`；JSON current_log已更新到该日志。34生产/27测试manifest已按当前源码重算，SHA见对应manifest文件。3.3已即时勾选，标题完整名称缺口闭合；3.1/3.2/3.5/3.6及1.3/1.4仍未全部完成。

旧冻结已失效并由本段替换：标题增量涉及workspace_pages.dart、reader_page.dart、workspace_tab_strip.dart及reader标题迁移测试；GUI旧PID/旧harness已清理，不能复用旧kernel或临时SHA。当前必须重新准备全文harness/helper并经architect读核后构建。

下一命令为：重新读核当前harness/helper全文SHA→`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub --target /tmp/ux1_f1_gui.dart`→DISPLAY=:1/GDK_BACKEND=x11隔离XDG新PID启动→真实A/B标题、页码、滚动、焦点、请求计数及新PID恢复→正常main构建与自身fixture清理。


## 2026-11-15 标题闭合后工具重建待核

标题磁盘回归最终：`/tmp/ux1-batch2-reader-titles-disk-loop.log` 4通过0失败0skip；标题analyze最终：`/tmp/ux1-batch2-reader-titles-analyze.log` raw/unique50=38+12，具体集合added=[] removed=[]。tasks 3.3已勾，标题完整名称与旧v1迁移断言已纳入备注。

当前manifest重算后仍34生产/27测试；生产文件manifest SHA与测试文件manifest SHA以batch-2-progress-production.sha256和batch-2-progress-tests.sha256为准。未提交。

旧/tmp工具已被环境清理，当前新工具仅重新生成、尚未获核/构建/启动：harness f2a1b63d36b0faf0af972933dbb302322c502102ec1eaff9a8d2894c95c220cc，helper 2b62fa1c1b796e1a00eddd79f6cfa9e559919ff4d89556305035a7bc3dda9ac1。harness调用生产main并设置fixture marker、固定title、窗口尺寸；不含历史受控Favorites注入/F6业务JSON，因此其后GUI证据能力受限，未冒称完整F1现场。待architect核读后再构建；若要求完整业务harness，需另行重写并重新核SHA。


## 2026-11-15 GUI工具重建（待architect读核，禁止构建）

旧简化wrapper/helper因不满足真实输入、resize和清理边界已作废。重新生成当前临时工具：harness `/tmp/ux1_f1_gui.dart` SHA7318bae0124ddd638da83cf178b7780a526a07217ded30954433b9f2a51b193a；helper `/tmp/ux1_f1_x11.py` SHAd8893fe8f264726119558b328506e7170528775506f731015f408950dc09405c。

新harness只在/tmp使用business/cache、由UX1_FIXTURE marker和`--ux1-f1-fixture`保护，建立受控source/favorites并挂载生产MainPage/WindowFrame；F6保存RepaintBoundary PNG与JSON（workspace/request计数），F12等待保存、卸载fixture manager、销毁自身窗口后退出。新helper每次完整核验exe、PID、固定title、env marker、命令参数、窗口/root及坐标边界；click/hover/wheel/key调用XTest真实输入，按键/鼠标try-finally释放；resize调用XResizeWindow并复核，capture再次identify且固定/tmp路径禁止覆盖。

当前仅完成源文件生成和SHA回传，未构建/启动；待architect全文核准后才能执行build和隔离GUI。`fvm dart format`尝试受本机只读engine缓存报错，未冒称格式化通过；未改生产文件。
## 2026-11-16 UX1 tasks 1.3/1.4 scoped re-entry (executor)

本轮只核 1.3/1.4；不扩 F2/3.x，不提交、归档或 push。当前 HEAD 仍为 `6f1f1bc01ce69be91e62b9474a0b95f83a752d73`，保留既有第一/第二批脏改。tasks.md 当前 SHA `d76a7513c0dc3390e0718272c456d51a763e61daa0a062ca92a86e8401c1a65f`。

1.3 现状：生产 `ComicTile` 的真实入口是主体打开、Details、后台打开菜单；未发现 Space 临时预览入口。已有 `workspace_search_results_test.dart`/`workspace_tabs_test.dart` 真实控件绿灯覆盖多栈、来源/关键词筛选、滚动、焦点和返回，但不覆盖所有列表统一主体点击，也不证明 D8 单进度，因此 1.3 不能勾。尚未新增生产代码或测试代码；不能把后续 F2/F5/F6 的实现当作本项红灯。尝试以真实 Flutter 控件集合建立可重放红灯时，命令：

`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_record_test.dart test/app_shell/workspace_recovery_test.dart test/app_shell/workspace_save_failure_test.dart test/app_shell/workspace_directory_lifecycle_test.dart --reporter expanded > /tmp/ux1-13-14-storage-protection.log 2>&1`

该命令在 Flutter 初始化阶段失败，未进入测试：`/home/_Le/fvm/versions/3.47.7/bin/internal/update_engine_version.sh` 无法写只读的 `bin/cache/engine.stamp.tmp.*`/`engine.realm`。这是测试初始化/环境红灯，不是产品行为红灯；日志为 `/tmp/ux1-13-14-storage-protection.log`，通过/失败/skip 均为 **0/0/0（未启动测试）**。未绕过 fvm，也未修改 SDK/cache。

1.4 现状：已核对生产实现边界：`WorkspaceRecord.version == 1`；tab/route/entity identity 与 directory 校验在 `lib/app_shell/workspace/workspace_record.dart`；`WorkspaceStore.assignment` 通过现有 Appdata 写入并阻止过期目录 owner；Retry/失败反馈沿用 `lib/components/settings_save_state.dart`。既有真实磁盘测试覆盖版本/身份校验、损坏回退、`.tmp` 写入阻断、Retry、最新 assignment、目录归属/旧 callback 与 A→B→A 生命周期，但新 PID 重启以及全部损坏/旧回调/新意图组合仍未形成可重放闭环；因此 1.4 仍不勾。上述集合本轮因同一 Flutter 初始化阻断未重跑，旧绿灯仅作历史证据，不能冒称本轮结果。

本轮新增/修改文件：仅 `tasks.md` 与本 delivery 记录；无生产代码、无测试代码、无 GUI 工具。`git diff --check` 通过。下一准确单变量命令仍为修复/解除 Flutter SDK 只读初始化后，先重跑上述四个 1.4 真实磁盘测试并记录 raw 计数，再建立 1.3 的真实 Space/主体点击/单进度红灯探针；在环境阻断解除前不勾 1.3/1.4。

## 2026-11-16 1.4 权限升级后闭合

architect 核对 SDK 目录可写后，按原命令申请合理升级权限重跑；未改项目或 SDK。命令仍为：

`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_record_test.dart test/app_shell/workspace_recovery_test.dart test/app_shell/workspace_save_failure_test.dart test/app_shell/workspace_directory_lifecycle_test.dart --reporter expanded > /tmp/ux1-13-14-storage-protection.log 2>&1`

结果：**10通过、0失败、0skip，约5秒**。测试实际进入 Flutter；日志中的 `FileSystemException` 均来自主动将 `implicitData.json.tmp` 建为目录的真实故障注入，随后断言 Retry、最新 assignment、恢复及磁盘内容通过。覆盖版本/稳定 tab-route-entity 身份、malformed/duplicate/foreign-directory 拒绝、损坏 view/unknown route 一次反馈回退、目录 ownership、旧 callback 不覆盖新意图、写入失败/Retry 与 A→B→A 生命周期。该集合支持 1.4 勾选；新 PID 重启仍留在 3.5，不冒称本项证据。

本轮仍无生产/测试代码改动；tasks.md 已勾 1.4 并补上述命令与局限。1.3 仍未勾：预览入口、全列表统一主体点击及 D8 单进度尚无真实生产红灯闭环。`git diff --check` 仍通过。

## 2026-11-16 UX1 task 1.3 scoped evidence

本轮只处理 1.3，保持 HEAD `6f1f1bc01ce69be91e62b9474a0b95f83a752d73` 与既有脏工作区；未改生产/测试代码，不做 F2 实现、预览实现或单进度实现。

重读 D4/D6/D8 后，现有生产入口确认：`ComicTile` 有主体打开、Details、后台打开菜单，但没有 Space 临时预览入口。现有真实控件对照命令及结果：

- `/tmp/ux1-13-favorites-control.log`：`bookshelf_hit_target_test.dart` **4通过0失败0skip**；真实 hover、封面/标题坐标 tap、Details/直接阅读路由、右键菜单、多选与 Escape。
- `/tmp/ux1-13-multistack-control.log`：`workspace_tabs_test.dart` **1通过0失败0skip**；真实滚动、长按/主体 tap、New tab、标签切换、同页面/控制器/实体集合/焦点现场。
- `/tmp/ux1-13-reader-d8-control.log`：`slider_navigation_test.dart` **2通过0失败0skip**；真实拖动与 300 页进度跳转。
- `/tmp/ux1-13-reader-tap-control.log`：Reader 真实漫画区域 tap 后页面卸载保护 **1通过0失败0skip**。
- `/tmp/ux1-13-reader-space-progress-control.log`：Reader `Space`/页进度场景 **1通过0失败0skip**；这是阅读器键盘分页对照，不是卡片预览。

上述合计 **9通过0失败0skip**，仅为局部绿灯对照。搜索结果真实控件命令写入 `/tmp/ux1-13-search-control.log`，初始化后停在 `+0` 且无新输出；已确认无本任务测试残留并停止，不计失败或通过。此前合跑在 `+7` 后同样无最终计数，未重复无差别重跑。

因此本轮仍不能把 1.3 勾选：

1. 多栈已有收藏入口绿灯，但缺少搜索/聚合等实际生产列表的统一主体设置对照闭环。
2. Space 从卡片打开临时预览没有生产入口；未以回调或模型伪造红灯，也未实现 F2。
3. D8 现有 reader slider/键盘/tap 局部绿，但尚无完整“漫画任意单击切换工具、独立按钮/菜单/章节/文本不冒泡、底部唯一进度”生产场景红灯。

当前 analyze：`/tmp/ux1-13-analyze.log` **raw/unique 50/50**；与既有 50 基线逐条比较的 `/tmp/ux1-13-analyze-comparison.json` 为 `added=[] removed=[]`（38 tool/code-audit + 12 其他）。本轮无新增生产/测试代码，未发现新增集合。初始化异常、搜索测试无输出与既有 50 项均单列，未冒称产品红灯。tasks.md 已追加本段证据但 1.3 仍为 `[ ]`；`git diff --check` 通过。

## 2026-11-16 UX1 tasks 3.1/3.2 closure

本轮范围仅 3.1/3.2，HEAD 仍 `6f1f1bc01ce69be91e62b9474a0b95f83a752d73`，保留既有脏工作区；未改 proposal/design/spec/design-spec、生产/测试代码、main/runner，未提交/归档/push。

3.1 红→绿证据：`/tmp/ux1-13-multistack-control.log` **1通过0失败0skip**（两卡滚动、多选、标签切换、同 State/Controller/焦点）；`/tmp/ux1-batch2-stacks-scope.log` **4通过0失败0skip**（420px、实体集合、原焦点、独立栈）；`/tmp/ux1-batch2-details-protection-green.log` **14通过0失败0skip**（详情展开/滚动/Alt+Left 收藏现场）；`/tmp/ux1-batch2-auxiliary-navigation-protection.log` **15通过0失败0skip**（搜索/单源结果/聚合/详情、阅读磁盘与多 reader 现场）；`/tmp/ux1-batch2-reader-titles-disk-loop.log` **4通过0失败0skip**（Reader 标题/页码/缺源身份迁移）。这些均保留真实 tap/key/route/磁盘断言。

3.2 红→绿证据：`/tmp/ux1-batch2-route-replace-loop.log` **3通过0失败0skip**（Navigator.replace、准确一次 builder、旧 route 移除）；`/tmp/ux1-batch2-route-covered-replace-green.log` **3通过0失败0skip**（覆盖页 active、下层零请求、Alt+Left 返回原两卡/420px/同实例/焦点）；`/tmp/ux1-batch2-local-reader-gallery-loop.log` **4通过0失败0skip**（本地 Reader 当前 workspace Navigator 与返回）；`/tmp/ux1-batch2-auxiliary-green.log` **9通过0失败0skip** 与 `/tmp/ux1-batch2-auxiliary-navigation-protection.log` **15通过0失败0skip**（ComicCoverViewer 运行期真实路由、父页 inactive、跨标签返回）。红灯 `/tmp/ux1-batch2-route-replace-red.log`、`/tmp/ux1-batch2-auxiliary-route-red.log`、`/tmp/ux1-batch2-local-reader-owned-route-red.log` 均保留，随后最小修复并保留原实体/焦点/Alt+Left 断言。

本轮核心合跑 `/tmp/ux1-31-32-core-regression.log` 在 `+3` 后无新输出，已停止且无残留，**不计失败/通过**；独立 `workspace_tabs_test.dart` 仍为 1 通过。MissingPlugin `flutter_memory_info` 为测试环境提示，不计产品异常。3.5 新 PID/重启父页、3.6 后台资源计数、F2/5.x/6.x 均排除。tasks.md 已勾选 3.1/3.2；`git diff --check` 通过。

本轮核心合跑完整命令：

`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_tabs_test.dart test/app_shell/workspace_details_state_test.dart test/app_shell/workspace_route_lifecycle_test.dart test/app_shell/workspace_auxiliary_route_test.dart test/app_shell/workspace_local_reader_route_test.dart test/app_shell/workspace_reader_state_test.dart --reporter expanded > /tmp/ux1-31-32-core-regression.log 2>&1`

当前相关实现 SHA256：`desktop_workspace.dart 913a49ddb2fc429ba6794bb6d4e319066809831da3f36bab29608cc537ff21cc`；`workspace_pages.dart 0652b908ed99f78889d5e58ee5873d787db4ff54b03ae4e83b2bfed9a400e2b3`；`workspace_record.dart 6b7a8e55922d9e927f6ab7c6fe7781a3c7e3132d5ae3e2fcc954933230c1656a`；`workspace_store.dart 3cec1f7023aab2fc1d16f9e85458ef856cbbf7f60f6819d938a6c1ca2478d427`；`comic_page.dart 4aad33c82afa553ce37c4b7d310021bb26d2118b58c8aba89b61b94b0aa0b63e`；`exit_guard.dart 821468de4f83572f26fe7086988a9833b3370d387c0bcddc208490631a112a2e`；`reader_page.dart 9db2675381770d93de9822491b2188bd960cb92ffa7461a3ceabb7c37ee83d0b`。相关测试 SHA：`workspace_tabs_test.dart 4d97ba1d9e9212943ec4f514eb341bc303d697ce3fe2ff67ef5429c3ebf59dbf`、`workspace_route_lifecycle_test.dart bae3d96ce469b18719aa2dcea40b1d8965af1a533aef02e10f3de817581ab9d5`、`workspace_auxiliary_route_test.dart 7c40e2dab4dfe7636af928f7fb5fc5a06efcab26faad8fc8cc274aac12d8e843`、`workspace_local_reader_route_test.dart 878ff6e4b869baec4ddc7ac6efbe5ee748ed3e08754c190860b9bac51d33cd7a`。

## 2026-11-16 UX1 tasks 3.5/3.6 scoped closure

本轮只处理 3.5/3.6；HEAD 与既有脏工作区保持不变，未改契约、生产/测试代码、main/runner，未提交/归档/push。

3.6 已闭合：

- 命令：`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_background_test.dart --reporter expanded > /tmp/ux1-35-36-background.log 2>&1`
- `/tmp/ux1-35-36-background.log`：**1通过0失败0skip，6秒**。真实卡片右键菜单创建三后台详情，创建阶段零详情请求且不进入 MRU；首次激活各请求一次；复访不增请求并保持正确实体/页面。
- `/tmp/ux1-batch2-reader-exit-freeze-loop.log`：**1通过0失败0skip**；真实后台 Reader 自动阅读暂停、输入/新请求拒绝、章节/页码保持、同 State/viewport、关闭资源与一次通知。
- `/tmp/ux1-batch2-auxiliary-navigation-protection.log`：**15通过0失败0skip**；包含多 reader 切换、后台计数、关闭与请求边界，未以 TickerMode/回调替代现场。

3.5 尚未闭合，保持未勾：现有 `workspace_reader_state_test.dart`、`workspace_auxiliary_route_test.dart` 及 1.4 磁盘集合只做同进程 `doInit`/磁盘重载；不可序列化辅助页同进程回父页反馈绿灯不能替代 D9 要求的真实终止进程→新 PID restore/fresh。当前没有获准且存在于 `/tmp` 的 GUI harness/helper，故未伪造新 PID 证据，也未启动未经核准的 GUI。策略修改不清当前会话、版本/稳定身份/目录归属、损坏/Retry/旧回调局部绿均保留为 3.5 局部证据。

Reader state 单跑命令写入 `/tmp/ux1-35-36-reader-state.log`，在 `flutter_memory_info` MissingPlugin 后无最终计数，已停止且不计失败；该环境提示不影响上述独立后台计数。当前 analyze 命令：`fvm flutter analyze --no-pub`，日志 `/tmp/ux1-35-36-analyze.log` **raw/unique 50/50**；逐条比较 `/tmp/ux1-35-36-analyze-comparison.json` 为 `added=[] removed=[]`。相关实现 SHA 沿用本段前列 `desktop_workspace/workspace_pages/workspace_record/workspace_store`；新增测试文件未改。`git diff --check` 通过。下一准确缺口是先提供并全文核准隔离 harness/helper，再做真实新 PID restore/fresh；未授权前不运行 GUI。

## 2026-11-16 UX1 3.5 new-PID continuation

owner 已确认 DISPLAY/GDK/FVM/bundle/X11 preflight **pass=11 fail=0**。本轮重新检查 `/tmp` 后确认没有可复用且可全文核准的 UX1 harness/helper，因此没有绕过身份校验直接启动生产 GUI。

补跑 restore/fresh 设置对照：命令为 `env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_settings_test.dart --reporter expanded > /tmp/ux1-35-settings.log 2>&1`；结果 `/tmp/ux1-35-settings.log` **1通过0失败0skip，4秒**。真实设置控件修改 restore/fresh 策略后当前会话不清空，保存后重载策略保持；仍是同进程测试，不满足 D9 新 PID。

3.5 继续未勾：已有真实磁盘版本/稳定身份/目录归属、坏记录回退、写入失败/Retry、快速新意图覆盖、辅助页同进程回父页反馈均为局部绿；唯一未闭合是必须真实终止 PID A、以新 PID B restore、再以新 PID C fresh/辅助页边界验证。当前未生成或运行新工具，故无 GUI/新 PID 通过或失败计数，不把 preflight 通过冒称业务验收。

本轮源码未变，相关 SHA 沿用 `desktop_workspace.dart 913a49ddb2fc429ba6794bb6d4e319066809831da3f36bab29608cc537ff21cc`、`workspace_pages.dart 0652b908ed99f78889d5e58ee5873d787db4ff54b03ae4e83b2bfed9a400e2b3`、`workspace_record.dart 6b7a8e55922d9e927f6ab7c6fe7781a3c7e3132d5ae3e2fcc954933230c1656a`、`workspace_store.dart 3cec1f7023aab2fc1d16f9e85458ef856cbbf7f60f6819d938a6c1ca2478d427`。analyze 仍为 `/tmp/ux1-35-36-analyze.log` raw/unique `50/50`，comparison `added=[] removed=[]`；`git diff --check` 通过。下一步需先回传新 harness/helper 全文 SHA，获准后再构建并执行 PID A/B/C。

## 2026-11-16 3.5 实际跨进程 A/B/C（局部完成，仍未勾）

本轮核准工具为 harness SHA5c950f9ace9b9a8e80b2bdda24027d87c16c38c4723ec0ab92d3889412a7c02c；helper 原7b483…仅补缺少_NET_CLIENT_LIST_STACKING时xwininfo枚举，SHA9313798b6dd0bf9c1a16b70108780304c53bbc5ca28ff540eccf393dc1c07ba1，architect已全文核准。当前源码harness构建成功，日志/tmp/ux1-35-f1-build.log；bundle exe SHA82ce0018ad5d2cad0d0aa12ecc39d8c1798fddf826fd7aeb21b2bd6720c32d44。旧nohup PID111603已不存在；此前检查命令错误落默认:2已区分，不当环境阻塞或业务失败。

实际进程链：PID A240681→正常窗口关闭exit0→PID B243366→正常窗口关闭exit0→PID C245856→正常窗口关闭exit0。均显式DISPLAY=:1 GDK_BACKEND=x11 UX1_FIXTURE=ux1-f1-20261116 --ux1-f1-fixture，XDG_CONFIG/DATA/CACHE/STATE_HOME分别/tmp/ux1-f1-xdg-{config,data,cache,state}；exe完整路径为项目build/linux/x64/debug/bundle/venera-next。/proc已核A完整exe/env/args，helper每步核PID/title/env/args/root/geometry。

A真实鼠标New tab→Settings，磁盘/tmp/ux1-f1-xdg-data/com.github.lezy233.veneranext/implicitData.json含两标签及第二标签favorites→settings栈；/tmp/ux1-35-pid-a-before-exit.json保存原文件。B截图pid-b-restored.png可见同Favorites+Settings；只读比较workspaceSnapshot完整等式为True（tab/route ID、顺序、active、recent与返回栈）；/proc/240681不存在。B真实Settings→APP→Application startup→Open favorites，截图pid-b-fresh-session-retained.png仍两标签/当前Settings，appdata.json workspaceStartup=fresh；/tmp/ux1-35-pid-b-before-exit.json保存设置及快照。C新PID截图pid-c-fresh.png可见All1/Favorites，无Settings；/proc/243366不存在。fresh首帧尚未用户动作时旧磁盘快照保留，不将其误报为单标签已写盘。

截图全部在/tmp/ux1-f1-captures，按窗口ID截图，非Flutter完整帧；日志启动短暂有15px RenderFlex/DRI3/Atk/首帧GL警告，稳定截图无可见溢出，但不能称零异常。当前仅证明Favorites+Settings restore/fresh，不替代D9搜索/详情/Reader与辅助页跨进程现场。3.5仍未勾；下一需受控来源/真实cover与page的临时外围harness并补只读F6现场计数，源码工具变化先全文SHA核准。main/runner与生产源码未变；bundle目前fixture产物，最终正常main恢复仍待。

### 3.5 丰富现场临时工具待核（未构建/启动）

A/B/C基础现场之后，只修改/tmp外围工具，生产源码未动。新harness /tmp/ux1_f1_gui.dart SHAdbdf73e7b9e408d09a5cc1890c41f6cdf529624ac33e497d06b2eef51a0ab768：复用生产createCoreBootstrap/runtime.init/ApplicationHost/WindowPlacementHost/production.MyApp与正常WindowFrame关闭；在runApp前配置仅/tmp受控来源与真实cover/page PNG。fixture仅首次seed（seed-v1.done），不删数据库、不改workspaceSnapshot、workspaceStartup、选择或offset；重启复用实体。F6只遍历实际State/Reader章节页码/选集/scroll/focus/workspace与source请求计数，保存/tmp完整Flutter帧+JSON，不推动业务动作。

helper /tmp/ux1_f1_x11.py SHAdc285339853d294b4e3967778c88d36f0ad221549e2ee35ebb620d619477af31：在既有9313798…身份/几何/截图边界上，仅增F6、限1..128字符ASCII真实XTest输入、1..6 tick真实wheel。全文已输出待architect核准，不运行新工具、不构建。原A/B/C均exit0，无自有活fixture。3.5未勾；需以新harness真实搜索/详情/Reader与辅助页跨PID完成其余现场。

### rich 构建编译反馈与最小修正

architect已读核rich harness dbdf73e7…与helper dc285339…，要求helper键盘先设置并核输入焦点。仅增加完整ctypes XSetInputFocus/XGetInputFocus/XSync与key/type前精确窗口校验，新helper SHA7c38817b147b632f869b38effdbe0970dd0fb89ead9058baa4e003aae9ac19fd，全文已回传。依「补齐后允许构建」授权运行rich build，/tmp/ux1-35-rich-build.log编译失败：临时harness缺registerShowMessageHandler导入，不是产品红灯，未启动新PID。只补foundation/context.dart单行导入；harness新SHA105d00d2351c2cc5ab45896ece0fe4bec52a70cbcd537bc83a1cb59f8ecb0cfe，去掉该行即逐字匹配已读dbdf73e7b9e408d09a5cc1890c41f6cdf529624ac33e497d06b2eef51a0ab768。等待此单行版本核准后再构建；helper/生产未改，无活fixture，3.5仍未勾。

### rich 跨PID实际现场与首帧异常（仍未最终验收）

核准harness105d00d2351c2cc5ab45896ece0fe4bec52a70cbcd537bc83a1cb59f8ecb0cfe/helper7c38817b147b632f869b38effdbe0970dd0fb89ead9058baa4e003aae9ac19fd，rich-build-2成功。实际rich A255580→正常关闭exit0→B266168→正常关闭exit0→C269207→正常关闭exit0。始终相同隔离目录，fixture只首次seed，重启不删重建收藏、不覆盖snapshot/startup。A通过真实Select comics菜单+两卡主体选book-3/book-4，wheel形成159px、focus local-favorites-selection；真实新tab搜索Alpha+Other，results212px；右键后台建book-2/book-6（创建阶段0详情请求）；激活book-6真实Read、PageDown至ep-1第2页；book-2详情53px后实际点封面进入ComicCoverViewer，restoreParent=true。真实Settings改restore，5标签未清。

/tmp/ux1-35-rich-a-before-exit.json为实际磁盘快照；F6 JSON/完整Flutter帧rich-255580-{1..6}在/tmp/ux1-f1-captures。B首激活book-2，全部5tab ID/route ID/栈与view完整等式通过，仅restoreParent消费；只有book-2详情1请求，search/chapter0，屏幕一次Temporary pages反馈。/tmp/ux1-35-rich-b-initial-assertions.json保存只读检查。B激活收藏，实际State恢复book-3/book-4选集、159px、合理focus；激活Alpha只发Alpha/1/other一次且actual scroll212px；激活Reader只加载book-6/ep-1一次，actual chapter1/page2/focus保持。对应rich-266168-{1..4}.{json,png}。

C269207以Reader为current从新PID启动，只请求book-6详情1与ep-1章节1，actual page2，search0，5标签/辅助marker均保持消费且无反馈再次出现，rich-269207-1.{json,png}与rich-c-reader-no-repeat-feedback.png。/tmp/ux1-35-rich-b-before-exit.json保存B磁盘，未用内存重建替代。

重要未闭合异常：B启动时SliverGridDelegateWithFixedHeight在layout.dart:64计算crossAxisCount0，随后sliver级联异常；B/C及此前basic启动均有15px RenderFlex，稳定截图业务正确不等于零异常。已拷贝真实生产日志/tmp/ux1-35-rich-production-log-through-c.txt，不能删弱/忽略。下一仅/tmp启动时序单变量：在runApp前设置真实窗口1000x700并等待physicalSize>1，区分1x1宿主初始化、恢复详情网格零宽和一次恢复反馈三假设；生产布局不动，工具改动先核准。3.5仍未勾，全部自有rich进程已正常退出；最终正常main构建恢复尚待。

### 首帧宿主时序单变量待核准（2026-11-16 14:28 CST）

architect已独立核A磁盘/B现场5标签及路由/views/active/recent一致、Reader第2页/收藏159/search212实际State；review-batch-2.md为architect文件，未改。仅/tmp/ux1_f1_gui.dart将既有placement.initialize/setSize(1000,700)/setPosition(20,20)移至runApp前，增加UX1_PREMOUNT_SIZE实际physicalSize日志；不加延迟、不吞异常、不改生产。精确diff已回传，旧文件/tmp/ux1_f1_gui.pre-window-order.dart仍为105d00d2…；新SHA42bd1cd8a24e937ba5493deb0f5c763c7c9a81d24817b9c6f544d4600f0d43ad。helper仍7c38817b147b632f869b38effdbe0970dd0fb89ead9058baa4e003aae9ac19fd。未构建/启动新版本，待architect核准；旧255580/266168/269207均已正常退出且ps无记录。若正常宿主尺寸仍复现，不能将其归为fixture已解决，需报告产品根因边界。3.5仍未勾，正常main构建/清理仍待。

## 2026-11-16 14:35 CST 最新权威交付：3.5已闭环，正常main已恢复

此前各段为历史；本段覆盖“3.5未勾/正常main待恢复”的旧续点。生产与测试源码本轮无变化，34生产/27测试冻结manifest全部MATCH；未修改architect的review-batch-2.md或契约。仅tasks3.5按真实新PID证据勾选，3.6既有勾选保持。不提交/归档/push，不跨F2。

**单变量根因结论。** architect核准/tmp harness42bd1cd8a24e937ba5493deb0f5c763c7c9a81d24817b9c6f544d4600f0d43ad，仅将既有placement.initialize/setSize/setPosition移到runApp前并打印physicalSize，无延迟/吞异常。helper7c38817b147b632f869b38effdbe0970dd0fb89ead9058baa4e003aae9ac19fd未变。`/tmp/ux1-35-rich-window-order-build.log`构建exit0。新PID275351/277155/281091全部挂载前physicalSize=1000×700，helper实测窗口1000×700+20+20。自日志旧202行之后仅3行Reader信息，新增Flutter error header **0**，真实详情/辅助页一次反馈与fresh启动均零Flutter异常；原15px/crossAxisCount0证据保留在rich-production-log-through-c。对照支持临时harness首帧宿主初始化顺序为原因，不修改生产layout或放宽断言。DRI3/Atk等原生环境警告仍存在，不宣称所有stderr为空。

**真实重启补证。** rich A255580→B266168→C269207全部正常关闭exit0，稳定现场与请求已记上段并经architect抽查。对照D275351在Reader页2启动只加载book-6/ep-1一次，真实激活book-2、点击封面进入辅助页，再正常关闭exit0；磁盘`/tmp/ux1-35-order-d-before-exit.json`含5tab及book-2 restoreParent=true。E277155新PID恢复book-2父详情，一次Temporary pages反馈，全部tab/route身份、栈、views/active/recent与D磁盘严格相等，仅restoreParent消费；只发book-2详情1次，其他来源请求0，旧PID不存在。截图order-e-restored-parent.png、F6 rich-277155-1.json/png。原C269207已验证标记消费后重启无重复反馈。

E真实Settings→APP→Application startup→Open favorites（绝对坐标937,327菜单及920,399选项），磁盘appdata workspaceStartup=fresh；F6 rich-277155-2与order-e-fresh-retains-session.png证明原5标签/当前Settings仍在。实际设置前后文件保存为/tmp/ux1-35-order-e-{appdata,implicitData}.json。E生产关闭exit0后F281091新PID从同目录启动，F6 rich-281091-1及order-f-fresh.png证明仅1个Favorites route、无反馈，details/searches/chapterRequests全部空；旧E PID不存在。F随后生产关闭exit0。全程没有直接设选择/scroll/页码、没有覆盖workspace/startup磁盘或重建seed。新进程State身份自然不同；保留实体/数据现场而非宣称跨PID同一对象。

**命令与计数边界。** 构建命令`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 RUSTUP_TOOLCHAIN=1.92.0-x86_64-unknown-linux-gnu fvm flutter build linux --debug --no-pub --target /tmp/ux1_f1_gui.dart`。启动显式`env DISPLAY=:1 GDK_BACKEND=x11 UX1_FIXTURE=ux1-f1-20261116 XDG_CONFIG_HOME=/tmp/ux1-f1-xdg-config XDG_DATA_HOME=/tmp/ux1-f1-xdg-data XDG_CACHE_HOME=/tmp/ux1-f1-xdg-cache XDG_STATE_HOME=/tmp/ux1-f1-xdg-state <project>/build/linux/x64/debug/bundle/venera-next --ux1-f1-fixture`，业务路径/tmp/ux1-f1-xdg-data/com.github.lezy233.veneranext。每次动作`env DISPLAY=:1 python3 /tmp/ux1_f1_x11.py <action>`均身份/root/window校验；key前精确输入焦点回读。F6只读实际State，capture稳定后独立保存已核验窗口，二者分列。GUI场景为人工输入/只读磁盘断言，不累加到Flutter test数量。真实磁盘故障保护/tmp/ux1-13-14-storage-protection.log仍10通过0失败0skip，设置/tmp/ux1-35-settings.log仍1通过0失败0skip，本轮只核最终日志未重复运行；原命令与范围见前段。

**最终收尾。** `/tmp/ux1-35-final-normal-main-build.log`命令同上去掉`--target`，正常main构建exit0；debug Dart产物为kernel_blob.bin，非libapp.so，具体SHA见batch-2-final-35-results.json。没有修改main/runner。PID275351/277155/281091均确认exit0且ps不存在；升级权限读取:1 X11树只剩qq和Chromium clipboard，无本任务窗口，未操作其他程序。保留/tmp审计harness/helper/隔离数据/截图，不再运行fixture，正常bundle已恢复。

34生产/27测试manifest重新校验全部MATCH，planner manifest的proposal/design/tabs spec三项MATCH，tasks因授权勾选而变化，旧manifest整体验证的此一项不匹配属预期，不伪称4工件全MATCH。固定保护pubspec.yaml/lock、design-spec、正式spec、AGENTS/ROADMAP/BACKLOG、main/runner零diff；planner既有D5/辅助页契约改动沿授权例外单列，executor无新增契约改动。`git diff --check`通过。当前源码analyze沿/tmp/ux1-35-36-analyze.log及comparison：raw/unique50/50=38+12，added=[]removed=[]，architect本轮亦独立复验50；本轮仅/tmp工具和任务证据变化，不重复无关源码矩阵。

最终可审计清单：batch-2-final-35-evidence.sha256（工具/GUI/快照/日志）、batch-2-final-35-results.json（本轮结果及正常main SHA），生产/测试仍以batch-2-progress-{production,tests}.sha256为准。本批提交仍未授权；交付等待architect独立复核，非owner最终验收。
