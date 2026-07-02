import assert from "node:assert/strict";
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs";

const licenseOnlyCases = ["LICENSE", "LICENSE.md", "LICENSE-MIT"];

for (const file of licenseOnlyCases) {
  const result = classifyChangedFiles([file]);

  assert.equal(
    result.package_sensitive,
    true,
    `${file} changes must run gem package verification because LICENSE is part of the packaged release evidence`
  );
  assert.equal(
    result.docs_only,
    false,
    `${file} changes must not be routed as docs-only repository prose`
  );
  assert.equal(
    result.docs_entrypoint_sensitive,
    false,
    `${file} changes must not request docs-entrypoint smoke without a docs entrypoint change`
  );
  assert.equal(
    result.ci_policy_sensitive,
    false,
    `${file} changes must not be CI-policy-sensitive by themselves`
  );
}

console.log(`Checked ${licenseOnlyCases.length} license package-sensitive routing cases.`);
