import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs";

const workflowPath = ".github/workflows/ci.yml";
const packagePath = "package.json";

const cases = [
  {
    name: "gem-packaged docs stay docs-only and request package and docs entrypoint guards",
    files: ["README.md", "docs/en/development.md", "docs/ja/development.md", "CHANGELOG.md"],
    expected: {
      docs_only: true,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "repository-only docs stay docs-only without package or docs entrypoint guard",
    files: ["Product Profile.md", "AGENTS.md"],
    expected: {
      docs_only: true,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: false,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "mockup docs remain docs-only but request browser smoke and package guard",
    files: ["docs/mockups/default-tree.html"],
    expected: {
      docs_only: true,
      mockups_changed: true,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: true
    }
  },
  {
    name: "browser smoke tests are not docs-only and request browser smoke",
    files: ["test/browser/docs_mockups_smoke.spec.js"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: true,
      package_sensitive: false,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "workflow changes are package- and Docker-sensitive full CI changes",
    files: [".github/workflows/ci.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: true,
      docs_entrypoint_sensitive: false
    }
  },
  {
    name: "public manifest changes request full JS and docs entrypoint guards",
    files: ["config/public_api_manifest.yml"],
    expected: {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: true,
      docker_setup_sensitive: true,
      docs_entrypoint_sensitive: true
    }
  }
];
