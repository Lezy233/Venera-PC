import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[3]
WORKFLOWS = ("analyze.yml", "pr_build.yml", "build.yml")


class PdfrxEnginePatchWorkflowTests(unittest.TestCase):
    def test_every_compiling_workflow_patches_after_pub_get(self) -> None:
        for name in WORKFLOWS:
            workflow = yaml.safe_load(
                (ROOT / ".github/workflows" / name).read_text(encoding="utf-8")
            )
            for job_id, job in workflow["jobs"].items():
                runs = [
                    step.get("run", "")
                    for step in job.get("steps", [])
                    if step.get("run")
                ]
                text = "\n".join(runs)
                if "flutter pub get --enforce-lockfile" not in text:
                    continue
                pub_get = text.index("flutter pub get --enforce-lockfile")
                patch = text.find("patch_pdfrx_engine.py")
                self.assertNotEqual(
                    patch,
                    -1,
                    f"{name}:{job_id} compiles the app but does not patch pdfrx_engine",
                )
                self.assertGreater(
                    patch,
                    pub_get,
                    f"{name}:{job_id} must patch pdfrx_engine after pub get",
                )

    def test_patch_script_exists(self) -> None:
        self.assertTrue(
            (ROOT / ".github/scripts/patch_pdfrx_engine.py").is_file()
        )


if __name__ == "__main__":
    unittest.main()
