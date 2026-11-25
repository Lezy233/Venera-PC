import unittest
from pathlib import Path

import yaml


ROOT = Path(__file__).resolve().parents[3]


class MacosRustupShimTests(unittest.TestCase):
    def test_shim_uses_runner_temp_and_path_independent_of_cargo_home(self):
        workflow = yaml.safe_load(
            (ROOT / ".github/workflows/build.yml").read_text(encoding="utf-8")
        )
        steps = workflow["jobs"]["Build_MacOS"]["steps"]
        matching = [step for step in steps if step.get("name") == "串行化 Rustup 安装操作"]
        self.assertEqual(len(matching), 1)
        script = matching[0]["run"]
        self.assertIn("$RUNNER_TEMP/rustup-shim", script)
        self.assertIn("$GITHUB_PATH", script)
        self.assertIn("RUSTUP_REAL_BINARY", script)
        self.assertIn("RUSTUP_LOCK_FILE", script)
        # The runner image may ship rustup outside $HOME/.cargo/bin.
        self.assertNotIn("$HOME/.cargo/bin", script)


if __name__ == "__main__":
    unittest.main()
