import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const englishPolicyPath = "docs/en/ci-policy.md"
const japanesePolicyPath = "docs/ja/ci-policy.md"

const workflow = readFileSync(workflowPath, "utf8")
const englishPolicy = readFileSync(englishPolicyPath, "utf8")
const japanesePolicy = readFileSync(japanesePolicyPath, "utf8")

function assertIncludes(source, expected, label) {
  assert.ok(
    source.includes(expected),
    `${label} must include ${JSON.stringify(expected)}`
  )
}

function assertAbsent(source, unexpected, label) {
  assert.ok(
    !source.includes(unexpected),
    `${label} must not include ${JSON.stringify(unexpected)}`
  )
}

function workflowJobBlock(jobName) {
  const jobHeader = `\n  ${jobName}:\n`
  const start = workflow.indexOf(jobHeader)

  assert.notEqual(start, -1, `${workflowPath} must define jobs.${jobName}`)

  const blockStart = start + 1
  const nextJobMatch = workflow.slice(blockStart + jobHeader.length).match(/\n  [A-Za-z0-9_]+:\n/)
  const blockEnd = nextJobMatch
    ? blockStart + jobHeader.length + nextJobMatch.index
    : workflow.length

  return workflow.slice(blockStart, blockEnd)
}

function assertRailsLane(jobBlock, jobName, railsVersion) {
  const gemfileVersion = railsVersion.replace(".", "_")

  assertIncludes(
    jobBlock,
    `- rails: "${railsVersion}"`,
    `${workflowPath} jobs.${jobName} Rails ${railsVersion} lane`
  )
  assertIncludes(
    jobBlock,
    `gemfiles/rails_${gemfileVersion}.gemfile`,
    `${workflowPath} jobs.${jobName} Rails ${railsVersion} gemfile lane`
  )
}

const prRailsMatrixJob = workflowJobBlock("pr_rails_matrix")
const rubyMatrixJob = workflowJobBlock("ruby_matrix")
const railsMatrixJob = workflowJobBlock("rails_matrix")

assertIncludes(
  prRailsMatrixJob,
  "if: github.event_name == 'pull_request'",
  `${workflowPath} jobs.pr_rails_matrix pull-request boundary`
)
assertIncludes(
  rubyMatrixJob,
  "if: github.event_name == 'push' && github.ref == 'refs/heads/main'",
  `${workflowPath} jobs.ruby_matrix main-push boundary`
)
assertIncludes(
  railsMatrixJob,
  "if: github.event_name == 'push' && github.ref == 'refs/heads/main'",
  `${workflowPath} jobs.rails_matrix main-push boundary`
)

for (const railsVersion of ["7.0", "7.2", "8.0"]) {
  assertRailsLane(prRailsMatrixJob, "pr_rails_matrix", railsVersion)
}

assertAbsent(
  prRailsMatrixJob,
  "- rails: \"7.1\"",
  `${workflowPath} jobs.pr_rails_matrix representative Rails matrix`
)
assertAbsent(
  prRailsMatrixJob,
  "gemfiles/rails_7_1.gemfile",
  `${workflowPath} jobs.pr_rails_matrix representative Rails matrix`
)

for (const railsVersion of ["7.0", "7.1", "7.2", "8.0"]) {
  assertRailsLane(railsMatrixJob, "rails_matrix", railsVersion)
}

assertIncludes(
  englishPolicy,
  "Pull requests run the representative Rails matrix for Rails 7.0, Rails 7.2, and Rails 8.0.",
  englishPolicyPath
)
assertIncludes(
  englishPolicy,
  "Rails 7.1 stays in the main-push full Rails matrix.",
  englishPolicyPath
)
assertIncludes(
  japanesePolicy,
  "Pull Request は Rails 7.0、Rails 7.2、Rails 8.0 の representative Rails matrix を実行します。",
  japanesePolicyPath
)
assertIncludes(
  japanesePolicy,
  "Rails 7.1 は main-push full Rails matrix に残します。",
  japanesePolicyPath
)

console.log("Checked CI matrix boundary workflow and docs signals.")
