import assert from "node:assert/strict";
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs";

const importmapPath = "config/importmap.tree_view.rb";
const classification = classifyChangedFiles([importmapPath]);

assert.deepEqual(
  classification,
  {
    docs_only: false,
    mockups_changed: false,
    browser_smoke_changed: false,
    package_sensitive: true,
    docker_setup_sensitive: false,
    docs_entrypoint_sensitive: true,
    ci_policy_sensitive: false
  },
  `${importmapPath} changes must run package and docs entrypoint guards without changing workflow topology`
);

console.log("Checked importmap docs entrypoint routing.");
