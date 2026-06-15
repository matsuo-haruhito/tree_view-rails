import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const workflowSource = readFileSync(workflowPath, "utf8")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

function workflowJobBlock(workflowSource, jobName) {
  const marker = `  ${jobName}:\n`
  const start = workflowSource.indexOf(marker)
  assert(start !== -1, `${workflowPath} must define jobs.${jobName}`)

  const bodyStart = start + marker.length
  const remainingWorkflow = workflowSource.slice(bodyStart)
  const nextJobOffset = remainingWorkflow.search(/\n  [a-z_]+:\n/)

  return nextJobOffset === -1 ? remainingWorkflow : remainingWorkflow.slice(0, nextJobOffset + 1)
}

function assertOrdered(source, earlier, later, label) {
  const earlierIndex = source.indexOf(earlier)
  const laterIndex = source.indexOf(later)

  assert(earlierIndex !== -1, `${label}: missing ${earlier}`)
  assert(laterIndex !== -1, `${label}: missing ${later}`)
  assert(earlierIndex < laterIndex, `${label}: expected ${earlier} before ${later}`)
}

const changesJob = workflowJobBlock(workflowSource, "changes")

const changedFileDetectionSignals = [
  ["base ref fetch", 'git fetch origin "${{ github.base_ref }}" --depth=1'],
  ["merge-base branch", 'git merge-base "origin/${{ github.base_ref }}" HEAD'],
  ["three-dot diff", 'git diff --name-only "origin/${{ github.base_ref }}"...HEAD'],
  ["fallback diff", 'git diff --name-only "origin/${{ github.base_ref }}" HEAD'],
  ["policy invocation", 'node script/ci_changed_files_policy.mjs <<EOF >> "$GITHUB_OUTPUT"'],
  ["changed files heredoc", "$changed_files"]
]

changedFileDetectionSignals.forEach(([label, signal]) => {
  assertIncludes(changesJob, signal, `${workflowPath} jobs.changes changed-file detection ${label}`)
})

assertOrdered(
  changesJob,
  'git fetch origin "${{ github.base_ref }}" --depth=1',
  'git merge-base "origin/${{ github.base_ref }}" HEAD',
  `${workflowPath} jobs.changes must fetch the base ref before merge-base detection`
)

assertOrdered(
  changesJob,
  'git merge-base "origin/${{ github.base_ref }}" HEAD',
  'git diff --name-only "origin/${{ github.base_ref }}"...HEAD',
  `${workflowPath} jobs.changes must try merge-base before the three-dot diff`
)

assertOrdered(
  changesJob,
  'git diff --name-only "origin/${{ github.base_ref }}"...HEAD',
  'git diff --name-only "origin/${{ github.base_ref }}" HEAD',
  `${workflowPath} jobs.changes must keep a fallback diff after the three-dot diff path`
)

assertOrdered(
  changesJob,
  'git diff --name-only "origin/${{ github.base_ref }}" HEAD',
  'node script/ci_changed_files_policy.mjs <<EOF >> "$GITHUB_OUTPUT"',
  `${workflowPath} jobs.changes must pass the collected file list into the policy script`
)

console.log("Checked CI changed-file detection workflow signals.")
