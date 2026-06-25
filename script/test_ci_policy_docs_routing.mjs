import assert from "node:assert/strict"
import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { classifyChangedFiles } from "./ci_changed_files_policy.mjs"

const dependabotPath = ".github/dependabot.yml"
const ciPolicyDocsPaths = [
  "docs/en/ci-policy-suite.md",
  "docs/ja/ci-policy-suite.md"
]
const ciPolicyDocsRoutingScriptPath = "script/test_ci_policy_docs_routing.mjs"

const expected = {
  docs_only: true,
  mockups_changed: false,
  browser_smoke_changed: false,
  package_sensitive: true,
  docker_setup_sensitive: false,
  docs_entrypoint_sensitive: true,
  ci_policy_sensitive: true
}

const expectedCiPolicyScriptChange = {
  docs_only: false,
  mockups_changed: false,
  browser_smoke_changed: false,
  package_sensitive: false,
  docker_setup_sensitive: false,
  docs_entrypoint_sensitive: false,
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

function dependabotUpdateBlock(source, ecosystem) {
  const marker = `  - package-ecosystem: "${ecosystem}"\n`
  const start = source.indexOf(marker)

  assert.notEqual(start, -1, `${dependabotPath} must define a ${ecosystem} update lane`)

  const remaining = source.slice(start + marker.length)
  const nextUpdateOffset = remaining.search(/\n  - package-ecosystem: /)
  return nextUpdateOffset === -1 ? remaining : remaining.slice(0, nextUpdateOffset + 1)
}

function assertIncludes(source, needle, label) {
  assert.ok(source.includes(needle), `${label}: missing ${needle}`)
}

function assertDependabotLaneSignal() {
  const dependabotSource = readFileSync(dependabotPath, "utf8")
  const githubActionsLane = dependabotUpdateBlock(dependabotSource, "github-actions")

  assertIncludes(githubActionsLane, 'directory: "/"', `${dependabotPath} github-actions lane directory`)
  assertIncludes(githubActionsLane, 'interval: "weekly"', `${dependabotPath} github-actions lane schedule interval`)
  assertIncludes(githubActionsLane, 'day: "monday"', `${dependabotPath} github-actions lane schedule day`)
  assertIncludes(githubActionsLane, 'time: "09:00"', `${dependabotPath} github-actions lane schedule time`)
  assertIncludes(githubActionsLane, 'timezone: "Asia/Tokyo"', `${dependabotPath} github-actions lane schedule timezone`)
  assertIncludes(githubActionsLane, "open-pull-requests-limit: 5", `${dependabotPath} github-actions lane open PR limit`)
}

function assertCiPolicyDocsDependabotSignals() {
  const docsSignals = [
    [
      "docs/en/ci-policy-suite.md",
      [
        ".github/dependabot.yml",
        "github-actions",
        "weekly Monday 09:00 Asia/Tokyo",
        "open pull request limit of 5",
        "action-major guard",
        "SHA pinning / allowed action policy"
      ]
    ],
    [
      "docs/ja/ci-policy-suite.md",
      [
        ".github/dependabot.yml",
        "github-actions",
        "weekly Monday 09:00 Asia/Tokyo",
        "open pull request limit 5",
        "action-major guard",
        "SHA pinning / allowed action policy"
      ]
    ]
  ]

  for (const [docsPath, signals] of docsSignals) {
    const docsSource = readFileSync(docsPath, "utf8")

    for (const signal of signals) {
      assertIncludes(docsSource, signal, `${docsPath} GitHub Actions Dependabot lane docs signal`)
    }
  }
}

function assertCiPolicyDocsDockerSetupSignals() {
  const docsSignals = [
    [
      "docs/en/ci-policy-suite.md",
      [
        "docker_setup_sensitive",
        "Dockerfile",
        "docker-compose.yml",
        "package.json",
        "package-lock.json",
        ".nvmrc",
        ".github/workflows/ci.yml",
        "docker_development_setup",
        "Node 22",
        "npm ci",
        "Docker image design"
      ]
    ],
    [
      "docs/ja/ci-policy-suite.md",
      [
        "docker_setup_sensitive",
        "Dockerfile",
        "docker-compose.yml",
        "package.json",
        "package-lock.json",
        ".nvmrc",
        ".github/workflows/ci.yml",
        "docker_development_setup",
        "Node 22",
        "npm ci",
        "Docker image design"
      ]
    ]
  ]

  for (const [docsPath, signals] of docsSignals) {
    const docsSource = readFileSync(docsPath, "utf8")

    for (const signal of signals) {
      assertIncludes(docsSource, signal, `${docsPath} Docker development setup lane docs signal`)
    }
  }
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
  classifyChangedFiles([ciPolicyDocsRoutingScriptPath]),
  expectedCiPolicyScriptChange,
  `${ciPolicyDocsRoutingScriptPath} changes must run the CI policy guard directly`
)

assert.deepEqual(
  parsePolicyCliOutput(policyCliOutput(`${ciPolicyDocsPaths.join("\n")}\n`)),
  expected,
  "changed-file policy CLI must emit CI policy-sensitive routing for bilingual CI policy docs changes"
)

assert.deepEqual(
  parsePolicyCliOutput(policyCliOutput(`${ciPolicyDocsRoutingScriptPath}\n`)),
  expectedCiPolicyScriptChange,
  "changed-file policy CLI must emit CI policy-sensitive routing for CI policy docs routing guard changes"
)

assertDependabotLaneSignal()
assertCiPolicyDocsDependabotSignals()
assertCiPolicyDocsDockerSetupSignals()

console.log(`Checked ${ciPolicyDocsPaths.length} CI policy docs routing paths.`)
console.log("Checked CI policy docs routing guard script routing.")
console.log("Checked GitHub Actions Dependabot lane config and docs signals.")
console.log("Checked Docker development setup CI docs signals.")
