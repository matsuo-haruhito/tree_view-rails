import assert from "node:assert/strict"
import { readFileSync } from "node:fs"

const agentsPath = "AGENTS.md"
const workflowPath = ".github/workflows/ci.yml"

const agentsSource = readFileSync(agentsPath, "utf8")
const workflowSource = readFileSync(workflowPath, "utf8")

function assertIncludes(source, needle, label) {
  assert.ok(source.includes(needle), `${label}: missing ${needle}`)
}

const guidanceSignals = [
  "CI observation rule",
  "combined status is empty",
  "GitHub Actions workflow run",
  "status/conclusion",
  "changed-files routing",
  "skipped jobs"
]

guidanceSignals.forEach((signal) => {
  assertIncludes(agentsSource, signal, `${agentsPath} CI observation guidance`)
})

const workflowSignals = [
  "name: CI",
  "jobs:",
  "changes:",
  "docs_only:",
  "package_sensitive:",
  "docs_entrypoint_sensitive:",
  "run: npm run test:docs-entrypoints",
  "run: npm run test:browser"
]

workflowSignals.forEach((signal) => {
  assertIncludes(workflowSource, signal, `${workflowPath} workflow run observation source`)
})

console.log("Checked CI observation guidance signals.")
console.log(`Checked ${guidanceSignals.length} maintainer guidance signals.`)
console.log(`Checked ${workflowSignals.length} workflow source signals for observation context.`)
