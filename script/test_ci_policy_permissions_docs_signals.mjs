import assert from "node:assert/strict"
import { readFileSync } from "node:fs"
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs"

function assertIncludes(source, needle, label) {
  assert.ok(source.includes(needle), `${label}: missing ${needle}`)
}

function assertCiPolicyRouting(file, expected, label) {
  assert.deepEqual(
    classifyChangedFiles([file]),
    {
      docs_only: false,
      mockups_changed: false,
      browser_smoke_changed: false,
      package_sensitive: false,
      docker_setup_sensitive: false,
      docs_entrypoint_sensitive: false,
      ci_policy_sensitive: true,
      ...expected
    },
    label
  )
}

const docsSignals = [
  [
    "docs/en/ci-policy-suite.md",
    [
      "## Read-only workflow permissions",
      "permissions: contents: read",
      "GITHUB_TOKEN",
      "contents: write",
      "pull-requests: write",
      "job-level `permissions:` overrides",
      "CI token-scope evidence",
      "branch protection",
      "required checks",
      "repository settings",
      "third-party action policy",
      "release publishing credentials",
      "update this note and the guard together"
    ]
  ],
  [
    "docs/ja/ci-policy-suite.md",
    [
      "## Read-only workflow permissions",
      "permissions: contents: read",
      "GITHUB_TOKEN",
      "contents: write",
      "pull-requests: write",
      "job-level `permissions:` override",
      "CI token scope の evidence",
      "branch protection",
      "required checks",
      "repository settings",
      "third-party action policy",
      "release publishing credential",
      "このメモと guard を一緒に更新"
    ]
  ]
]

for (const [docsPath, signals] of docsSignals) {
  const docsSource = readFileSync(docsPath, "utf8")

  for (const signal of signals) {
    assertIncludes(docsSource, signal, `${docsPath} read-only workflow permissions docs signal`)
  }
}

assertCiPolicyRouting(
  "script/test_ci_policy_permissions_docs_signals.mjs",
  {},
  "permissions docs signal guard changes must request the CI policy guard"
)
assertCiPolicyRouting(
  ".github/workflows/release.yaml",
  {
    package_sensitive: true,
    docker_setup_sensitive: true
  },
  "workflow YAML changes must request package, Docker, and CI policy guards"
)
assertCiPolicyRouting(
  ".github/workflows/ci.yml",
  {
    package_sensitive: true,
    docker_setup_sensitive: true
  },
  "the main CI workflow must keep package, Docker, and CI policy guard routing"
)

console.log("Checked CI policy read-only workflow permissions docs signals.")
console.log("Checked CI policy routing for permissions docs signal and workflow changes.")
