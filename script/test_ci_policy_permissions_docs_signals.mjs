import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

function assertIncludes(source, needle, label) {
  assert.ok(source.includes(needle), `${label}: missing ${needle}`)
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

console.log("Checked CI policy read-only workflow permissions docs signals.")
