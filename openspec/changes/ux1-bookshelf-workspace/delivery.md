# UX1 交付总览（2026-11-26，owner 手动验收通过）

本 change 分阶段实施、分阶段归档，剩余 5A 对账、6.x 阅读器与 7.6 全量测试归零在本分支完成。owner 于 2026-11-26 手动验收通过；本文件汇总最终门禁、范围与局限，作为 7.5 的交付索引。

## 最终门禁（architect 独立复跑）

| 检查 | 结果 |
|---|---|
| `check_structure_imports.py` | exit 0，0 违规 |
| `check_architecture_dependencies.py` | exit 0，`baseline is clean` |
| `.github/scripts/tests` | 156 运行 / 0 失败 / 10 skip |
| `flutter analyze --fatal-infos --fatal-warnings` | `No issues found`，exit 0 |
| 全量 `flutter test --concurrency=4` | **5791 通过 / 0 失败 / 150 skip**，exit 0，7:16（`tmp/review-7x.log`） |
| `openspec validate --changes` | 4/4 通过 |
| `git diff --check` | 干净 |

保护边界：`design-spec.md`、`openspec/specs/**`、本 change 的 delta specs、`ci-quality-gate-recovery/**` 零 diff；`pubspec.lock` 仅含 ci change 的 24 行最小差异；`packages/webdav_client/` 与上游缓存逐文件一致；无截图入库。

## 分支与提交

- 分支 `ux1-reader-6x`，基于 `fix/ci-quality-gates @ ecaa99f`；未 push、未建 PR、未 archive。
- `d24fbb5`：6.6–6.1 收尾、6.7 布局槽、6.5 Xvfb GUI、7.6 全量归零、5A/workspace 对账与新测试。
- `de23ce9`：architect 独立复核记录与状态同步。

## 阶段交付索引

- F1 书架壳层与多标签：`archive/2026-11-16-ux1-bookshelf-workspace-phase-1-f1/`
- F2 预览与多选拖放：`archive/2026-11-17-ux1-bookshelf-workspace-phase-2-f2/`
- 搜索/详情与全局卡片：`archive/2026-11-18-ux1-bookshelf-workspace-phase-3-search-details/`
- 5A 基本工作：`archive/2026-11-21-ux1-bookshelf-workspace-phase-4-5a-foundation/`
- 本阶段：`delivery-6x-7.6.md`、`review-6x-7.6.md`、`full-suite-baseline.md`；早期诊断与批次记录 `delivery-batch-{1,2,3}.md`、`review-batch-{1,2,3}.md`。

## GUI 与局限

- 6.5 使用隔离 Xvfb 生产 bundle 逐图像素核对两行/单行顶栏、单进度、章节 Escape；owner 手动验收覆盖真实桌面。
- 6.6 原缺陷未能复现（旧测试等待错 save owner），新增面板级/Reader 级持久化测试；owner 手动验收通过，视为覆盖原复现路径。
- 6.7 精简进度线为 8px 布局槽、不覆盖漫画；owner 目视通过。
- 6.5 的“第二标签后台休眠/跨重启页码恢复”只有自动化覆盖，未取得 GUI，已如实声明。
- 150 skip 均为既有平台条件跳过，未新增；全量覆盖率在本机高内存占用下 4 并发收尾不稳，覆盖率用 2 并发同套测试取得（82.44%），测试结果以 4 并发无覆盖率全量为准。

## 已知债务

- 4 条既有 UI 跨 feature 直接边（`favorites→search`、`reader→settings`、`search→favorites`、`settings→search`）由 `ci-quality-gate-recovery` 2.5 登记为 allowlist 债务，清理项见 `openspec/BACKLOG.md`。
