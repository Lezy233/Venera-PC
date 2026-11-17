# 1.3 尚未实施阶段的可重放生产诊断

这些预期失败只在/tmp运行，不加入常规suite、不加skip，不授权5.x/6.x实现。运行环境为派工指定env代理与LD_LIBRARY_PATH，fvm flutter test --no-pub。

## 5.1 实际搜索主体偏好失配

将下列源码保存为/tmp/ux1_b3_click_baseline_test.dart，然后运行：
`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub /tmp/ux1_b3_click_baseline_test.dart --reporter expanded`

/tmp/ux1-b3-global-click-red.log：0通过2失败0skip；初始化零异常，真实来源请求Alpha/1/[]及可见作品均先通过；实际点生产SearchResultPage或AggregatedSearchPage作品文字，准确一次路由为ComicPage且实体book-a/click-baseline，D4 read设置要求ReaderWithLoading。收藏对照由本阶段B4真实read/viewDetail控件保护通过；本轮不统一非收藏列表设置。

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/features/comic_widgets/comic_widgets.dart';
import 'package:venera_next/features/comic_source/comic_source.dart';
import 'package:venera_next/features/reader/reader.dart';
import 'package:venera_next/features/search/search_result_page.dart';
import 'package:venera_next/features/search/aggregated_search_page.dart';
import 'package:venera_next/foundation/app.dart';
import 'package:venera_next/foundation/appdata.dart';
import 'package:venera_next/foundation/app_page_route.dart';
import 'package:venera_next/foundation/res.dart';
import 'package:venera_next/routing/app_navigation.dart';
import 'file:///home/_Le/Code/Projects/Venera-Next/test/support/comic_source_fixture.dart';

class Source extends ComicSourceFixture {
  Source():super(key:'click-baseline');
  final calls = <Object>[];
  @override
  SearchPageData get searchPageData => SearchPageData([], (keyword,page,options) async {
    calls.add([keyword,page,List.of(options)]);
    return Res([const Comic('Actual result card', '', 'book-a', null, null, '', 'click-baseline', null, null)], subData:1);
  }, null);
}
class Routes extends NavigatorObserver {
  final pages = <AppPageRoute>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if(route is AppPageRoute) pages.add(route);
  }
}
void main() {
  App.dataPath=App.cachePath=Directory.systemTemp.path;
  for(final aggregate in [false,true]) {
    testWidgets('5.1 production ${aggregate?'aggregate':'single-source'} body must honor read preference', (tester) async {
      final source=Source(), routes=Routes();
      final previous=Map<String,dynamic>.from(appdata.toJson()['settings'] as Map);
      final navigator=appNavigation.rootNavigatorKey, previousMain=appNavigation.mainNavigatorKey;
      appNavigation.mainNavigatorKey=navigator;
      appdata.settings['language']='en-US';
      appdata.settings['onClickFavorite']='read';
      appdata.settings['comicDisplayMode']='gallery';
      appdata.settings['blockedWords']=<String>[];
      appdata.settings['searchSources']=[source.key];
      appdata.settings['autoAddLanguageFilter']='none';
      configureComicSourceRegistry(all:()=>[source],find:(key)=>key==source.key?source:null,fromIntKey:(_)=>source,isEmpty:()=>false);
      configureComicWidgets(comicPageBuilder:({required id, required sourceKey,cover,title,heroID})=>ComicPage(id:id,sourceKey:sourceKey,cover:cover,title:title,heroID:heroID));
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        configureComicWidgets();
        configureComicSourceRegistry(all:()=>[],find:(_)=>null,fromIntKey:(_)=>null,isEmpty:()=>true);
        appNavigation.mainNavigatorKey=previousMain;
        previous.forEach((k,v)=>appdata.settings[k]=v);
      });
      await tester.pumpWidget(MaterialApp(navigatorKey:navigator,navigatorObservers:[routes],home:Scaffold(body:
        aggregate ? const AggregatedSearchPage(keyword:'Alpha') : SearchResultPage(text:'Alpha',sourceKey:source.key))));
      await tester.pumpAndSettle();
      expect(tester.takeException(),isNull,reason:'initialization is not product red');
      expect(find.text('Actual result card'),findsOneWidget);
      expect(source.calls,[['Alpha',1,[]]]);
      await tester.tapAt(tester.getCenter(find.text('Actual result card')));
      expect(routes.pages,hasLength(1));
      final destination=routes.pages.single.builder(navigator.currentContext!);
      if(destination is ComicPage) expect((destination.id,destination.sourceKey),('book-a',source.key));
      expect(destination,isA<ReaderWithLoading>(),reason:'D4 global read preference must apply to actual search/aggregate body');
    });
  }
}

```

## 6.2 生产Reader单进度/漫画区域单击

先`cp test/features/reader/slider_navigation_test.dart /tmp/ux1_b3_reader_baseline_test.dart`，再应用下列精确差异（只改/tmp副本），然后运行：
`env https_proxy=http://127.0.0.1:7897 http_proxy=http://127.0.0.1:7897 LD_LIBRARY_PATH=/home/_Le/Code/Projects/Venera-Next/build/linux/x64/debug/bundle/lib fvm flutter test --no-pub /tmp/ux1_b3_reader_baseline_test.dart --reporter expanded`

/tmp/ux1-b3-reader-final-baseline.log：1通过2失败0skip。沿用已正常初始化的生产Reader、实际300张本地PNG与原platform effects fixture；没有调用openOrClose或slider回调建场。中部(400,300)两次真实单击：工具开时Slider可命中1、工具关闭后为0，要求持续唯一可用进度而失败。既有点击翻页开启时下部(700,500)真实单击未打开工具（实际翻页路径），要求D8任意位置切工具而失败。独立Reader brightness按钮真实单击保持工具展开和原页码通过，不冒称这部分缺失。此前(700,300)位于垂直阅读中区的单击对照为绿；纠正下部坐标才构成缺失边界，保留旧日志，不将坐标探索算新增红灯。

```diff
--- test/features/reader/slider_navigation_test.dart	2026-10-21 11:59:48.187522276 +0800
+++ /tmp/ux1_b3_reader_baseline_test.dart	2026-11-16 20:04:54.069983647 +0800
@@ -23,8 +23,8 @@
 import 'package:venera_next/foundation/log.dart';
-
+
 void main() {
-  for (final rapid in [false, true]) {
-    testWidgets('300-page slider jump preserves touch scrolling (rapid=$rapid)', (
+  for (final scenario in ['progress', 'comicTap', 'independent']) {
+    testWidgets('6.2 real Reader baseline $scenario', (
       tester,
     ) async {
       final previous =
@@ -47,6 +47,7 @@
         settings['autoReaderMode'] = false;
         settings['readerMode'] = 'continuousTopToBottom';
         settings['enablePageAnimation'] = true;
+        settings['enableTapToTurnPages'] = scenario == 'comicTap';
         settings['enableClockAndBatteryInfoInReader'] = false;
         settings['showPageNumberInReader'] = false;
         settings['eInkMode'] = false;
@@ -114,28 +115,35 @@
         final scaffold = tester.state<ReaderScaffoldState>(
           find.byType(ReaderScaffold),
         );
-        scaffold.openOrClose();
-        await frames(15);
-        final slider = tester.widget<Slider>(find.byType(Slider).first);
-        // A slider can emit multiple destination changes before the next frame,
-        // while the positioned list has not mounted its transition list yet.
-        if (rapid) slider.onChanged!(150);
-        slider.onChanged!(200);
-        await frames(50);
-        expect(reader.isPageAnimating, isFalse);
-        expect(reader.page, 200);
-        scaffold.openOrClose();
-        await frames(15);
-        final flow = reader.imageViewController as ContinuousModeState;
-        final before = flow.scrollController.offset;
-        await tester.dragFrom(const Offset(400, 400), const Offset(0, -220));
-        await frames(15);
-        expect(flow.scrollController.offset, greaterThan(before + 50));
-        final after = flow.scrollController.offset;
-        await tester.dragFrom(const Offset(400, 150), const Offset(0, 220));
-        await frames(15);
-        expect(flow.scrollController.offset, lessThan(after - 50));
         expect(tester.takeException(), isNull);
+        expect(scaffold.isOpen,isFalse);
+        final pageBefore = reader.page;
+        if(scenario == 'progress') {
+          await tester.tapAt(const Offset(400,300)); await frames(20);
+          expect(scaffold.isOpen,isTrue);
+          expect(find.byType(Slider).hitTestable(),findsOneWidget);
+          await tester.tapAt(const Offset(400,300)); await frames(20);
+          expect(scaffold.isOpen,isFalse);
+          expect(reader.page,pageBefore);
+          expect(find.byType(Slider).hitTestable(),findsOneWidget,
+            reason:'D8 requires one usable progress control while tools are hidden');
+        } else if(scenario == 'comicTap') {
+          await tester.tapAt(const Offset(700, 500));
+          await frames(20);
+          expect(scaffold.isOpen,isTrue,reason:'D8 arbitrary comic position single tap opens tools');
+          expect(reader.page,pageBefore,reason:'tool toggle must not navigate pages');
+          await tester.tapAt(const Offset(700,500)); await frames(20);
+          expect(scaffold.isOpen,isFalse);
+          expect(reader.page,pageBefore);
+        } else {
+          await tester.tapAt(const Offset(400,300)); await frames(20);
+          expect(scaffold.isOpen,isTrue);
+          final brightness=find.byTooltip('Reader brightness').hitTestable();
+          expect(brightness,findsOneWidget);
+          await tester.tapAt(tester.getCenter(brightness)); await frames(15);
+          expect(scaffold.isOpen,isTrue,reason:'independent tool must not bubble into comic toggle');
+          expect(reader.page,pageBefore);
+        }
       } finally {
         await tester.pumpWidget(const SizedBox.shrink());
         await tester.pump(const Duration(seconds: 3));

```


## 4.3必要依赖实施后的历史边界

以上单源/聚合read主体0/2红及源码完整保留为改前生产基线；不是当前源码仍失败的宣称。architect批准本批必要绑定后，默认ComicTile/SimpleComicTile已复用原onClickFavorite，新真实键鼠测试card_body_preference_test.dart以typed reader builder正确初始化，read/viewDetail、id/source/title、一次路由、挂载Loading、平台返回、选集及显式Details全部转绿，body-hit-protection共19/0/0。原/tmp诊断初始化只注入旧ComicPage builder，直接在新接口下重放须补reader builder；该初始化适配不抹去原产品红灯。Reader单进度/漫画单击两条6.2红灯仍仅历史诊断，未实现6.x；5.1默认布局/设置整项仍未做。
