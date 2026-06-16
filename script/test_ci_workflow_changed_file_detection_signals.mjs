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
  assert(start !== -1, `${workflowPath}: missing jobs.${jobName}`)

  const nextJob = workflowSource.indexOf("\n  ", start + marker.length)
  return nextJob === -1 ? workflowSource.slice(start) : workflowSource.slice(start, nextJob)
}

function assertOrdered(source, earlier, later, label) {
  const earlierIndex = source.indexOf(earlier)
  const laterIndex = source.indexOf(later)

  assert(earlierIndex !== -1, `${label}: missing earlier marker ${earlier}`)
  assert(laterIndex !== -1, `${label}: missing later marker ${later}`)
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

const changesJob = workflowJobBlock(workflowSource, "changes")
const rspecJob = workflowJobBlock(workflowSource, "rspec")
const browserSmokeJob = workflowJobBlock(workflowSource, "browser-smoke")
const packageGuardJob = workflowJobBlock(workflowSource, "package-guard")
const dockerBuildJob = workflowJobBlock(workflowSource, "docker-build")
const docsBuildJob = workflowJobBlock(workflowSource, "docs-build")
const docsQualityJob = workflowJobBlock(workflowSource, "docs-quality")
const docsLinkCheckJob = workflowJobBlock(workflowSource, "docs-link-check")
const docsEntryPointJob = workflowJobBlock(workflowSource, "docs-entrypoint-check")

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

assertIncludes(
  changesJob,
  "git diff --name-only --diff-filter=ACMRT origin/${{ github.base_ref }}...HEAD > /tmp/changed_files.txt",
  `${workflowPath} jobs.changes changed-file diff`
)
assertIncludes(
  changesJob,
  "only_docs=true",
  `${workflowPath} jobs.changes docs-only default`
)
assertIncludes(
  changesJob,
  "docs_only=false",
  `${workflowPath} jobs.changes non-docs fallback`
)
assertIncludes(
  changesJob,
  "changed_mockups=false",
  `${workflowPath} jobs.changes mockups default`
)
assertIncludes(
  changesJob,
  "browser_smoke_changed=false",
  `${workflowPath} jobs.changes browser smoke output default`
)
assertIncludes(
  changesJob,
  "package_sensitive=false",
  `${workflowPath} jobs.changes package-sensitive default`
)
assertIncludes(
  changesJob,
  "docker_setup_sensitive=false",
  `${workflowPath} jobs.changes docker-setup-sensitive default`
)
assertIncludes(
  changesJob,
  "docs_entrypoint_sensitive=false",
  `${workflowPath} jobs.changes docs-entrypoint-sensitive default`
)
assertIncludes(
  changesJob,
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes changed-file loop`
)
assertIncludes(
  changesJob,
  "docs/mockups/*)",
  `${workflowPath} jobs.changes mockups detection`
)
assertIncludes(
  changesJob,
  "test/dummy/)",
  `${workflowPath} jobs.changes browser smoke directory detection`
)
assertIncludes(
  changesJob,
  "package.json|package-lock.json|app/assets/javascripts/)",
  `${workflowPath} jobs.changes package-sensitive detection`
)
assertIncludes(
  changesJob,
  "Dockerfile|docker-compose*.yml|entrypoint.sh|bin/docker-entrypoint)",
  `${workflowPath} jobs.changes docker setup detection`
)
assertIncludes(
  changesJob,
  "docs/index.md|docs/)",
  `${workflowPath} jobs.changes docs entrypoint detection`
)
assertIncludes(
  changesJob,
  "mockups_changed=$changed_mockups",
  `${workflowPath} jobs.changes mockups output`
)
assertIncludes(
  changesJob,
  "browser_smoke_changed=$browser_smoke_changed",
  `${workflowPath} jobs.changes browser smoke output`
)
assertIncludes(
  changesJob,
  "package_sensitive=$package_sensitive",
  `${workflowPath} jobs.changes package-sensitive output`
)
assertIncludes(
  changesJob,
  "docker_setup_sensitive=$docker_setup_sensitive",
  `${workflowPath} jobs.changes docker-setup-sensitive output`
)
assertIncludes(
  changesJob,
  "docs_entrypoint_sensitive=$docs_entrypoint_sensitive",
  `${workflowPath} jobs.changes docs-entrypoint-sensitive output`
)
assertOrdered(
  changesJob,
  "only_docs=true",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize docs-only before iterating files`
)
assertOrdered(
  changesJob,
  "changed_mockups=false",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize mockups before iterating files`
)
assertOrdered(
  changesJob,
  "browser_smoke_changed=false",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize browser smoke before iterating files`
)
assertOrdered(
  changesJob,
  "package_sensitive=false",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize package-sensitive before iterating files`
)
assertOrdered(
  changesJob,
  "docker_setup_sensitive=false",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize docker setup before iterating files`
)
assertOrdered(
  changesJob,
  "docs_entrypoint_sensitive=false",
  "while IFS= read -r file; do",
  `${workflowPath} jobs.changes must initialize docs entrypoint before iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"docs_only=$only_docs\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit docs-only after iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"mockups_changed=$changed_mockups\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit mockups after iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"browser_smoke_changed=$browser_smoke_changed\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit browser smoke after iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"package_sensitive=$package_sensitive\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit package-sensitive after iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"docker_setup_sensitive=$docker_setup_sensitive\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit docker setup after iterating files`
)
assertOrdered(
  changesJob,
  "while IFS= read -r file; do",
  "echo \"docs_entrypoint_sensitive=$docs_entrypoint_sensitive\" >> \"$GITHUB_OUTPUT\"",
  `${workflowPath} jobs.changes must emit docs entrypoint after iterating files`
)
assertOrdered(
  changesJob,
  'if [ "${{ github.event_name }}" != "pull_request" ]; then',
  'git fetch origin "${{ github.base_ref }}" --depth=1',
  `${workflowPath} jobs.changes must emit non-pull-request defaults before pull request fetch`
)

assertIncludes(
  rspecJob,
  "if: needs.changes.outputs.docs_only != 'true'",
  `${workflowPath} jobs.rspec docs-only skip condition`
)
assertIncludes(
  browserSmokeJob,
  "if: needs.changes.outputs.docs_only != 'true' || needs.changes.outputs.browser_smoke_changed == 'true'",
  `${workflowPath} jobs.browser-smoke docs-only/browser-smoke condition`
)
assertIncludes(
  packageGuardJob,
  "if: needs.changes.outputs.docs_only != 'true' || needs.changes.outputs.package_sensitive == 'true'",
  `${workflowPath} jobs.package-guard package-sensitive condition`
)
assertIncludes(
  dockerBuildJob,
  "if: needs.changes.outputs.docs_only != 'true' || needs.changes.outputs.docker_setup_sensitive == 'true'",
  `${workflowPath} jobs.docker-build docker-setup-sensitive condition`
)
assertIncludes(
  docsBuildJob,
  "if: needs.changes.outputs.docs_only == 'true'",
  `${workflowPath} jobs.docs-build docs-only condition`
)
assertIncludes(
  docsQualityJob,
  "if: needs.changes.outputs.docs_only == 'true'",
  `${workflowPath} jobs.docs-quality docs-only condition`
)
assertIncludes(
  docsLinkCheckJob,
  "if: needs.changes.outputs.docs_only == 'true'",
  `${workflowPath} jobs.docs-link-check docs-only condition`
)
assertIncludes(
  docsEntryPointJob,
  "if: needs.changes.outputs.docs_entrypoint_sensitive == 'true'",
  `${workflowPath} jobs.docs-entrypoint-check docs entrypoint condition`
)

console.log("Checked CI changed-file detection workflow signals.")
console.log(`Checked ${Object.keys(nonPullRequestDefaultOutputs).length} non-pull-request workflow default outputs.`)
