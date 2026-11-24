# Provenance

This directory vendors the `webdav_client` package instead of resolving it
from a Git dependency, so clean environments do not depend on a remote
repository remaining available.

- Upstream project: `flymzero/webdav_client` (previously resolved through
  `https://github.com/CyrilPeng/webdav_client`)
- Source commit: `2f669c98fb81cff1c64fee93466a1475c77e4273`
  (`Support multiple authentication method.`, 2025-03-17)
- Package version: `1.2.2`
- License: BSD 3-Clause, see `LICENSE`
- Vendored on: 2026-11-24

## Included files

Copied verbatim from the pub cache checkout of the commit above:

- `lib/` (runtime code)
- `pubspec.yaml`
- `README.md`
- `CHANGELOG.md`
- `LICENSE`

Every copied file was compared byte-for-byte against the cached checkout with
`diff -r` and `sha256sum` before being committed.

## Excluded files

- `.git/` and VCS metadata
- `example/` (sample application)
- `images/` (README screenshots)
- `test/` (tests require a live WebDAV server)
- `.metadata`, `.gitignore`

## Updating

Dependency updates are a separate, reviewable change. Do not regenerate the
root `pubspec.lock`; re-vendor a newer upstream commit here and update the
root path dependency plus the lock file entry deliberately.
