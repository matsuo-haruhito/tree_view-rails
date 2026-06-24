import { readFileSync } from "node:fs"

const workflowPath = ".github/workflows/ci.yml"
const workflowSource = readFileSync(workflowPath, "utf8")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

function topLevelWorkflowPermissions(source) {
  const match = source.match(/^permissions:\n(?<body>(?:  [a-z-]+: .+\n)+)/m)
  assert(match, `${workflowPath} must declare top-level GITHUB_TOKEN permissions`)
  return match.groups.body
}

function jobLevelWorkflowPermissions(source) {
  return source
    .split(/\r?\n/)
    .map((line, index) => ({ line, number: index + 1 }))
    .filter(({ line }) => /^    permissions:\s*$/.test(line))
}

const permissionsBlock = topLevelWorkflowPermissions(workflowSource)
const jobLevelPermissions = jobLevelWorkflowPermissions(workflowSource)

assertIncludes(
  permissionsBlock,
  "  contents: read\n",
  `${workflowPath} top-level workflow permissions`
)

assert(
  !/^  contents: write$/m.test(permissionsBlock),
  `${workflowPath} must not request write contents permission for CI jobs`
)

assert(
  !/^  pull-requests: write$/m.test(permissionsBlock),
  `${workflowPath} must not request pull request write permission for CI jobs`
)

assert(
  jobLevelPermissions.length === 0,
  [
    `${workflowPath} must not declare job-level GITHUB_TOKEN permissions overrides; keep CI read-only at the workflow top level.`,
    ...jobLevelPermissions.map(({ number }) => `  - job-level permissions block starts on line ${number}`)
  ].join("\n")
)

console.log("Checked CI workflow read-only GITHUB_TOKEN permissions.")
