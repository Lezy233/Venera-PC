# Batch C 临时预览浮层焦点与紧凑布局

- 日期：2026-11-20
- 状态：实现完成，待 owner GUI 复核。

## 实现

- 预览浮层获得明确的键盘焦点环，焦点离开时恢复普通边界。
- 预览内容增加视口高度上限，expanded、medium、compact 和大文字场景改为在浮层内部滚动，关闭入口保持可见。
- 保留左右切换、Enter 当前标签、Cmd/Ctrl+Enter 后台标签、Escape 关闭及原卡片焦点归还契约。

## 验证

- `fvm flutter test test/app_shell/workspace_preview_test.dart`：8/0/0，通过。
- `fvm flutter analyze lib/features/comic_widgets/comic_preview.dart`：通过，No issues found。
- `git diff --check`：通过。

本轮尚未取得新 GUI 截图；待正常 macOS 构建可用后，需按 5A.2 的 expanded/medium/compact、150% 大文字、浅深主题和减少动画场景复核焦点环、滚动边界与关闭入口。
