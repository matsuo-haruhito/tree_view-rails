import assert from "node:assert/strict";
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs";

const cases = [
  {
    name: "root and language docs stay docs-only",
    files: ["README.md", "docs/en/development.md", "docs/ja/development.md", "Product Profile.md", "CHANGELOG.md", "AGENTS.md"],
    expected: {
      docs_only: true,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: false
    }
  },
  {
    name: "mockup docs remain docs-only but request browser smoke",
    files: ["docs/mockups/default-tree.html"],
    expected: {
      docs_only: true,
      mockups_changed: true,
      browser_smoke_changed: false,
      package_sensitive: false
    }
  },
  {
    name: "browser smoke tests are not docs-only and request browser smoke",
    files: ["test/browser/docs_mockups_smoke.spec.js"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: true,
      package_sensitive: false
    }
  },
  {
    name: "workflow changes are package-sensitive full CI changes",
    files: [".github/workflows/ci.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true
    }
  },
  {
    name: "package-sensitive runtime files are not docs-only",
    files: ["app/javascript/tree_view/index.js", "config/public_api_manifest.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true
    }
  }
];

for (const testCase of cases) {
  assert.deepEqual(classifyChangedFiles(testCase.files), testCase.expected, testCase.name);
}

console.log(`Checked ${cases.length} CI changed-file policy cases.`);
