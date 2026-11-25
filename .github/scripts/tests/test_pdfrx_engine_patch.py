import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "patch_pdfrx_engine.py"

PRISTINE = """void open(PdfFileCache? cache) {
  cache ??= makeCache();
  if (!cache.isInitialized) {
    cache.setBlockSize(blockSize);
  }
  return entryFunctions.openCustom(
    read: (buffer, position, size) async {
      final blockId = position ~/ cache!.blockSize;
      final isAvailable = cache.isCached(blockId);
      final readEnd = min(position + size, (blockId + 1) * cache.blockSize);
      await cache.read(buffer, 0, position, readEnd - position);
    },
    fileSize: cache.fileSize,
    onDispose: () {
      cache!.close();
    },
  );
}
"""


class PdfrxEnginePatchTests(unittest.TestCase):
    def make_cache(self, root: str, content: str = PRISTINE) -> Path:
        path = Path(root) / (
            "hosted/pub.dev/pdfrx_engine-0.4.5/lib/src/native/pdf_file_cache.dart"
        )
        path.parent.mkdir(parents=True)
        path.write_text(content, encoding="utf-8")
        return path

    def run_script(self, root: str) -> subprocess.CompletedProcess[str]:
        env = dict(os.environ)
        env["PUB_CACHE"] = root
        env["HOME"] = str(Path(root) / "home")
        env.pop("LOCALAPPDATA", None)
        return subprocess.run(
            [sys.executable, str(SCRIPT)],
            env=env,
            capture_output=True,
            text=True,
            check=False,
        )

    def test_patches_known_accesses_and_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as root:
            path = self.make_cache(root)
            first = self.run_script(root)
            self.assertEqual(first.returncode, 0, first.stderr)
            text = path.read_text(encoding="utf-8")
            for expected in (
                "cache!.isCached(",
                "* cache!.blockSize)",
                "await cache!.read(",
                "fileSize: cache!.fileSize,",
            ):
                self.assertIn(expected, text)
            # Flow-promoted accesses outside the closure must stay untouched.
            self.assertIn("if (!cache.isInitialized)", text)
            self.assertIn("cache.setBlockSize(", text)
            second = self.run_script(root)
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertIn("already patched", second.stdout)

    def test_missing_package_fails_loudly(self) -> None:
        with tempfile.TemporaryDirectory() as root:
            result = self.run_script(root)
            self.assertEqual(result.returncode, 1)
            self.assertIn("not found", result.stderr)

    def test_unexpected_source_shape_fails_loudly(self) -> None:
        with tempfile.TemporaryDirectory() as root:
            changed = PRISTINE.replace(
                "await cache.read(", "await otherCache.read("
            )
            self.make_cache(root, changed)
            result = self.run_script(root)
            self.assertEqual(result.returncode, 1)
            self.assertIn("expected source pattern missing", result.stderr)


if __name__ == "__main__":
    unittest.main()
