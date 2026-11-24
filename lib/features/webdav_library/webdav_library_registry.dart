import 'package:venera_next/features/comic_source/comic_source_api.dart';

import 'webdav_library_services.dart';
import 'webdav_library_settings.dart';
import 'webdav_library_source.dart';

/// Application-owned registration of the WebDAV comic-library source.
///
/// The feature owns the registration rules and the owner record; the
/// application composition root decides which services instance is mounted and
/// keeps that instance alive. Lower modules call [mountWebDavLibrary] with the
/// services obtained from `WebDavLibraryScope` instead of reading the
/// application singleton.
final _registryOwners = Expando<WebDavLibrarySource>('WebDAV registry owner');

/// Replaces callbacks from a previous app mount with this owner's instance.
void mountWebDavLibrary(WebDavLibraryServices services) {
  if (services.source.isDisposed) return;
  adoptWebDavLibrarySource(ComicSourceManager(), services.source);
  registerWebDavLibrarySource(
    ComicSourceManager(),
    services.source,
    services.settings.read(),
  );
}

/// Records [manager] as the application owner of [source].
///
/// Called by the composition root when it creates the application services so
/// queued configuration writes can detect that their owner was replaced.
void adoptWebDavLibrarySource(
  ComicSourceManager manager,
  WebDavLibrarySource source,
) {
  _registryOwners[manager] = source;
}

/// Whether [source] is still the registration owner for [manager].
bool ownsWebDavLibrarySource(
  ComicSourceManager manager,
  WebDavLibrarySource source,
) {
  return identical(_registryOwners[manager], source);
}

/// Applies [settings] to the registry: exactly one adapter exists while the
/// purpose is enabled with a valid connection.
void registerWebDavLibrarySource(
  ComicSourceManager manager,
  WebDavLibrarySource source,
  WebDavLibrarySettings settings,
) {
  if (source.isDisposed) return;
  manager.remove(WebDavLibrarySource.sourceKey);
  if (settings.enabled && settings.connection.isValid) {
    manager.add(source.create());
  }
}
