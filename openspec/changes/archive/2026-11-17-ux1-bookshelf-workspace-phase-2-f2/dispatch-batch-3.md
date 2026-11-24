你是 executor（w4:p2），architect 在 w4:p1。owner 已安排当前 UX1 的 1.3 + F2（4.1–4.5），要求 architect 持续监听并代办任务内权限。基准 HEAD 5548f5fedf1d40c28e1bcaefb41653a65106bd78，分支 redesign-2026；开局先核 HEAD 和干净工作区。书架/F1已验收并阶段归档提交推送；此次是同一个活动 change 的新阶段，不沿用旧的“不可跨 F2”限制，不新开另一套 change。

阅读 AGENTS.md、ROADMAP、活动 openspec/changes/ux1-bookshelf-workspace 的 proposal/design/全部specs/tasks，以及 design-spec.md 相关 UI 契约。本轮只实现 1.3 + 4.1–4.5，不做5.x/6.x生产功能。可新建或修改生产控件测试，先红后绿；上一轮“不得改测试”的限制不适用于本轮。使用 diagnosing-bugs、tdd 和 ui-ux-pro-max 技能，只解决现有契约，不重建视觉系统。项目文件直接用 apply_patch 等编辑工具；不要用 Python 字符串替换绕行编辑生产文件。

1.3：补真实生产控件的 Space 预览、多选独立命中/拖放缺失红灯，并补全全局主体点击（5.1）与单进度/漫画单击（6.2）等尚缺的生产基线红灯。已实现多栈不得人为改坏制造红灯，引用既有历史红→绿并记录当前绿。每个红灯必须是正确初始化后实际坐标/按键/路由/请求/可见组件断言失败，非静态源码猜测、初始化错误或仅调回调。未来5/6阶段的诊断测试可在/tmp执行并保存可重放patch/源码文字及原始命令/断言到delivery，勿将当前必然失败的测试混入常规suite或加skip掩盖；1.3是建立证据，不授权实现5/6。全部要求均有真实证据才勾1.3；部分证据先如实备注，继续不依赖该缺口的F2。

F2边界以design D4/D5/D6/D10和browse-and-preview/workspace spec为准：
- Space从实际当前卡片打开概览/目录/必要详情预览，不建标签、不写标签历史；左右切换同组目标，Space/Escape关后回原卡片，保留滚动、多选，输入框/Reader原Space不被吞。浮层加载、卸载和快速换目标不得串来源/作品或触发整批完整详情操作。
- Enter在当前标签打开并保持标签内返回关系；Cmd/Ctrl+Enter后台详情，不抢占原工作现场，后台首次激活才加载。命中只执行一次，不透到底层卡片。
- 右上角复选框hover/focus出现、选中常驻，勾选/描边/语义完整；复选框只选，主体按既有全局偏好正常打开，已有选集不把另一主体点击变成选中或清空。此4.3必做，若需统一全局设置文案/所有非F2列表等5.1范围则先向architect说明最小依赖，不自行扩展。Escape先关预览/菜单等上层，下一次才清空选择。保护F10独立排序与拖动、F11折叠、B4命中、F5系列身份。
- 多选真实拖至标签栏，每实体建立后台详情，正确id/sourceKey、准确次数、原页保持；Escape取消拖动不建标签。按钮或菜单及Cmd/Ctrl+Enter有等价入口；不能只直接调用drop回调替代拖放。不能修改收藏、作者顺序或来源配置。注意与作者栏既有长按重排冲突，冲突先报告architect。
- 覆盖expanded/medium/compact、浅深、150%文字、简繁、手动/系统减少动画、鼠标/键盘/焦点、独立按钮和请求计数。复用token/语义色/现有组件，预览可滚动且关闭入口始终可用。

每完成一项立即勾tasks并写真实备注。新交付用 delivery-batch-3.md 和本阶段源码/测试/证据manifest，不覆盖历史交付或已归档证据。新文案.tl，assets/translation.json同时zh_CN/zh_TW。不得改 proposal/design/delta spec、design-spec.md、openspec/specs/**、pubspec.yaml/lock、已归档阶段文件；不升级依赖/重生成lock/修无关基线。发现契约冲突停相关实现报architect，其他独立工作继续。不得自行提交/归档/push。

Flutter fvm3.47.7，命令前https_proxy/http_proxy=http://127.0.0.1:7897，test/build/analyze全部--no-pub；原生测试LD_LIBRARY_PATH=$PWD/build/linux/x64/debug/bundle/lib。analyze raw/unique50=38tool+12其余具体集合零新增，记录原始/唯一计数与added/removed。必要pdfrx外部cache四处cache!.热补丁先核对、不改lock。环境sandbox写SDK失败时申请窄权限，不让owner改已正常可写的SDK。

GUI：DISPLAY=:1 GDK_BACKEND=x11，四个XDG及业务/cache显式隔离，截图只/tmp，临时harness只/tmp，正常main/runner不为fixture修改。可复用/tmp/ux1_f1_gui.dart和helper但须核全文SHA、标题/PID/exe/marker/坐标/focus；旧stage snapshot不覆盖。窗口placement.initialize/setSize/setPosition在runApp前并记录实际physicalSize，避免已确证的临时1×1首帧异常；不靠等待/吞异常掩盖问题。新工具或修改工具先给SHA/精确diff由architect核准。可为固定Flutter任务命令、经核准固定GUI helper申请合理窄前缀，不以坐标/日志名作每次审批边界，不申请全局访问。只操作本轮隔离窗口，正常窗口关闭清理，禁XKillClient/杀显示服务/广泛pkill。

owner已持续授权architect处理任务内审批，不向owner重复询问。原生审批弹窗请architect读屏；自动Reviewing approval request不是可盲按的弹窗。若真额度/自动审查阻断如实报，不将其当产品红灯。

交付：根因/红绿原始命令与计数0skip、实际新增和相关保护回归、analyze50具体集合、tasks、protected零diff/diffcheck/OpenSpec、逐图真实场景、受控来源局限、normal main恢复构建和自有fixture精确清理。先反馈开局核验和红灯计划，随后自主持续执行直至本轮完成；architect持续监听，完成等独立复核，不自行提交。

## 派工后边界记录

- 正常启动阻断的必要生产修复已由architect按实测首帧证据批准：允许在`lib/main.dart`仅将现有`await placement?.initialize()`移至`runApp(MyApp(host: host))`之前，作为单变量验证及最小修复候选。此前“正常main/runner不为fixture修改”规则继续有效；此次是正常入口初始化顺序修复，不是fixture接入，不允许其他main重构或runner改动。不新增只为搬运该语句的抽象或源码字符串测试；用同输入正常main冷启动、实际绘制窗口与原日志消失证明，配合既有启动/窗口生命周期保护测试。若单变量未转绿则继续诊断，不能预先定根因或扩大改动。

- owner 随后澄清：正常 run 后**无任何窗口弹出，无法进入应用**。以生产正常 main 无窗口为首要复现目标，overflow仅伴随线索；必须区分进程退出/启动停滞/隐藏或未映射窗口，不能用已在runApp前初始化窗口的旧harness替代正常入口证据。禁止以无依据的手动删配置/重置数据交给owner处理。

- owner 启动验收新增阻断：正常 `fvm flutter run -d linux` 输出右侧15px溢出两次、底部15px一次。executor 按 diagnosing-bugs 构建可自动重放的真实生产布局反馈循环，先取得具体 RenderFlex/约束/页面/首帧尺寸及未改源码的有效红灯，再最小修复并以相同输入转绿。不得将启动日志中正常 VM Service/动态色提示猜作原因；不吞错误、不缩字/裁剪掩盖、不改窗口或保存数据来消除现场。先核当前授权脏改并保留，用户配置可只读核必要项且不打印敏感内容，不操作 owner 真实窗口；隔离 GUI 正常 main 启动与 fixture 身份分列。优先复用现有测试和已核准工具，变更工具先审；用户原页面/尺寸尚待补充，不等待即可独立查证启动和边界。若不能匹配 exact symptom，如实记录缺口，不能以相近绿灯宣告修复。受保护文件/权限代办/不提交归档push规则不变；最终更新诊断、SHA/analyze及正常main构建清理并交 architect 复核。

- 2026-11-17 owner 已明确“采纳建议”：作者栏采用独立拖动手柄进行选集拖出，保留卡片原长按排序。此前待选状态已解除，以 design D4 和 browse-and-preview 新增场景为准。续做 4.4/4.5：手柄命中与复选框/主体/原长按排序分离，空选集不启动；保护三态、每栏独立排序、跨栏同实体选择及原焦点/滚动，Escape 取消零新增，drop 每实体后台详情准确一次、正确来源、零提前详情请求。复用既有菜单/键盘等价入口及已通过矩阵，新增必要真实坐标控件回归和有界作者栏 GUI；不重复无关全矩阵。当前授权脏改全部保留，核对 HEAD 和当前清单，不要求清工作区。源码改动使最终冻结失效，按影响更新 SHA/analyze/正常 main 构建和 fixture 清理，交付等待 architect 独立复核，不提交/归档/push。

- 作者栏现有主体长按排序与 F2 多选拖放的手势冲突已转 owner 选择：独立拖动手柄（建议，保留原长按）或选中卡片普通拖动并停用该卡片长按排序。等待答案期间不改作者栏拖动；普通网格和其他独立任务继续。未答复不视为批准。
- architect 已批准 D10/4.5 必要的最小依赖：补 Appearance 的可靠手动 Reduce motion bool 与设置入口，新预览读取“手动 OR 系统 disableAnimations”。使用现有持久化及 .tl/双中文，测试真实保存重载和两独立开关；阅读器和其他全局动效仍留 6.4。本项为既定契约实现依赖，不扩大为全局动效重构。
- 2026-11-17 最终复核发现 4.3 明文要求主体遵循全局点击设置，故撤回其过早勾选。architect 批准必要的最小绑定：ComicTile/SimpleComicTile 默认主体与普通 Enter 共用既有 FavoritePreferences.onClickFavorite；read 使用既有 ReaderWithLoading，viewDetail 使用既有 ComicPage。typed reader builder 复用 configureComicWidgets 注入并在 app_runtime/init.dart 连接；自定义 onTap 保持优先，显式 Details、预览提升、后台详情仍为明确详情语义。此依赖覆盖默认 F2 卡片，不改默认布局/设置名称/详情层级/6.x。1.3 的原失败证据留作历史，新行为须真实点击红→绿、身份/一次/返回/hero 保护；5.1 整项仍未完成。生产冻结与改前 GUI 证据分别记录，按实际影响更新测试、SHA、analyze、正常构建与有界 GUI。
