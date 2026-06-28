import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const workflowSource = readFileSync(workflowPath, "utf8")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

function assertAbsent(source, needle, label) {
  assert(!source.includes(needle), `${label}: unexpected ${needle}`)
}

function workflowTopLevelConcurrencyBlock(workflowSource) {
  const match = workflowSource.match(/^concurrency:\n(?<body>[\s\S]*?)\n\njobs:\n/m)

  assert(
    match,
    `${workflowPath} CI concurrency policy must define a top-level concurrency block before jobs`
  )

  return match.groups.body
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

assertWorkflowConcurrencyPolicy(workflowSource)

console.log("Checked CI workflow concurrency policy signals.")
