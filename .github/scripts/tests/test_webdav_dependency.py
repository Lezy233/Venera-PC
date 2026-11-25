import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[3]
PUBSPEC = ROOT / "pubspec.yaml"
PUBSPEC_LOCK = ROOT / "pubspec.lock"
PACKAGE = ROOT / "packages" / "webdav_client"
SOURCE_COMMIT = "2f669c98fb81cff1c64fee93466a1475c77e4273"


class WebDavClientProvisioningTests(unittest.TestCase):
    def test_root_dependency_is_a_local_path(self):
        data = yaml.safe_load(PUBSPEC.read_text(encoding="utf-8"))
        dependency = data["dependencies"]["webdav_client"]
        self.assertEqual(dependency, {"path": "packages/webdav_client"})
        self.assertNotIn("git", dependency)

    def test_lockfile_pins_local_source_and_version(self):
        lock = yaml.safe_load(PUBSPEC_LOCK.read_text(encoding="utf-8"))
        entry = lock["packages"]["webdav_client"]
        self.assertEqual(entry["dependency"], "direct main")
        self.assertEqual(entry["source"], "path")
        self.assertEqual(entry["version"], "1.2.2")
        self.assertEqual(
            entry["description"],
            {"path": "packages/webdav_client", "relative": True},
        )

    def test_vendored_package_is_complete_and_licensed(self):
        pubspec = yaml.safe_load(
            (PACKAGE / "pubspec.yaml").read_text(encoding="utf-8")
        )
        self.assertEqual(pubspec["name"], "webdav_client")
        self.assertEqual(pubspec["version"], "1.2.2")
        self.assertTrue((PACKAGE / "lib" / "webdav_client.dart").is_file())
        license_text = (PACKAGE / "LICENSE").read_text(encoding="utf-8")
        self.assertIn("BSD 3-Clause License", license_text)
        for excluded in ("example", "images", "test", ".git"):
            self.assertFalse(
                (PACKAGE / excluded).exists(),
                f"vendored package must not include {excluded}",
            )
        provenance = (PACKAGE / "PROVENANCE.md").read_text(encoding="utf-8")
        self.assertIn(SOURCE_COMMIT, provenance)


class GitDependencySourceTests(unittest.TestCase):
    """The pinned git dependencies must resolve from a reachable public repo."""

    def test_dead_repositories_are_not_referenced(self):
        pubspec = PUBSPEC.read_text(encoding="utf-8")
        self.assertNotIn("github.com/CyrilPeng/webdav_client", pubspec)
        self.assertNotIn("github.com/CyrilPeng/flutter.widgets", pubspec)
        self.assertNotIn(
            "github.com/CyrilPeng/flutter_inappwebview", pubspec
        )

    def test_mirrored_sources_keep_the_locked_commits(self):
        data = yaml.safe_load(PUBSPEC.read_text(encoding="utf-8"))
        lock = yaml.safe_load(PUBSPEC_LOCK.read_text(encoding="utf-8"))
        expected = {
            "scrollable_positioned_list": (
                "https://github.com/venera-app/flutter.widgets",
                "09e756b1f1b04e6298318d99ec20a787fb360f59",
                "packages/scrollable_positioned_list",
            ),
            "flutter_inappwebview": (
                "https://github.com/venera-app/flutter_inappwebview",
                "3ef899b3db57c911b080979f1392253b835f98ab",
                "flutter_inappwebview",
            ),
        }
        for name, (url, ref, path) in expected.items():
            git = data["dependencies"][name]["git"]
            self.assertEqual(git["url"], url)
            self.assertEqual(git["ref"], ref)
            self.assertEqual(git["path"], path)
            entry = lock["packages"][name]
            self.assertEqual(entry["source"], "git")
            self.assertEqual(entry["description"]["url"], url)
            self.assertEqual(entry["description"]["resolved-ref"], ref)


if __name__ == "__main__":
    unittest.main()
