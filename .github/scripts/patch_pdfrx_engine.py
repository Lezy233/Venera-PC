#!/usr/bin/env python3
"""Apply the documented null-safety hot patch to pdfrx_engine 0.4.5.

The pinned ``pdfrx_engine`` 0.4.5 loses Dart flow promotion inside the
``openCustom`` closure, so four accesses on the nullable ``cache`` parameter
fail to compile in a clean pub cache. The project has always applied this fix
to its local pub cache; CI must apply the same deterministic patch after
``flutter pub get`` or every job that compiles the app (tests, Windows smoke,
desktop builds) fails.

Only the four known accesses are rewritten. The script is idempotent and
fails loudly when the pinned package is missing or the expected source shape
changed, so a silent regression cannot hide behind the patch.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

VERSION = "0.4.5"
RELATIVE = (
    Path("hosted/pub.dev")
    / f"pdfrx_engine-{VERSION}"
    / "lib/src/native/pdf_file_cache.dart"
)
REPLACEMENTS = (
    ("cache.isCached(", "cache!.isCached("),
    ("* cache.blockSize)", "* cache!.blockSize)"),
    ("await cache.read(", "await cache!.read("),
    ("fileSize: cache.fileSize,", "fileSize: cache!.fileSize,"),
)


def pub_cache_roots() -> list[Path]:
    roots: list[Path] = []
    configured = os.environ.get("PUB_CACHE")
    if configured:
        roots.append(Path(configured))
    roots.append(Path.home() / ".pub-cache")
    local_app_data = os.environ.get("LOCALAPPDATA")
    if local_app_data:
        roots.append(Path(local_app_data) / "Pub" / "Cache")
    return roots


def find_source() -> Path | None:
    for root in pub_cache_roots():
        candidate = root / RELATIVE
        if candidate.is_file():
            return candidate
    return None


def main() -> int:
    source = find_source()
    if source is None:
        print(
            f"pdfrx_engine {VERSION} not found in the pub cache; "
            "run flutter pub get before this script",
            file=sys.stderr,
        )
        return 1

    text = source.read_text(encoding="utf-8")
    changed = 0
    for old, new in REPLACEMENTS:
        if new in text:
            continue
        if old not in text:
            print(
                f"pdfrx_engine {VERSION}: expected source pattern missing: {old!r}",
                file=sys.stderr,
            )
            return 1
        text = text.replace(old, new, 1)
        changed += 1

    if changed:
        source.write_text(text, encoding="utf-8")
        print(f"pdfrx_engine {VERSION}: patched {changed} access(es) in {source}")
    else:
        print(f"pdfrx_engine {VERSION}: already patched ({source})")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
