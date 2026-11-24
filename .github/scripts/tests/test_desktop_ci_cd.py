import json
import os
import re
import subprocess
import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[3]
WORKFLOWS = ROOT / ".github/workflows"
BUILD_YML = WORKFLOWS / "build.yml"
MAIN_YML = WORKFLOWS / "main.yml"


def load_workflow(path):
    # GitHub Actions workflows may use non-standard YAML tags such as
    # `on:`; parse with a tolerant loader that treats them as plain maps.
    class ActionsLoader(yaml.SafeLoader):
        pass

    def unknown(loader, tag_suffix, node):
        if isinstance(node, yaml.MappingNode):
            return loader.construct_mapping(node)
        if isinstance(node, yaml.SequenceNode):
            return loader.construct_sequence(node)
        return loader.construct_scalar(node)

    ActionsLoader.add_multi_constructor("", unknown)
    ActionsLoader.add_multi_constructor("tag:yaml.org,2002:", unknown)
    data = yaml.load(path.read_text(encoding="utf-8"), Loader=ActionsLoader)
    if "on" not in data and True in data:
        # YAML 1.1 resolves the bare key `on` to boolean true.
        data["on"] = data.pop(True)
    return data


class DesktopBuildWorkflowTests(unittest.TestCase):
    def test_only_desktop_inputs_are_exposed(self):
        on = load_workflow(BUILD_YML)["on"]
        for trigger in ("workflow_call", "workflow_dispatch"):
            inputs = on[trigger].get("inputs", {})
            self.assertIsInstance(inputs, dict)
            self.assertEqual(
                sorted(inputs),
                ["build_linux_arm64", "build_linux_x64", "build_macos", "build_windows"],
                f"{trigger} inputs should only cover desktop platforms",
            )
            for definition in inputs.values():
                self.assertEqual(definition["type"], "boolean")
                self.assertTrue(definition["default"])
            expected_required = trigger == "workflow_dispatch"
            for definition in inputs.values():
                self.assertEqual(definition["required"], expected_required)

    def test_mobile_signing_secrets_are_removed(self):
        workflow = load_workflow(BUILD_YML)
        secrets = workflow["on"]["workflow_call"].get("secrets", {})
        self.assertEqual(secrets, {})

    def test_only_desktop_jobs_remain(self):
        workflow = load_workflow(BUILD_YML)
        self.assertEqual(
            sorted(workflow["jobs"]),
            [
                "Build_Linux_ARM64",
                "Build_Linux_x64",
                "Build_MacOS",
                "Build_Windows",
            ],
        )

    def test_no_mobile_references_in_build_workflow(self):
        text = BUILD_YML.read_text(encoding="utf-8")
        for pattern in (r"android", r"ios", r"apk", r"\bipa\b", r"keystore"):
            self.assertIsNone(
                re.search(pattern, text, re.IGNORECASE),
                f"build.yml still references mobile content: {pattern}",
            )


class DesktopReleaseWorkflowTests(unittest.TestCase):
    def test_build_call_only_passes_desktop_inputs(self):
        workflow = load_workflow(MAIN_YML)
        build = workflow["jobs"]["Build"]
        self.assertEqual(
            sorted(build["with"]),
            ["build_linux_arm64", "build_linux_x64", "build_macos", "build_windows"],
        )
        self.assertNotIn("secrets", build)

    def test_release_metadata_validation_distinguishes_manual_builds_and_tags(self):
        workflow = load_workflow(MAIN_YML)
        steps = workflow["jobs"]["Release_Metadata"]["steps"]
        step = next(step for step in steps if step.get("name") == "校验发布元数据")
        version = json.loads((ROOT / "release.json").read_text(encoding="utf-8"))["version"]
        cases = (
            ("workflow_dispatch", "main"),
            ("push", f"v{version}"),
        )
        for event_name, ref_name in cases:
            with self.subTest(event_name=event_name, ref_name=ref_name):
                result = subprocess.run(
                    ["bash", "-e", "-c", step["run"]],
                    cwd=ROOT,
                    env={
                        **os.environ,
                        "GITHUB_EVENT_NAME": event_name,
                        "GITHUB_REF_NAME": ref_name,
                    },
                    capture_output=True,
                    text=True,
                )
                self.assertEqual(
                    result.returncode,
                    0,
                    f"stdout:\n{result.stdout}\nstderr:\n{result.stderr}",
                )
                self.assertIn(f"Release metadata for v{version} is valid", result.stdout)

    def test_release_downloads_only_desktop_artifacts(self):
        text = MAIN_YML.read_text(encoding="utf-8")
        self.assertNotIn("ios_build", text)
        self.assertNotIn("apk-", text)
        for artifact in (
            "macos_build",
            "windows_build",
            "deb_build",
            "arch_build",
            "deb_arm64_build",
            "linux_extra_",
        ):
            self.assertIn(artifact, text)

    def test_release_file_globs_exclude_mobile_assets(self):
        workflow = load_workflow(MAIN_YML)
        script = None
        for step in workflow["jobs"]["Release"]["steps"]:
            if "创建草稿 Release 并上传资产" in (step.get("name") or ""):
                script = step["run"]
                break
        self.assertIsNotNone(script)
        self.assertIn("outputs/*.dmg", script)
        self.assertIn("outputs/*.AppImage", script)
        for glob in ("outputs/*.apk", "outputs/*.ipa"):
            self.assertNotIn(glob, script)


PR_BUILD_YML = WORKFLOWS / "pr_build.yml"
ANALYZE_YML = WORKFLOWS / "analyze.yml"


class PullRequestGateWorkflowTests(unittest.TestCase):
    def test_android_job_and_gate_dependency_are_removed(self):
        workflow = load_workflow(PR_BUILD_YML)
        self.assertEqual(
            sorted(workflow["jobs"]),
            ["changes", "platform_gate", "windows"],
        )
        self.assertEqual(
            workflow["jobs"]["platform_gate"]["needs"],
            ["changes", "windows"],
        )

    def test_gate_summary_keeps_windows_smoke_checks(self):
        text = PR_BUILD_YML.read_text(encoding="utf-8")
        self.assertNotIn("ANDROID_RESULT", text)
        self.assertIn("WINDOWS_RESULT", text)
        self.assertIn("windows-pr-startup-logs", text)
        self.assertIn("test_windows_startup.ps1", text)
        self.assertIn("platform_gate", text)


class QualityWorkflowTests(unittest.TestCase):
    def test_ios_only_check_is_removed_and_desktop_checks_stay(self):
        workflow = load_workflow(ANALYZE_YML)
        self.assertEqual(
            sorted(workflow["jobs"]),
            ["analyze", "apple-directory-access", "flutter-tests", "rhttp-native"],
        )
        text = ANALYZE_YML.read_text(encoding="utf-8")
        self.assertIn("swift test --package-path apple", text)
        self.assertNotIn("rhttp-ios", text)

    def test_directory_access_uses_the_desktop_macos_runner(self):
        quality = load_workflow(ANALYZE_YML)
        build = load_workflow(BUILD_YML)
        job = quality["jobs"]["apple-directory-access"]
        self.assertEqual(job["runs-on"], "macos-15")
        desktop_runners = {
            name: definition["runs-on"]
            for name, definition in build["jobs"].items()
            if str(definition.get("runs-on", "")).startswith("macos-")
        }
        self.assertEqual(set(desktop_runners.values()), {job["runs-on"]})
        self.assertEqual(
            [step.get("run") for step in job["steps"]],
            [None, "swift test --package-path apple"],
        )

    def test_quality_steps_keep_structure_tests_and_coverage(self):
        workflow = load_workflow(ANALYZE_YML)
        analyze_runs = [
            step.get("run", "") for step in workflow["jobs"]["analyze"]["steps"]
        ]
        self.assertIn(
            "python3 .github/scripts/check_structure_imports.py", analyze_runs
        )
        self.assertIn(
            'python3 -m unittest discover -s .github/scripts/tests -p "test_*.py"',
            analyze_runs,
        )
        self.assertIn("flutter pub get --enforce-lockfile", analyze_runs)
        self.assertIn("flutter analyze --fatal-infos --fatal-warnings", analyze_runs)
        flutter_runs = [
            step.get("run", "")
            for step in workflow["jobs"]["flutter-tests"]["steps"]
        ]
        self.assertTrue(any("flutter test --coverage" in run for run in flutter_runs))
        self.assertIn(
            "python3 .github/scripts/prepare_linux_test_libraries.py",
            "".join(flutter_runs),
        )


if __name__ == "__main__":
    unittest.main()
