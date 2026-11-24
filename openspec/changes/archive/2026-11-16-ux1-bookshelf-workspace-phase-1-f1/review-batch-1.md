# UX1 第一批 architect 独立复核

2026-11-08，基准 HEAD `6f1f1bc01ce69be91e62b9474a0b95f83a752d73`。本记录评估书架壳层与收藏切片，不代表 UX1 整体实现完成或 owner 人工验收通过。保持未提交、未归档、未推送。

## 结论与阶段边界

本批实现及补证符合已派阶段范围，可以接续 F1 多内容栈阶段。tasks 1.1/1.2、2.1–2.4 的阶段证据已核；1.3/1.4 的多栈、预览、统一主体、单进度红灯及真正工作区快照尚未完成，继续保留未勾。

2.4 的键盘结果限于已执行壳层控件矩阵及真实收藏覆盖层 Escape/焦点恢复。内层 Navigator 到外层工作区的全局 Tab 可达性尚未证明；这不是设计豁免，F1 的焦点模型与 tasks 3.3、7.1/acceptance H1 必须闭合。不得将本批测试概括为全应用仅键盘操作已经通过。漫画多选主体新语义按已批准阶段边界留 4.3，当前仍保护原 B4/F5 断言。

## 独立执行与核验

- 相关测试独立运行：`/tmp/ux1-architect-supplement-regression.log`，**293 通过、0 失败、0 skip**。测试集合为 `test/app_shell`、导航/平滑滚动/漫画列表生命周期，以及 F11 侧栏、F10 UI/布局/悬停/独立顺序/存储/拖动、B4 原命中与新增书架命中、F5 系列、收藏展示与设置持久化。所有 Flutter 调用使用规定代理、原生库路径和 `--no-pub`。未跑全库，既有 folder_order_ownership 编译基线未宣称修复。
- 独立 `flutter analyze --no-pub`：`/tmp/ux1-architect-supplement-analyze.log`，**raw/unique 50＝38 tool＋12 其他**；逐条比较冻结基线 added=[]、removed=[]。比对摘要为 `/tmp/ux1-architect-supplement-analyze-comparison.json`。执行者的完整诊断集合另见 `batch-1-supplement-analyze-comparison.json`。
- `batch-1-supplement-production.sha256` 的 **16/16**、`batch-1-supplement-tests.sha256` 的 **6/6**、工具与 GUI 清单全部独立校验 MATCH。原 `batch-1-*` 清单和之前 274 项独立回归为历史阶段证据，最终补修以 supplement 清单为准，计数不累加。
- 受保护设计/正式 spec/既往归档/AGENTS/BACKLOG/ROADMAP/pubspec.yaml/pubspec.lock/main/runner，以及 B4 两份原命中测试均零 diff；`git diff --check` 与 `openspec validate ux1-bookshelf-workspace` 通过。

## 补证与 GUI

独立审查打回的两点均已闭合：共享布局改为显式 opt-in，真实普通 ComicList 与生产手动排序页尺寸不随收藏密度变化；真实 MainPage＋WindowFrame＋收藏集成验证两卡身份、420px 业务滚动、同一页面/控制器、宽窄切换与 Escape 精确返回原焦点，并验证 query 绑定和卸载清理。两个收藏页面原 didChangeDependencies 同步通知改为沿用既有 build 帧后同步，是本轮集成必要修复；没有删除业务通知或旧测试断言。

已实际 view_image 抽查 `/tmp/ux1-cont-a-wide-selected-scrolled.png`、`ux1-cont-d-overlay.png`、`ux1-cont-f-wide-restored.png`、`ux1-cont-g-expanded-flutter.png`。GUI A–G 日志核对 page=273429618、controller=85245702、实体 local:ux1-0/local:ux1-1、offset=214.95852066715972；覆盖域中焦点变化，Escape 返回原选择 FocusNode identity558480815，恢复宽窗偏好保持收起。图中选2及作品0/1选中态一致。

完整 Flutter 帧不等于完整 X11 宿主图；宿主1080×760，expanded X11 图明确标为裁截，真实鼠标仅屏幕可达区域。主题为受控 ThemeData，不证明真实动态取色链路；macOS 未实机验证，GUI 组合为代表场景，未冒称全部排列。以上局限继续进入最终验收，不删弱。

## 正常入口与清理

正常 main 构建 `/tmp/ux1-supplement-main-build.log` 成功。独立检查 kernel SHA `37982c9e23848d81e68fee6c4dad8e5c279c25899d095004eeed8ef18034b0e8`，包含正常 main，未包含 `/tmp/ux1_gui.dart` 入口。PID351413 不存在；独立 X11 树仅原 QQ 与 Chromium clipboard 窗口，无本任务窗口。临时工具、fixture 数据及截图仅在 /tmp，不入库。
