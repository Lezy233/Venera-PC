# F2隔离GUI证据（普通网格阶段）

全部截图/数据仅/tmp/ux1-f2-captures，未入库。工具全文已由architect核准：harness `8b9a04d2fbe7a5a35c4fd359317d1a593ed9fc8e3fb09a1f1bdf96761f512911`，helper `fa9ee5fc037cd08b0bb56a9c7739e8b527e40ed968850177ba7cd65196cc883a`，过程未改工具或生产源码。清单batch-3-progress-gui.sha256包含工具、实际JSON/图片、构建/运行日志与kernel。

生产bootstrap/MyApp，DISPLAY=:1/GDK_BACKEND=x11、固定F2 marker/title/完整exe/arg及四XDG隔离；业务/cache位于/tmp/ux1-f2-xdg-data与cache下。首seed60收藏及已解码本地受控PNG，不代表外部真实站点/封面资源；未直接写选集/scroll/工作区现场。所有业务状态由实际键鼠建立，F6只读/截图。每次helper重验PID/exe/env/arg/xprop/focus/window/root，不操作其他窗口。

| 场景/稳定截图 | 对应F6 JSON（同名rich图片为完整Flutter帧） | 实际事实 |
|---|---|---|
| selected-scrolled.png | rich-487144-1 | 真滚轮164.325px、真实Checkbox book-3/book-4两选，焦点1012199551 |
| preview-dark-medium.png | rich-487144-2 | Space预览book-4概览/目录，1tab，单次book-4请求，scale1/system false |
| 方向键Right→Escape | rich-487144-3 | book-5新增一次必要详情后关闭，原focus1012199551、页面367469035、滚动控制器898127722和offset/两选保持 |
| drag-cancel-live.png | rich-487144-4 | 真鼠标拖动中Escape移除反馈，仍1tab，选集/现场不清 |
| drag-drop-live.png、drag-drop-result.png | rich-487144-5 | 真drop至标签栏恰新增book-3/book-4两后台，准确source=ux1-fixture；active/recent不变，未新增详情请求 |
| preview-compact-dark.png | rich-487144-6 | 600×700固定关闭/底部操作可见 |
| 预览Enter→AltLeft | rich-487144-7/8 | 当前tab栈加一次comic，返回原页/原focus，标签不关闭；预览必要请求与打开完整详情各自记录，不声称跨用途去重 |
| preview-light-cn150-system.png | rich-801876-1 | 真生产设置浅色/简体，实际previewMedia scale1.5/system true；正文超高可滚动 |
| preview-compact-cn150-scrolled.png | rich-801876-2 | 600×700滚动正文，关闭及底部操作始终可见 |
| preview-expanded-cn150-window.png | rich-801876-3 | 实际1400×760；窗口截图只有1060×740，**是宿主裁截**。rich完整Flutter帧1400×760，不能称完整X11宿主帧；鼠标仅可达区域 |
| preview-dark-tw150-system.png | rich-801876-4 | 真生产设置深色/繁体，scale1.5/system true |
| preview-compact-tw150-system.png | rich-801876-5 | 600×700深繁150%、真实正文滚轮到章节，关闭常驻 |
| appearance-tw150.png、preview-tw150-manual-only.png | rich-809100-1 | 真Appearance开关保存后重启复用，磁盘reduceMotion=true；系统开关独立关闭，实际previewMedia scale1.5/system false |

系统reduceMotion与scale由已核准临时MediaQuery注入；以F6实际读取值证明已作用到预览，**不是OS设置入口操作**。手动Reduce motion/语言/主题均真实生产设置控件操作，独立四组合动画时序及可靠保存/重载由生产控件测试补证。生产主题动态色保持真实MyApp初始化；未替换ThemeData视觉系统。

PID487144/801876/809100均通过正常窗口关闭exit0，未用kill/XKillClient。日志分别/tmp/ux1-b3-gui-a/b/c.log；启动前实际physicalSize900×600、1000×700、1000×700，均非1×1。只有GTK Atk/MESA与resize OpenGL旧帧尺寸警告，未发现新增Flutter异常/overflow。宿主升级权限ps三PID无记录、xwininfo固定F2标题零窗口，helper最后identify found0。截图/data/cache保留审计，不留运行fixture。

正常main恢复构建成功：/tmp/ux1-b3-main-build.log；正常kernel `83d1c7a56f9f8f9268d05dd9066490762eb21a8463e89436c3fa31061528b1c4`与f9bb3e…/app.dill匹配，depfile包含lib/main.dart。GUI harness缓存kernel `99b061da92fe564dcf02014748b9465b7edfb8d9181c5add5b1805458fc97cc9`，619daf6e…depfile入口/tmp/ux1_f2_gui.dart。GUI时的宿主exe未单独预留哈希，不把正常main构建后的kernel充当GUI kernel。

作者栏选集拖出/长按重排划分仍待owner；本页仅证明普通网格与预览，不宣称完整4.4/4.5或F2最终验收。

## 4.3主体依赖后有界增量（最新源码）

旧PID487144/801876/809100图组是主体绑定修改前的局部预览/拖放证据；旧清单保留batch-3-pre-body-gui.sha256，缓存kernel项会因后续构建覆盖，不称该旧清单继续全MATCH。当前18生产/30测试SHA清单对应新主体源码；工具仍为原核准SHA，未更改。

PID836728，日志/tmp/ux1-b3-body-gui.log。使用真实生产本机收藏设置将原“点击收藏”选read；没有改名或另加偏好。1200×700显示可见SearchPage自己的搜索框，真实输入Alpha/Return提交，来源收到[Alpha,1,[normal]]一次。此前误点“搜索于”目标栏及壳层搜索框没有提交来源请求，仅是取证定位错误，未算产品红灯/通过，未改搜索代码。

真实结果卡book-0 hover→checkbox选择→F6-1（body-before-read.png）→点标题。F6-2/body-reader-real.png显示实际Reader id=book-0/source=ux1-fixture/chapter1/page1，已解码本地PNG“UX1 PAGE 1”；reader state736847454。实际Alt+Left→F6-3/body-read-return.png，原checkbox仍checked；原focus323739778返回一致，各scrollState身份及offset列表与F6-1逐项相等。全程active tab/recent及标签数3保持，原结果页路由恢复。source搜索一次、详情一次、chapter ep-1一次，返回后不重发。F6未记录SearchResultPage State身份，不借旧favoritesState冒称结果页State；该项由真实控件测试同State断言补证。

三次完整Flutter帧为rich-836728-1/2/3.png及同名JSON，1200×700。宿主窗口截图右侧受root边界裁截，不作全X11完整帧；实际点击始终在可达区域。此增量仅单源生产read/返回一次，聚合/键盘及viewDetail用真实控件测试，不冒称全部GUI矩阵重跑。图像为已解码受控本地PNG，外部站点仍未验证。

fixture构建/tmp/ux1-b3-body-gui-build.log成功，操作前保存/tmp/ux1-b3-body-fixture-binary.sha256：kernel525a84448da9e2441141d3eced1d6895c6b5244ea87f6b9b02030f6567f3b700，与当前619daf6e…harness缓存app.dill匹配。结束正常窗口关闭exit0；升级权限ps PID836728不存在，固定title X11窗口零残留。没有kill/修改工具边界。

正常main再次恢复构建/tmp/ux1-b3-body-main-build.log成功；当前bundle kernel7d0b8074e134f720d030c7c96a97ba00b77d7dcebc2f216f8d1c0e7de35585b4，与f9bb3e…正常app.dill一致。main/runner未改，当前无运行fixture。GTK Atk初始化警告单列；本次运行日志无新增Flutter异常/overflow。
## 作者栏独立手柄：最终新增 GUI（2026-11-17）

本段覆盖此前等待owner段；owner已选独立手柄，卡片原长按排序保留。工具未改：harness8b9a04d2…、helperfa9ee5fc…。实际新PID1102014，固定title/完整exe/marker/参数/四XDG/:1 x11逐次identify通过；premount及实际窗口1000×700、原点20,20，完整宿主帧无裁截。业务目录沿用本轮已隔离fixture，没有重建业务或写选择/offset；生产启动恢复旧搜索，真实点击收藏→右侧筛选→排序“按作者分栏”→收起筛选→两张checkbox建立选择。

| 稳定图（均位于 /tmp/ux1-f2-captures/） | 对应只读现场 | 真实动作/观察 |
|---|---|---|
| author-empty-handle-1102014.png | 生产作者栏 | 标题区可见手柄，空选集禁用，与卡片右上checkbox/下方排序菜单物理分开 |
| author-selected-before-1102014.png | rich-1102014-1.json/.png | 真实checkbox选book0/book1；原3标签；焦点668761396，页面753090468 |
| author-cancel-stable-1102014.png | rich-1102014-2.json/.png | 手柄root954,226→620,130，中途Escape，仍3标签，两卡/焦点/各scrollState及offset保持 |
| author-drop-stable-1102014.png | rich-1102014-3.json/.png | 同手柄实际drop，3→5，仅新增book0/book1，source=ux1-fixture；active/recent不变，details/chapter均空，旧搜索只启动一次 |

author-cancel-live/drop-live图是拖动中间帧，不能冒充稳定结果。其余start/favorites/filter/menu/hover图仅输入定位过程。/tmp/ux1-b3-author-handle-gui-comparison.json逐项比较三份真实State/请求数据并assert通过；architect已独立view_image两稳定图及联查1/2/3通过，无需重复GUI。所有素材受控本地PNG、单作者单来源；本GUIoffset为0，不冒称非零滚动。跨栏同实体/同ID异来源、三态原长按独立排序及三宽150%由生产控件新增3测试验证；既有普通网格非零滚动/预览完整矩阵另列，不以本图代替。

本次fixture kernel ecf2a509456c349f1af41a3dc986db47edde5a6b4eba9eef4450378418ca5593，见/tmp/ux1-b3-author-handle-fixture-binary.sha256；GUI构建/runtime日志同前缀。GTK Atk/DRI启动警告单列，无新增Flutter异常/overflow。正常窗口按钮关闭exit0，升级权限宿主ps精确1102014不存在、:1树仅qq/clipboard，无F2窗口；未杀其他程序。正常main构建/tmp/ux1-b3-author-handle-main-build.log成功，当前kernel与正常main app.dill均1f2eeebdb7ec768a0b1766056d04fb2a8b09a48295b238a6fc3762bfaa11518a；main depfile含lib/main.dart、不含ux1_f2_gui.dart。main/runner未改。

当前GUI/工具/证据清单119项全部MATCH。改前87项保留batch-3-pre-author-gui.sha256，其中harness缓存app.dill及bundle kernel因构建替换预期不匹配，不声明旧清单MATCH；旧15/29/65亦仅历史。
## 正常生产入口启动修复：覆盖此前只build恢复的不足

owner报告的无画面已在未经包装normal入口精确复现；旧F2 GUI harness预先初始化窗口，不能替代normal启动。当前新增/tmp/ux1-b3-normal-startup-order-green.png（同红灯目录PID1395945）与/tmp/ux1-b3-normal-startup-fresh-green.png（全新四XDG、最终main bundle、PID1403769）均为实际900×600+10+10完整窗口，已view_image并获architect独立核，无三条15px/1×1超时。未操作同名owner窗口1377349。首帧trace1×1→900×600对照仅诊断，包装Zone mismatch修前修后各1单列；normal无该异常。

本次仅main已授权两行交换await/runApp，不改runner。当前正常kernel4100dcba…与main入口匹配，fresh图即最终产物实际启动；自身五诊断PID已退出，owner同名窗口仍在。当前清单19/31/139独立MATCH，旧18/31/119保留pre-startup历史。命令、完整SHA与失败约束见batch-3-startup-diagnostics.md和delivery最新权威段。本次GUI不冒称owner原配置全部验收通过，等待owner重试。
