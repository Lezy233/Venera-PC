import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
WORKFLOWS = ROOT / ".github/workflows"


class RepositoryUrlTests(unittest.TestCase):
    def test_pubspec_points_current_project_at_new_repository(self):
        pubspec = (ROOT / "pubspec.yaml").read_text(encoding="utf-8")
        self.assertIn("homepage: https://github.com/Lezy233/Venera-PC", pubspec)
        self.assertIn("url: https://github.com/Lezy233/Venera-PC", pubspec)
        # Third-party git dependencies keep their upstream sources.
        for dependency in (
            "CyrilPeng/flutter_qjs",
            "venera-app/flutter_desktop_webview",
        ):
            self.assertIn(dependency, pubspec)
        # The WebDAV client is vendored so clean environments do not depend on
        # the upstream repository staying reachable.
        self.assertIn("path: packages/webdav_client", pubspec)
        self.assertNotIn("CyrilPeng/webdav_client", pubspec)

    def test_workflows_reference_new_repository_and_asset_names(self):
        for workflow in ("main.yml", "winget.yml", "build.yml"):
            text = (WORKFLOWS / workflow).read_text(encoding="utf-8")
            self.assertNotIn("CyrilPeng/venera-next", text, workflow)
            self.assertNotIn("VeneraNext-", text, workflow)
        winget = (WORKFLOWS / "winget.yml").read_text(encoding="utf-8")
        self.assertIn("Lezy233/Venera-PC", winget)
        self.assertIn("VeneraPC-", winget)

    def test_sponsors_cdn_points_at_new_repository(self):
        loader = (ROOT / "lib/features/settings/sponsors_loader.dart").read_text(
            encoding="utf-8"
        )
        self.assertIn("cdn.jsdelivr.net/gh/Lezy233/Venera-PC@main", loader)
        self.assertIn("raw.githubusercontent.com/Lezy233/Venera-PC/main", loader)
        self.assertNotIn("CyrilPeng", loader)


class DesktopWindowTitleTests(unittest.TestCase):
    def test_desktop_window_titles_use_the_new_product_name(self):
        for path, expected in (
            ("linux/my_application.cc", '"Venera-PC-Dev"'),
            ("windows/runner/main.cpp", 'L"Venera-PC-Dev"'),
            ("macos/Runner/Base.lproj/MainMenu.xib", "Venera-PC-Dev"),
            ("lib/main.dart", 'title: "Venera-PC-Dev"'),
        ):
            text = (ROOT / path).read_text(encoding="utf-8")
            self.assertIn(expected, text, path)
            self.assertNotIn("VeneraNext-Dev", text, path)


class CompatibilityIdentityTests(unittest.TestCase):
    def test_winget_generator_keeps_stable_identifiers(self):
        script = (ROOT / ".github/scripts/generate_winget_manifest.py").read_text(
            encoding="utf-8"
        )
        self.assertIn('PACKAGE_IDENTIFIER = "CyrilPeng.VeneraNext"', script)
        self.assertIn('APP_ID = "{C6B7E69A-0FD6-4F2A-AC64-7D1AE8A40FB8}_is1"', script)
        self.assertIn('PACKAGE_NAME = "Venera-PC"', script)
        self.assertIn('PACKAGE_FILE_NAME = "VeneraPC"', script)
        self.assertIn('REPOSITORY_URL = "https://github.com/Lezy233/Venera-PC"', script)
        self.assertIn('"c" / "CyrilPeng" / "VeneraNext"', script)

    def test_inno_upgrade_identity_is_unchanged(self):
        for template in ("build.iss", "build_arm64.iss"):
            text = (ROOT / "windows" / template).read_text(encoding="utf-8")
            self.assertIn(
                "AppId={{56B2DEB6-E67F-4FDA-8D0E-37B65352D468}", text, template
            )
            self.assertIn('MyAppName "Venera-PC"', text.replace("#define ", ""), template)
            self.assertIn("VeneraPC.exe", text, template)

    def test_windows_binary_name_is_venerapc(self):
        cmake = (ROOT / "windows/CMakeLists.txt").read_text(encoding="utf-8")
        self.assertIn('set(BINARY_NAME "VeneraPC")', cmake)

    def test_linux_binary_and_gtk_application_id(self):
        cmake = (ROOT / "linux/CMakeLists.txt").read_text(encoding="utf-8")
        self.assertIn('set(BINARY_NAME "venera-pc")', cmake)
        self.assertIn('set(APPLICATION_ID "com.github.lezy233.veneranext")', cmake)

    def test_macos_product_and_bundle_identity(self):
        xcconfig = (ROOT / "macos/Runner/Configs/AppInfo.xcconfig").read_text(
            encoding="utf-8"
        )
        self.assertIn("PRODUCT_NAME = VeneraPC", xcconfig)
        self.assertIn(
            "PRODUCT_BUNDLE_IDENTIFIER = com.github.lezy233.veneranext", xcconfig
        )
        plist = (ROOT / "macos/Runner/Info.plist").read_text(encoding="utf-8")
        self.assertIn("<string>Venera-PC</string>", plist)

    def test_application_update_api_uses_new_repository(self):
        service = (ROOT / "lib/foundation/application_update_service.dart").read_text(
            encoding="utf-8"
        )
        self.assertIn("repos/Lezy233/Venera-PC/releases/latest", service)
        self.assertIn("repos/Lezy233/Venera-PC/releases?per_page=20", service)


if __name__ == "__main__":
    unittest.main()
