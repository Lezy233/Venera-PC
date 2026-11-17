# UX1 1.3 与 F2 阶段归档

2026-11-17 owner在正常启动修复及实际显示路由排查后明确“验收通过，归档并提交”。本目录冻结已验收的1.3与4.1–4.5阶段证据，实现随本次提交保存；此次未授权推送。

本阶段完成Space临时预览、同组切换与原焦点恢复，Enter当前栈和Cmd/Ctrl后台详情，独立复选框、多选拖入标签栏及等价菜单/键盘入口。作者栏使用标题区独立手柄拖出选集，卡片原长按仍只重排本栏。默认漫画主体沿既有read/viewDetail设置，显式Details/预览提升保持详情语义，来源和实体准确一次，后台不提前请求详情。

验收补修：正常main原先先runApp后初始化窗口，首帧1×1引发right15两条/bottom15一条和原生绘制超时；仅交换现有placement.initialize与runApp顺序，同输入及全新目录正常启动均有900×600实际画面，首帧观察对照转绿。main此次为明确授权的两行非零diff，未将fixture接入正常入口，runner未改。随后owner仍看不到窗口，固定实际PID只读确认遗留DISPLAY=:1把程序送往Xvfb，而当时可见桌面Xwayland在:2；一次性恢复实际显示并移除测试XDG继承后owner验收通过。该显示号仅是当次证据，后续应读取实际会话，不能永久硬编码。未操作owner窗口、删除配置或升级依赖。

独立证据以review-batch-3.md为准：默认主体相关123通过/0skip，作者手柄及F10/F11保护60通过/0skip，启动宿主32通过/2个既有Windows专属skip；各集合重叠，不相加包装为一次全量。更早225通过/1失败及后续定向修正绿灯保留原始历史。最终analyze raw/unique50=38tool+12，具体集合added/removed为空。

最终19生产/31测试/139证据项SHA独立全MATCH；后续只读显示路由证据另列batch-3-display-routing.sha256，不冒称包含于旧139项。历史pre-body/pre-author/pre-startup清单仅作当时证据，其中被覆盖的可变构建产物不再宣称匹配。截图、日志、harness/helper和隔离数据仅保留/tmp，不提交图片。正常main产物恢复、自己五个诊断PID均已清理；owner进程不属于fixture清理范围。

上述全MATCH为独立复核当时事实。归档再核19生产/31测试仍全MATCH；后续正常flutter run后bundle kernel已被重写，139清单其余138项匹配，原kernel4100dcba…仍保留于正常main缓存app.dill。保留原清单不替换历史hash；当前bundle51202f80…不冒充重新执行GUI时的产物。

这是阶段证据归档，延续前一书架/F1阶段惯例，不是整个OpenSpec change归档。活动`openspec/changes/ux1-bookshelf-workspace/`仍是后续契约源，保留5.x搜索/详情、6.x阅读器、7.x整体验收全部未勾项；未运行整项archive，未把未实现delta合入正式spec。后续复用1.3诊断源码时读本目录batch-3-baseline-diagnostics.md，不把其历史红灯计为当前新增失败。

任务快照为tasks-snapshot.md；设计快照为proposal-snapshot.md、design-snapshot.md及specs-snapshot/，仅冻结本次契约，不代表其中所有未来需求已实现。
