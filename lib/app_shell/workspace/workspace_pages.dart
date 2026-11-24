import 'package:venera_next/features/comic_details/cover_viewer.dart';
import 'package:flutter/widgets.dart';
import 'package:venera_next/app_shell/home_page.dart';
import 'package:venera_next/features/discovery/discovery.dart';
import 'package:venera_next/features/favorites/favorites.dart';
import 'package:venera_next/features/search/search.dart';
import 'package:venera_next/features/comic_details/comic_details.dart';
import 'package:venera_next/features/reader/reader.dart';
import 'package:venera_next/features/settings/settings.dart';
import 'package:venera_next/foundation/workspace_record.dart';

/// Explicit auxiliary allowlist; unknown main pages are not silently made
/// eligible for parent-only restoration.
bool isWorkspaceAuxiliaryPage(Widget page) => page is ComicCoverViewer;

/// Constructors only. Describing a widget must not mount it or issue a request.
WorkspaceRouteRecord? describeWorkspacePage(Widget page) {
  if (page is HomePage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.home);
  }
  if (page is FavoritesPage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.favorites);
  }
  if (page is ExplorePage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.explore);
  }
  if (page is CategoriesPage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.categories);
  }
  if (page is SearchPage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.search);
  }
  if (page is SettingsPage) {
    return WorkspaceRouteRecord(kind: WorkspacePageKind.settings);
  }
  if (page is SearchResultPage) {
    return WorkspaceRouteRecord(
      kind: WorkspacePageKind.searchResults,
      arguments: {
        'keyword': page.text,
        'sourceKey': page.sourceKey,
        'options': page.options,
      },
    );
  }
  if (page is AggregatedSearchPage) {
    return WorkspaceRouteRecord(
      kind: WorkspacePageKind.aggregatedSearch,
      arguments: {'keyword': page.keyword, 'profileId': page.profileId},
    );
  }
  if (page is ComicPage) {
    return WorkspaceRouteRecord(
      kind: WorkspacePageKind.comic,
      arguments: {
        'id': page.id,
        'sourceKey': page.sourceKey,
        'cover': page.cover,
        'title': page.title,
      },
    );
  }
  if (page is Reader) {
    return WorkspaceRouteRecord(
      kind: WorkspacePageKind.reader,
      arguments: {
        'id': page.cid,
        'sourceKey': page.type.sourceKey,
        'title': page.name,
        'chapter': page.initialChapter,
        'page': page.initialPage,
      },
    );
  }
  if (page is ReaderWithLoading) {
    return WorkspaceRouteRecord(
      kind: WorkspacePageKind.reader,
      arguments: {
        'id': page.id,
        'sourceKey': page.sourceKey,
        'title': page.title,
        'chapter': page.initialEp,
        'page': page.initialPage,
      },
    );
  }
  return null;
}

Widget buildWorkspacePage(WorkspaceRouteRecord record) {
  final args = record.arguments;
  return switch (record.kind) {
    WorkspacePageKind.home => const HomePage(),
    WorkspacePageKind.favorites => const FavoritesPage(),
    WorkspacePageKind.explore => const ExplorePage(),
    WorkspacePageKind.categories => const CategoriesPage(),
    WorkspacePageKind.search => const SearchPage(),
    WorkspacePageKind.settings => const SettingsPage(),
    WorkspacePageKind.searchResults => SearchResultPage(
      text: args['keyword'] as String,
      sourceKey: args['sourceKey'] as String,
      options: (args['options'] as List?)?.cast<String>(),
    ),
    WorkspacePageKind.aggregatedSearch => AggregatedSearchPage(
      keyword: args['keyword'] as String,
      profileId: args['profileId'] as String?,
    ),
    WorkspacePageKind.comic => ComicPage(
      id: args['id'] as String,
      sourceKey: args['sourceKey'] as String,
      cover: args['cover'] as String?,
      title: args['title'] as String?,
    ),
    WorkspacePageKind.reader => ReaderWithLoading(
      id: args['id'] as String,
      sourceKey: args['sourceKey'] as String,
      title: args['title'] as String?,
      initialEp: args['chapter'] as int?,
      initialPage: args['page'] as int?,
    ),
  };
}
