# UX1 6.x + 7.6 独立复核（architect，2026-11-26）

基准分支 `ux1-reader-6x @ d24fbb5`（基于 `fix/ci-quality-gates @ ecaa99f`），工作区干净。本记录只覆盖 6.1–6.7 与 7.6 的实施复核；不影响 5.5 与 7.1–7.5 仍未完成，也不构成 owner 验收、提交推送或归档授权。

## 独立复跑（architect 本机）

| 命令 | 结果 |
|---|---|
| `python3 .github/scripts/check_structure_imports.py` | `Structure import boundaries are clean.`，exit 0 |
| `python3 .github/scripts/check_architecture_dependencies.py` | `Architecture dependency baseline is clean.`，exit 0 |
| `python3 -m unittest discover -s .github/scripts/tests -p 'test_*.py'` | 156 运行 / 0 失败 / 10 skip，`OK` |
| `fvm flutter analyze --fatal-infos --fatal-warnings` | `No issues found!`，exit 0 |
| `LD_LIBRARY_PATH=$PWD/build/test-native/lib fvm flutter test --concurrency=4` | **5791 通过 / 0 失败 / 150 skip**，exit 0，7:16（`tmp/review-7x.log`） |
| `git diff --check` | 干净 |

保护边界：`design-spec.md`、`openspec/specs/**`、`openspec/changes/ci-quality-gate-recovery/**` 零 diff；`pubspec.lock` 仅含 ci change 的 24 行最小差异；`packages/webdav_client/` 与上游缓存逐文件一致（仅多 `PROVENANCE.md`，上游 `example/`、`images/`、`test/`、`.git` 仍被排除）。

测试完整性：skip 仍为 150（与基线一致，无新增 skip）；未删除测试（`reader_exit_integration_test` 的 `testWidgets` 98→99）；迁移的旧断言在原位置被加强或等价替换（例如 `fixture.exits` 断言总数 45→45、`barsVisible`/`orientation` 断言保留），未发现用宽泛 finder 或空断言掩盖。

## 逐项判定

- **6.1–6.5：符合。** 真实 MainPage 测试覆盖两行/单行顶栏、沉浸隐藏与恢复、任意单击切工具、单进度、章节浮层两级 Escape、同 Reader/标签/章节页码/请求现场；B3/F9 39/0/0 与 B5/读者退出保护保留。GUI 使用 Xvfb 生产 bundle 逐图像素核对，属于自动化证据，owner 桌面视觉仍归 7.3。
- **6.6：条件符合。** 未复现 owner 报告的“方案选择无法持久化”，新增面板级 3 项与 Reader 级 1 项真实控件持久化/失败恢复测试，B3 语义（重试不重放失败编辑）保留。**局限：章节切换维度未单独取证；owner 应按原复现路径复验，若仍复现则立即重开本项。**
- **6.7：条件符合。** 重建 owner 否决的 Stack overlay 红后恢复布局槽实现；8px 单条、无覆盖、无模糊/章节按钮，dark+150%+减少动画与展开态均通过。**owner 需目视确认精简进度线不再覆盖漫画。**
- **7.6：符合。** 64 项基线失败全部转绿，独立全量复跑 0 失败；差值 +72 = 64 项修复 + 8 项新增测试。

## 契约与保护测试变动

- **密度隔离（owner 本次裁定 A）**：排序编辑器改用收藏 bookshelf 卡片并钉定舒适密度；`bookshelf_density_isolation_test` 删除了原“HEAD 七列宽度”pin，改为 `bookshelf == reorder` 与“切密度尺寸不变”，几何一致性由 `favorites_reorder_test` 负责。这属于保护测试的定向弱化，因 owner 明确裁定且仍有补偿断言而接受，记录备查。
- `search_profile_flow_test` 由 `SimpleComicTile` 改为 `ComicTile`、增加 `Scrollable.ensureVisible`，与 UX1 D4 聚合卡形态一致；断言“只打开对应来源详情一次、不打开全部结果”保留。

## 局限与后续

1. 6.6 的原缺陷路径（章节切换）未单独取证；owner 复验是关闭条件。
2. 6.5 未取得“第二标签后台休眠/跨重启页码恢复”的 GUI，仅自动化覆盖，已在交付中声明，未冒称通过。
3. `delivery-6x-7.6.md` 有编辑残留断句，architect 已最小修正；内容重复段保留，不影响证据。
4. 本分支未 push、未建 PR、未 archive；UX1 仍 41/47（余 5.5、7.1–7.5），owner 7.x 验收后再进入单一 PR（含 ci 提交）以取得 ci 4.5 与 desktop 4.3 的 PR 证据。
