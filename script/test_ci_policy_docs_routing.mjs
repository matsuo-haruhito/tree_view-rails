import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs"

const ciPolicyDocsPaths = [
  "docs/en/ci-policy-suite.md",
  "docs/ja/ci-policy-suite.md"
]

const expected = {
  docs_only: true,
  mockups_changed: false,
  browser_smoke_changed: false,
  package_sensitive: true,
  docker_setup_sensitive: false,
  docs_entrypoint_sensitive: true,
  ci_policy_sensitive: true
}

function policyCliOutput(input) {
  return execFileSync(process.execPath, ["script/ci_changed_files_policy.mjs"], {
    input,
    encoding: "utf8"
  })
}

function parsePolicyCliOutput(output) {
  return Object.fromEntries(
    output.trim().split(/\r?\n/).map((line) => {
      assert.match(line, /^[a-z_]+=(true|false)$/)
      const [key, value] = line.split("=")

      return [key, value === "true"]
    })
  )
}

for (const docsPath of ciPolicyDocsPaths) {
  assert.deepEqual(
    classifyChangedFiles([docsPath]),
    expected,
    `${docsPath} changes must run docs entrypoint, package, and CI policy guards while staying docs-only`
  )
}

assert.deepEqual(
  classifyChangedFiles(ciPolicyDocsPaths),
  expected,
  "bilingual CI policy docs changes must keep the same routing as each individual docs path"
)

assert.deepEqual(
  parsePolicyCliOutput(policyCliOutput(`${ciPolicyDocsPaths.join("\n")}\n`)),
  expected,
  "changed-file policy CLI must emit CI policy-sensitive routing for bilingual CI policy docs changes"
)

console.log(`Checked ${ciPolicyDocsPaths.length} CI policy docs routing paths.`)
