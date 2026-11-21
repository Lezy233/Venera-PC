# Batch D 阅读器 chrome 收尾（第一切片）

- 日期：2026-11-20
- 状态：第一切片完成；精简底栏与工具切换布局修复已追加，仍待 owner GUI 复核。

## 实现

- `ReaderTopBar` 移除 `BlurEffect` 和 `Colors.grey` 边界，改用当前 `ColorScheme.surface` 与 `outlineVariant` token。
- 标签长按拖动暂缓，已记录在 `TODO.md`，不再阻塞 Batch D。
- 精简模式底栏改为实际 8px 自绘单进度轨道，不再保留完整工具栏的 105px 或隐藏滑块的 48px 空占位；轨道无 thumb、overlay、底部安全区和额外命中槽。
- 普通模式始终保留相同的 8px 底部几何槽，完整工具栏覆盖显示，工具切换不再改变漫画内容列的高度。
- 沉浸切换的原生窗口变更改为 shell 重建后的 post-frame 调度，并增加 reader 生命周期守卫，避免 macOS 在同一手势中同步拆装 reader surface。
- 精简进度轨道进一步收敛为 8px 纯轨道，隐藏 thumb 和 overlay；Debug macOS 下仅切换 reader immersive chrome，跳过原生全屏窗口调用，避免 Flutter VM 断连，release/profile 仍保留原生全屏路径。
- 精简轨道的填充方向及命中映射跟随阅读方向；`reversed` 时页数从右侧向左侧增长。

## 验证

- `flutter analyze lib/features/reader/top_bar.dart`：通过。
- `git diff --check`：通过。
- `shell_presentation_test.dart` 3 项在既有 fixture 的 `Icons.screen_rotation` 查找处失败；失败发生在进入本次 top bar 断言前，未归因于本切片。
- `information_overlay_test.dart` 当前仍有既有 tap 计数失败（6 个场景，实际 0/期望 2），与本次底栏几何断言无关，需后续独立迁移/复核。

后续 Batch D 仍需继续核对 6.1–6.7 的普通/沉浸行数、单进度、章节 Escape、主题和减少动画 GUI 证据。
