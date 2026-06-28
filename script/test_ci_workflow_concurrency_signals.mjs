import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs"

const workflowPath = ".github/workflows/ci.yml"
const concurrencySignalPath = "script/test_ci_workflow_concurrency_signals.mjs"
const ciPolicyDocsPaths = [
  "docs/en/ci-policy-suite.md",
  "docs/ja/ci-policy-suite.md"
]
const workflowSource = readFileSync(workflowPath, "utf8")

const expectedCiPolicyScriptChange = {
  docs_only: false,
  mockups_changed: false,
  browser_smoke_changed: false,
  package_sensitive: false,
  docker_setup_sensitive: false,
  docs_entrypoint_sensitive: false,
  ci_policy_sensitive: true
}

function assertIncludes(source, needle, label) {
  assert.ok(source.includes(needle), `${label}: missing ${needle}`)
}

function assertAbsent(source, needle, label) {
  assert.ok(!source.includes(needle), `${label}: unexpected ${needle}`)
}

function workflowTopLevelConcurrencyBlock(workflowSource) {
  const match = workflowSource.match(/^concurrency:\n(?<body>[\s\S]*?)\n\njobs:\n/m)

  assert.ok(
    match,
    `${workflowPath} CI concurrency policy must define a top-level concurrency block before jobs`
  )

  return match.groups.body
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
      assert.match(line, /^[a-z_]+=(true|false)$/, `policy CLI output must be key=value boolean, got ${line}`)
      const [key, value] = line.split("=")

      return [key, value === "true"]
    })
  )
}

function assertWorkflowConcurrencyPolicy(workflowSource) {
  const concurrencyBlock = workflowTopLevelConcurrencyBlock(workflowSource)

  assertIncludes(
    concurrencyBlock,
    "  group: ${{ github.workflow }}-${{ github.event_name }}-${{ github.event.pull_request.number || github.ref }}",
    `${workflowPath} CI concurrency policy group`
  )
  assertIncludes(
    concurrencyBlock,
    "  cancel-in-progress: ${{ github.event_name == 'pull_request' }}",
    `${workflowPath} CI concurrency policy pull-request-only cancellation`
  )
  assertAbsent(
    concurrencyBlock,
    "cancel-in-progress: true",
    `${workflowPath} CI concurrency policy must not cancel main push runs unconditionally`
  )
}

function assertConcurrencyDocsSignals() {
  const docsSignals = [
    [
      "docs/en/ci-policy-suite.md",
      [
        "## Pull request run concurrency",
        concurrencySignalPath,
        "PR-only cancellation condition",
        "absence of unconditional `cancel-in-progress: true`",
        "does not change workflow routing, required checks, branch protection, or CI polling behavior"
      ]
    ],
    [
      "docs/ja/ci-policy-suite.md",
      [
        "## Pull request run concurrency",
        concurrencySignalPath,
        "PR-only cancellation 条件",
        "無条件の `cancel-in-progress: true` がないこと",
        "workflow routing、required checks、branch protection、CI polling behavior は変更しません"
      ]
    ]
  ]

  for (const [docsPath, signals] of docsSignals) {
    const docsSource = readFileSync(docsPath, "utf8")

    for (const signal of signals) {
      assertIncludes(docsSource, signal, `${docsPath} workflow concurrency docs signal`)
    }
  }
}

function assertConcurrencySignalRouting() {
  assert.deepEqual(
    classifyChangedFiles([concurrencySignalPath]),
    expectedCiPolicyScriptChange,
    `${concurrencySignalPath} changes must run CI policy guard directly`
  )

  assert.deepEqual(
    parsePolicyCliOutput(policyCliOutput(`${concurrencySignalPath}\n`)),
    expectedCiPolicyScriptChange,
    "changed-file policy CLI must emit CI policy-sensitive routing for workflow concurrency signal changes"
  )
}

assertWorkflowConcurrencyPolicy(workflowSource)
assertConcurrencyDocsSignals()
assertConcurrencySignalRouting()

console.log("Checked CI workflow concurrency policy signals.")
console.log("Checked CI workflow concurrency docs signals.")
console.log("Checked CI workflow concurrency guard routing.")
