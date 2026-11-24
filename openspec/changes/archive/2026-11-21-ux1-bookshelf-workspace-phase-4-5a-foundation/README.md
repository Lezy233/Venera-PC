# UX1 5A 草稿视觉基线对齐基本工作阶段归档

2026-11-21 owner 指令将 gpt6.1sol 已完成的 UX1 5A 基本工作归档并提交 Git；本次未授权 push。归档范围包括 5A.1 草稿/生产差异审计、5A.2 差异分类与纠偏批次、Batch A–D 已实现切片、标签布局与排序，以及对应 DOM 证据和交付记录。

本归档是**基本工作阶段快照**，不是完整 5A 或 UX1 验收。Batch B 仍有收藏双层导航、作者 shelf、搜索首屏和详情 hero 后续项；Batch C/D 与标签排序仍待 owner GUI 复核；6.1–6.7 和 7.x 保持未完成。交付时已经记录的 `bookshelf_workspace_test`、`workspace_tab_input_test`、`shell_presentation_test`、`information_overlay_test` 失败或阻断不得改写为通过，详见各 delivery 文件。

活动 change 仍是后续契约与任务源，保留 5.5、5A 后续纠偏、6.x 和 7.x。本阶段不执行整个 OpenSpec archive，不把 delta spec 合入 `openspec/specs/`；`proposal-snapshot.md`、`design-snapshot.md`、`tasks-snapshot.md` 与 `specs-snapshot/` 仅冻结归档时状态。

归档前复核补上了 `WorkspaceTabStrip.reorder` 新增必填参数在两个既有拖放测试中的空调用适配，未改变生产行为。2026-11-21 独立复跑 12 个受影响测试文件：71 通过、6 失败、0 skip；失败为 `bookshelf_workspace_test` 1 项、`workspace_tab_input_test` 2 项、`workspace_preview_test` 2 项、`workspace_search_results_test` 1 项，保持为本阶段已知限制。17 个本次变更 Dart 文件的定向 analyze 为 No issues found；全量 analyze 为 52 项，其中既有归档基线 50 项，另有当前 pdfrx 环境的两个 `invalid_override`，未借本归档修改基线。`git diff --check` 通过。

本机没有可直接运行的 `openspec` 命令，尝试通过 npx 调用时 npm 网络连接被重置，因此本次未重新执行 CLI validate；既有交付记录中的 validate 结果保持原样，不冒称本轮通过。截图、日志和 fixture 不入库；`.metadata`、`web/`、`analysis_options.yaml`、Pod/SwiftPM 锁文件等生成物不属于本阶段提交范围。
