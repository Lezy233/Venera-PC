# Venera-PC UI/UX 改造路线图

> 分工：codex「architect」（规划，pane w4:p1）→ codex「executor」（执行/debug，pane w4:p2）→ owner（人工验收 → archive）
> 规则见 `openspec/config.yaml` 的 context 与 operations。已完成的 quick wins 见 `doc/ui-audit-2026-10-20.md`。
> 设计方向（2026-10-20 锁定，同日修订）：现代极简——浅色内容区 + 浅色壳，动态取色为唯一强调色来源；阅读器跟随主题不设例外；深色内容区主题为二期。详见 design-system-foundation。

## 执行顺序（依赖关系）

**2026-11-26 状态（覆盖 11-25 排期）**：4 个活动 change，`openspec validate --changes` 4/4 通过；归档 23 个、正式 specs 20 份。`ux1-bookshelf-workspace` **41/47**（余 5.5、7.1–7.5；6.1–6.7 与 7.6 已实施并经 architect 独立复核，待 owner 验收）；`ci-quality-gate-recovery` 14/15；`desktop-only-ci-cd` 10/12；`venera-pc-rebrand` 20/21。顺序：**UX1 7.1–7.5 owner 验收 → 单一 PR（含 ci 提交，取得 ci 4.5 与 desktop 4.3 证据）→ rebrand 7.3**。门禁：结构/架构/`flutter analyze --fatal-infos --fatal-warnings` 均 0，Python 156/0/10，全量测试 **5791/0/150**（architect 独立复跑）。剩余已知债务为 4 条既有 UI 跨 feature 边（BACKLOG）。

2026-11-21 owner指令归档并提交UX1 5A基本工作，未授权push。阶段快照：`changes/archive/2026-11-21-ux1-bookshelf-workspace-phase-4-5a-foundation/`；含审计、纠偏计划、Batch A–D已交付切片及标签布局/排序。Batch B后续项、owner GUI复核与6.x/7.x仍未完成，活动change继续保留，不整项archive或合入未实现delta。

2026-11-18 owner已验收UX1搜索/详情及全局卡片交互阶段（5.1–5.4、5.6–5.13），授权阶段归档提交，未授权push。归档 `openspec/changes/archive/2026-11-18-ux1-bookshelf-workspace-phase-3-search-details/`；独立15/0skip、相关128/0skip（重叠不相加）、analyze raw/unique50=38+12零新增、正常构建/保护校验通过。5.5真实GUI证据保持未勾，活动change继续6.x阅读器→7.x整体验收，不整项archive或合入未实现delta。

**2026-11-17 最新状态（覆盖下方历史）**：owner验收1.3＋F2（4.1–4.5）通过并授权阶段归档提交，未授权此次推送。证据见 `changes/archive/2026-11-17-ux1-bookshelf-workspace-phase-2-f2/`；书架/F1此前已归档推送。活动UX1仅余5.x搜索/详情 → 6.x阅读器 → 7.x整体验收，继续保留，不整项archive或合入未实现delta。

**2026-11-16 当前状态**：UX1 书架壳层与 F1 多标签阶段已经 owner 验收并授权归档、提交、推送；阶段证据见 `changes/archive/2026-11-16-ux1-bookshelf-workspace-phase-1-f1/`。活动 `ux1-bookshelf-workspace` 继续保留，余项按 1.3 对应阶段红灯 → 4.x F2 预览/多选拖放 → 5.x 搜索/详情一致性 → 6.x 阅读器交互 → 7.x 整体验收推进。下方旧的“生产未启动/待排期”为历史；尚未完成全部任务，不合并整个 delta spec。

功能愿望与新功能规划见 `openspec/BACKLOG.md`（愿景 + 候选清单 + 批次建议）。

2026-11-01 owner反馈的依赖/验收条件见BACKLOG「Owner反馈TODO」。当前F6/F7、B3/B4及F8–F10均已验收归档；B5于2026-11-06验收归档，2026-11-07随F11推送；F11于2026-11-07经owner验收通过并归档。UX1于2026-11-07完成方向确认和正式方案，F1/F2纳入其分阶段实施，已分阶段交付归档（见执行表 #17）；2026-11-24 的 UX1 计数与余项以文首状态为准。

2026-11-02 owner实际搜索未得到结果，已批准废止B2详情跨平台入口及原F7专用作者聚合链路。`search-profiles-author` 最终设计：F6搜索方案保留，F7改为收藏右栏单选创作者的平台名称树，可维护同源多名称并点击普通单源搜索。2026-11-03实现与自动化独立复核完成：113项测试全通过、0skip，analyze50=38+12零新增；F6/F7 GUI证据已重留并独立抽查通过，正常生产构建已恢复，owner于2026-11-03验收通过，已归档（实现commit c5429bb）。B3/B4已于2026-11-03由owner安排，四件套已建并校验，顺序执行；F8–F11尚未启动。

| # | Change | 内容 | 前置依赖 |
|---|--------|------|----------|
| 1 | **design-system-foundation** | 设计方向确认 + design-spec.md + token/断点系统 + 壳层规范 | 无（最先做；方向任务 1.1 需 owner 确认） |
| 2 | **settings-ia-cleanup** ✅已归档 | WebDAV 三合一（P0）/ 阅读设置作用域选择器（P1）/ 分类调整（P1） | 与 #1 可并行；断点迁移受 #1 影响处需对齐 |
| 3 | **desktop-shell-polish** ✅已归档 | 宽屏设置就地编辑（P2） | #1（断点）、#2（WebDAV 入口对齐） |
| 4 | **desktop-search-context** ✅已归档 | 命令中心三上下文行为统一（P1-6） | #1（命令中心可见性规则） |
| 5 | **reader-quick-settings-panel** ✅已归档 | 阅读内精简设置面板（P0-1 遗留） | #2 的作用域选择器（降级路径见 design.md D3） |
| 6 | **keyboard-shortcuts**（BACKLOG F3，批次 A）✅已归档 | 动作注册表 + 多键位自定义 + 冲突检测 + 独立主分类 + 平台默认键（2026-10-23 归档，commit b735663） | 无强依赖（注册表为 F1 多栈预留扩展，见 design D8） |
| 7 | **reader-mode-presets**（BACKLOG F4，批次 A）✅已归档 | 阅读模式方案 CRUD：命名快照/应用/管理 + 面板方案切换（2026-10-23 归档，commit 1c8fbc3） | settings-ia-cleanup 作用域选择器（已归档）；quick-settings 面板 |
| 8 | **favorite-series**（BACKLOG F5，批次 C）✅已归档 | 跨来源手动系列 + 收藏文件夹右键操作 + 顶部多选入口 + Escape 退出 + 批量加入系列（2026-10-25 归档，commit ce5be2a） | settings-ia-cleanup（已归档） |
| 9 | **search-profiles-author**（BACKLOG F6+F7，批次 C）✅已归档 | 搜索方案CRUD/来源排序及选项 + 收藏单选创作者平台名称树/手动维护/普通单源搜索（2026-11-03 owner验收，实现commit c5429bb，替代旧B2） | 既有搜索及收藏作者alias基础；F8前置已满足 |
| 10 | **reader-preset-state-recovery**（B3）✅已归档 | 持续编辑共享19键、跟随默认保持绑定并动态继承；285+174测试0skip、analyze50零新增，GUI/重启/正常构建通过 | 2026-11-03 owner验收通过，实现526c311；归档review.md含证据 |
| 11 | **comic-card-hit-target-fix**（B4）✅已归档 | 标题首行/封面命中、窄brief紧凑徽章；owner验收通过，实现6f65f7f，174测试/50基线及GUI通过 | 无B3技术依赖；2026-11-03单独归档，B3返工保留 |
| 12 | **search-target-memory**（F8）✅已归档 | 记忆聚合/单源及方案身份，失效可见回退、可靠保存；59测试0skip、analyze50零新增、GUI/重启/正常构建通过 | 2026-11-04 owner验收通过，实现3749a52；见归档review.md |
| 13 | **reader-preset-ordering**（F9）✅已归档 | 拖动和上/下移，跨入口顺序/绑定/继承不变；525测试0skip、analyze50零新增、GUI/重启/构建清理通过 | 2026-11-04 owner验收；实现bc3f82a，2026-11-06随F10推送 |
| 14 | **favorite-author-manual-order**（F10）✅已归档 | 作者分栏/三态/独立排序/单源搜索及卡片hover反馈 | 2026-11-06 owner验收并授权归档推送，实现cdce3e6；tasks4.x 3/3、独立204通过0skip/analyze50零新增，GUI/正常构建/清理与23SHA通过 |

| 15 | **reader-double-page-letterbox-fix**（B5）✅已归档 | 修正双面错误窗口尺寸覆盖，保护原图比例/完整性与既有阅读语义 | 2026-11-06 owner验收通过，实现49ea8a9；tasks1.x 4/4、独立148通过0skip/analyze50零新增，GUI/正常构建/清理/SHA通过；2026-11-07随F11推送 |

| 16 | **favorites-sidebar-section-collapse**（F11）✅已归档 | 本地/系列/网络独立折叠、状态记忆、当前条目摘要及键盘/菜单隔离 | 2026-11-07 owner验收，实现4a886a6；tasks5/5、独立140通过0skip/analyze50零新增，GUI/真实重启/正常构建/清理及四SHA通过，本次授权推送 |
| 17 | **ux1-bookshelf-workspace**（UX1，5A基本工作已归档） | 6.1–6.7、5A 对账与 7.6 全量测试归零已交付（5791/0/150）；余 5.5、7.1–7.5；tasks 41/47 | 基于 #18 分支；owner 7.x 验收后进入单一 PR；6.6/6.7 需复验原缺陷路径与目视 |
| 18 | **ci-quality-gate-recovery**（实施中，14/15） | WebDAV 客户端入库为 path 依赖、两个额外失效 git 依赖改同 commit 镜像、恢复 components/features/app_shell 依赖边界、macOS 授权检查迁到 macos-15；并补齐架构 inventory、修复 CI 可见 analyze 问题、vendored 目录排除格式/分析检查 | 无硬前置；4.5 需 UX1 7.x 验收后的绿灯 PR 证据；⚠ 会搬迁 `app_shell` 共享 UI，UX1 6.x 基于本分支 |
| 19 | **desktop-only-ci-cd**（10/12） | 桌面专用 CI/CD：build/main/pr_build/analyze 收敛，移动商店工作流删除 | 余 4.1 本地全量脚本测试、4.3 PR 门禁核实；依赖 #18 与 #17 全绿 PR 后复核 |
| 20 | **venera-pc-rebrand**（20/21） | Venera-PC 产品身份与发布命名（Windows/macOS/Linux 资产、README、元数据） | 平台构建验证依赖 #18/#19 与 #17 全绿 PR；余 7.3（Linux 冷启动走查 + CI 构建核实） |

当前状态：**F10于2026-11-06经owner最终验收通过并授权归档推送**，实现cdce3e6，归档2026-11-06-favorite-author-manual-order，复核证据见归档review-v2.2.md；F9此前本地提交随本次推送。**B5 reader-double-page-letterbox-fix已于2026-11-06经owner验收通过并归档提交**（实现49ea8a9，tasks4/4、148通过0skip/analyze50零新增、GUI/正常main构建/清理及SHA通过，局限见归档review.md；2026-11-07随F11推送）；F11收藏侧栏分类折叠于2026-11-07经owner验收通过并归档2026-11-07-favorites-sidebar-section-collapse，实现4a886a6，tasks5/5、独立140通过0skip/analyze50零新增，GUI/真实重启/正常构建/清理及四SHA通过，本次授权推送。2026-11-07 owner确认UX1 A书架型方向及全部默认值，正式方案位于openspec/changes/ux1-bookshelf-workspace；截至2026-11-24，F1/F2 与 5.x 已分阶段交付归档，UX1 整体 41/47，余 5.5、7.x，详见文首状态与执行表 #17–#20。

## 已完成（quick wins，不在 changes 中）

- 设置页双栏默认着陆（settings_page.dart）
- Reading 页 7 组分组标题（reader.dart）
- 搜索框上下文提示语（desktop_top_bar.dart）

## 验收后归档

每个 change 由 owner 验收后运行 `openspec archive <name>`，delta spec 合并进 `openspec/specs/`。
归档前执行 agent 必须完成：flutter analyze 基线50项零新增、tasks.md 全部勾选、新增词条已补 zh_CN/zh_TW。

2026-11-03 owner人工验收：B4通过，未发归档推送指令；B3不通过，要求选中的方案成为持续编辑目标。planner已修订B3四件套，保留19键范围并明确同ID共享、None退出保留效果、旧引用迁移及失败恢复；交executor执行3.x/4.x后再次独立复核。B4实现与工件作为保护基线，不混入返工。

2026-11-03 owner明确「先归档推送B4，B3继续完成」：B4实现6f65f7f，归档2026-11-03-comic-card-hit-target-fix；B3保持活动change，未提交返工实现、未归档，待剩余窄回归/GUI与跟随默认语义完成后另行验收。

2026-11-03 owner裁定B3跟随默认：保持方案绑定并保存共享继承行为，按各目标上层模式策略动态求值；planner补充D2.4/spec/tasks3.5。既有窄35测试、已定GUI/真实重启及正常构建完成，待继承分支实现后最终回归及独立复核。

2026-11-03 owner最终验收B3通过并授权归档推送；实现526c311，归档2026-11-03-reader-preset-state-recovery。历史未完成记录以上述最终状态为准；接续F8 → F9。

2026-11-04 owner验收F8通过并授权归档推送后执行F9；F8实现3749a52，归档2026-11-04-search-target-memory。F9沿既定四件套交executor新会话，不启动其他change。
