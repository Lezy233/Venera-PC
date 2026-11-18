# Batch 5 dispatch — owner additions 5.6/5.7

2026-11-18 owner reported two production bugs. Executor scope is limited to the following tasks; 5.5 remains separately blocked on real GUI evidence.

## 5.6 cover-ratio repair

Establish a production red case with at least two controlled covers of different aspect ratios and pixel/layout assertions that identify the crop. Preserve the existing gallery density, columns, title behavior, hover/pressed/selected/focus states, independent checkbox/menu/body hit targets, entity identity, source key and hero. The smallest fix must show the full cover at its original ratio; do not introduce a new visual system or hide the problem with a fixed landscape card. Cover affected responsive and typography states or record why a state is not affected.

## 5.7 single-card drag to background tab

Establish a real pointer-coordinate red case with no selection: drag one card body onto the tab bar. The result is exactly one background detail tab for that card, while the current page, selection, focus, scroll, source identity and request counts remain unchanged. It must not bubble into a body click, checkbox toggle, author-shelf reorder, or duplicate route. Preserve id/sourceKey/title/hero and existing multi-select drag, menu, keyboard, Escape-cancel, checkbox, menu and author-handle precedence. Use production widgets and real pointer events; callback-only tests are insufficient. If the current Wayland/X11 environment cannot safely provide a real GUI, record the block without using the old `:1` fixture display as owner evidence.

Protected: proposal/design/spec/design-spec, pubspec.lock, unrelated changes. No commit/archive/push until architect review and owner acceptance.
