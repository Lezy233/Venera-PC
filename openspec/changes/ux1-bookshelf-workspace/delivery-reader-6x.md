# Reader 6.x — 进行中

基准：`bccedcb2534b625b6413be8060a234a2929d8e1e`，`redesign-2026`；开局干净。未提交、归档或 push。5.5 GUI 缺口保留；本轮不执行7.x。

使用 diagnosing-bugs / tdd / ui-ux-pro-max，测试 seam 为生产 MainPage/WindowFrame/Reader 真实坐标及键盘事件。

## 可证伪假设与当前证据

1. 现有 fullscreen 仅 native window，不通知工作区：若成立，真实 Reader 无沉浸入口或切换后标签仍可命中。
2. 漫画边缘点击仍走翻页分支：若成立，同页连续边缘点击会改变页码而不是只切换工具。
3. 工具隐藏时进度整体移出视口：若成立，生产 ReaderProgressSlider 仍在树中但无法命中。
4. 章节现有 SideBarRoute 可能已经覆盖且支持 Escape：先真实测尺寸/逐级退出，不能静态认定需重写。
5. “闲置2秒”可能已无独立计时器：用实际打开工具等待3秒验证，不凭旧需求添加或删除计时器。

## 6.1 当前循环

命令（后续日志只改变重定向路径）：

```sh
env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub test/app_shell/workspace_reader_state_test.dart --plain-name 'real reader stays inside its tab and pauses background work while retaining its exact page' --reporter expanded
```

- `/tmp/ux1-reader-61-red.log`：0通过/1失败/0skip，正常初始化并读至第2页后缺少 Enter immersive reading 真实控件。
- `/tmp/ux1-reader-61-green-loop.log`：0/1/0；沉浸行为断言已过，恢复后原本有两个 Toggle bookshelf（标题栏/工具栏），测试错误要求唯一。
- `/tmp/ux1-reader-61-green-loop-2.log`：1/0/0。保留沉浸时零命中、恢复时可达；Reader/画布/标签身份、章节页码、一次章节请求及既有后台休眠恢复断言全部通过。
- SDK sandbox 只读退出发生于测试初始化前，单列环境失败，窄权限运行解决；不计产品红灯。
- 日志中既有 flutter_memory_info MissingPlugin 为可处理缓存尺寸日志，未充当产品红灯；测试异常零断言保留。

实现暂为 ReaderShellData/当前标签 DesktopReaderActions 传递 immersive，显示工具入口，沉浸隐藏标签和书架 chrome，复用原 native fullscreen/background window 生命周期。尚待相关保护及完整6.1检查，不勾任务。

## 未完成与环境

6.2真实同一 Reader 隐藏进度/边缘连续点击测试运行中，原始日志 `/tmp/ux1-reader-62-red.log`；尚未实现。
6.3–6.5未完成；analyze未跑，正常main未重新构建，尚无最终SHA。
只读GUI preflight：DISPLAY=:2、WAYLAND_DISPLAY=wayland-1、GDK_BACKEND=wayland,x11、XDG_SESSION_TYPE=wayland；有xprop/grim，无wtype/ydotool。没有启动任何fixture或GUI输入；不沿用旧:1，不把测试帧当宿主截图。

## 当前 checkpoint（2026-11-18）

定向 6.2/6.3 复核为 14/0/0：`/tmp/ux1-reader-14-recheck-2.log`，包含进度键盘、菜单焦点、评论发送与真实退出等待、收藏真实请求和 native fullscreen 恢复。HEAD 副本对照为 273/0/23：`/tmp/ux1-reader-head-b3-f9-b5.log`；23 项均为既有 `skip: !Platform.isWindows` 场景。工作区首轮完整保护的 259/14/23 保留在 `/tmp/ux1-reader-b3-f9-b5-protection.log`，14 项失败未删除退出、存储、实体或请求断言。

视觉/布局保护 7/0/0：`/tmp/ux1-reader-64-visual-protection.log`，覆盖 ReaderMode title-bar 避让。GUI 尚未执行，6.5 未完成。当前 analyze raw 51；唯一项目项为既有 `test/features/favorites/folder_order_ownership_test.dart:144:50 return_of_invalid_type`，其余为原 tool/code-audit 基线；需按历史50逐条比对，不清零。`git diff --check` 与 OpenSpec validate 已通过；正常 main 尚未重新构建。

当前生产改动集中在 Reader shell、workspace chrome、gesture、progress 与 reader state；测试包含 workspace reader state、gesture/bottom actions、reader exit 语义迁移。无 GUI helper/harness 改动或启动。6.4 的手动减少动画读取既有 `AppearancePreferences.reduceMotion`，与系统 `disableAnimations` 取 OR；未增加服务或依赖。

## 6.6–6.7 增量 checkpoint

6.6 真实 `ReaderQuickSettingsPanel` 方案选择红灯命令已运行：
`test/features/reader/quick_settings_panel_test.dart --plain-name 'preset selection survives quick panel close and disk reload'`，日志 `/tmp/ux1-reader-66-red.log`。选择后等待 `SettingsSaveState.waitForSettingsSave()` 超过有界时间（约33秒）未收敛，停止自身测试；记录为真实保存等待/fixture writer 阻塞，未将初始化异常冒称产品绿灯。6.6 未实现、未勾，保留既有 B3/F9 保护与失败恢复断言。

历史6.7局部红→绿（后被用户复验否决）：`/tmp/ux1-reader-67-green.log` 1/0/0；`/tmp/ux1-reader-67-protection-final.log` 18/0/0。该证据只覆盖底栏自身，不证明 scaffold 内容保留区域。

用户复验后该项重新打开：`/tmp/ux1-reader-67-layout-red.log`（workspace真实场景在自动阅读恢复的 `pumpAndSettle` timeout，未删弱断言）。生产修复已移除精简态 BlurEffect/容器边框与背景，并把精简底栏作为 scaffold body 的保留布局区域；`/tmp/ux1-reader-67-layout-protection.log` 为18/0/0。新增无 BlurEffect、无章节按钮和窄线断言尚待 workspace timeout 根因复验；6.7 当前未勾。

本轮 A/B 修复：精简布局槽保持与完整态相同的 105px 基准，ReaderProgressSlider 保留 48px 可访问/可拖动命中区，轨道视觉高度降为3px，定位在槽底；精简态无 BlurEffect、背景或边框，上一章/下一章不渲染。独立控件 A 几何/命中/无模糊测试 `/tmp/ux1-reader-67-ab-green.log` 1/0/0。真实 workspace 内容 rect 对照 `/tmp/ux1-reader-67-ab-workspace.log` 仍在自动阅读恢复处 timeout，未冒称 B 通过；需继续定位该既有异步等待后才能勾6.7。

本增量未修改受保护契约、依赖或 lock；尚未重新构建正常 main。analyze 仍沿用上一 checkpoint 51项，需最终独立复核后再刷新具体集合。
