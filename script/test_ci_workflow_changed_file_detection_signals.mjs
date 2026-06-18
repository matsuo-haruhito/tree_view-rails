import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const packagePath = "package.json"
const workflowSource = readFileSync(workflowPath, "utf8")
const packageJson = JSON.parse(readFileSync(packagePath, "utf8"))

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

function workflowNonPullRequestDefaultOutputBlock(changesJob) {
  const match = changesJob.match(
    /if \[ "\$\{\{ github\.event_name \}\}" != "pull_request" \]; then\n(?<body>(?:            echo "[a-z_]+=(?:true|false)" >> "\$GITHUB_OUTPUT"\n)+)            exit 0\n          fi/
  )

  assert(
    match,
    `${workflowPath} jobs.changes must define non-pull-request default outputs before pull request file detection`
  )
  return match.groups.body
}

function assertDefaultWorkflowOutput(block, key, value) {
  assertIncludes(
    block,
    `echo "${key}=${value}" >> "$GITHUB_OUTPUT"`,
    `${workflowPath} jobs.changes non-pull-request default output ${key}`
  )
}

function assertPackageScript(scriptName) {
  assert(
    Object.hasOwn(packageJson.scripts ?? {}, scriptName),
    `${packagePath} scripts must define ${scriptName} for the CI JavaScript job`
  )
}

const changesJob = workflowJobBlock(workflowSource, "changes")
const lintJob = workflowJobBlock(workflowSource, "lint")
const prSpecsJob = workflowJobBlock(workflowSource, "pr_specs")
const prRailsMatrixJob = workflowJobBlock(workflowSource, "pr_rails_matrix")
const rubyMatrixJob = workflowJobBlock(workflowSource, "ruby_matrix")
const railsMatrixJob = workflowJobBlock(workflowSource, "rails_matrix")
const javascriptJob = workflowJobBlock(workflowSource, "javascript")
const dockerDevelopmentSetupJob = workflowJobBlock(workflowSource, "docker_development_setup")
const gemPackageJob = workflowJobBlock(workflowSource, "gem_package")

const nonPullRequestDefaultOutputs = {
  docs_only: false,
  mockups_changed: false,
  browser_smoke_changed: false,
  package_sensitive: true,
  docker_setup_sensitive: true,
  docs_entrypoint_sensitive: true
}
const nonPullRequestDefaultOutputBlock = workflowNonPullRequestDefaultOutputBlock(changesJob)
Object.entries(nonPullRequestDefaultOutputs).forEach(([key, value]) => {
  assertDefaultWorkflowOutput(nonPullRequestDefaultOutputBlock, key, value)
})

assertOrdered(
  changesJob,
  'if [ "${{ github.event_name }}" != "pull_request" ]; then',
  'git fetch origin "${{ github.base_ref }}" --depth=1',
  `${workflowPath} jobs.changes must emit non-pull-request defaults before pull request fetch`
)

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

const workflowActionMajorSignals = [
  ["changes", changesJob, "actions/checkout@v6"],
  ["lint", lintJob, "actions/checkout@v6"],
  ["pr_specs", prSpecsJob, "actions/checkout@v6"],
  ["pr_rails_matrix", prRailsMatrixJob, "actions/checkout@v6"],
  ["ruby_matrix", rubyMatrixJob, "actions/checkout@v6"],
  ["rails_matrix", railsMatrixJob, "actions/checkout@v6"],
  ["javascript", javascriptJob, "actions/checkout@v6"],
  ["docker_development_setup", dockerDevelopmentSetupJob, "actions/checkout@v6"],
  ["gem_package", gemPackageJob, "actions/checkout@v6"],
  ["lint", lintJob, "ruby/setup-ruby@v1"],
  ["pr_specs", prSpecsJob, "ruby/setup-ruby@v1"],
  ["pr_rails_matrix", prRailsMatrixJob, "ruby/setup-ruby@v1"],
  ["ruby_matrix", rubyMatrixJob, "ruby/setup-ruby@v1"],
  ["rails_matrix", railsMatrixJob, "ruby/setup-ruby@v1"],
  ["javascript", javascriptJob, "ruby/setup-ruby@v1"],
  ["gem_package", gemPackageJob, "ruby/setup-ruby@v1"],
  ["javascript", javascriptJob, "actions/setup-node@v6"]
]

workflowActionMajorSignals.forEach(([jobName, jobSource, action]) => {
  assertIncludes(
    jobSource,
    `uses: ${action}`,
    `${workflowPath} jobs.${jobName} workflow action major version signal`
  )
})

assertIncludes(
  javascriptJob,
  'node-version: "22"',
  `${workflowPath} jobs.javascript setup-node representative Node version`
)
assert(
  packageJson.engines?.node === "22.x",
  `${packagePath} engines.node must remain aligned with the CI JavaScript job Node major`
)

const rubyMatrixVersionSignals = [
  ["ruby_matrix", rubyMatrixJob, 'ruby-version:'],
  ["ruby_matrix", rubyMatrixJob, '- "3.2"'],
  ["ruby_matrix", rubyMatrixJob, '- "3.3"'],
  ["rails_matrix", railsMatrixJob, 'ruby-version: "3.2"'],
  ["rails_matrix", railsMatrixJob, 'ruby-version: "3.3"'],
  ["pr_rails_matrix", prRailsMatrixJob, 'ruby-version: "3.2"'],
  ["pr_rails_matrix", prRailsMatrixJob, 'ruby-version: "3.3"']
]

rubyMatrixVersionSignals.forEach(([jobName, jobSource, signal]) => {
  assertIncludes(
    jobSource,
    signal,
    `${workflowPath} jobs.${jobName} representative Ruby version signal`
  )
})

const javascriptJobNpmScripts = [
  "test:docs-entrypoints",
  "test:js:core",
  "test:browser"
]

javascriptJobNpmScripts.forEach((scriptName) => {
  assertIncludes(
    javascriptJob,
    `npm run ${scriptName}`,
    `${workflowPath} jobs.javascript npm script command`
  )
  assertPackageScript(scriptName)
})

console.log("Checked CI changed-file detection workflow signals.")
console.log(`Checked ${Object.keys(nonPullRequestDefaultOutputs).length} non-pull-request workflow default outputs.`)
console.log(`Checked ${workflowActionMajorSignals.length} workflow action major version signals.`)
console.log(`Checked ${rubyMatrixVersionSignals.length} representative Ruby workflow version signals.`)
console.log(`Checked ${javascriptJobNpmScripts.length} JavaScript job npm script commands and package.json scripts.`)
