import assert from "node:assert/strict"
import { spawnSync } from "node:child_process"

const checks = [
  {
    group: "Foundational docs entrypoints",
    command: "node",
    args: ["script/test_docs_entrypoints.mjs"]
  },
  {
    group: "Repository-only maintainer entrypoints",
    command: "node",
    args: ["script/test_repository_only_maintainer_entrypoints.mjs"]
  },
  {
    group: "Docs entrypoint signals",
    command: "node",
    args: ["script/test_docs_entrypoint_signals.mjs"]
  },
  {
    group: "Host app extension diagnostics signals",
    command: "node",
    args: ["script/test_host_app_extension_diagnostics_signals.mjs"]
  },
  {
    group: "Development docs Node version signals",
    command: "node",
    args: ["script/test_development_docs_node_version_signals.mjs"]
  },
  {
    group: "Development docs command signals",
    command: "npm",
    args: ["run", "test:development-docs-commands"]
  },
  {
    group: "Public setup surface docs signals",
    command: "node",
    args: ["script/test_public_setup_surface_docs_signals.mjs"]
  },
  {
    group: "Configuration docs signals",
    command: "node",
    args: ["script/test_configuration_docs_signals.mjs"]
  },
  {
    group: "Breadcrumb docs signals",
    command: "node",
    args: ["script/test_breadcrumb_docs_signals.mjs"]
  },
  {
    group: "Docs reader journey signals",
    command: "node",
    args: ["script/test_docs_reader_journey_signals.mjs"]
  },
  {
    group: "Decision guide signals",
    command: "node",
    args: ["script/test_decision_guide_signals.mjs"]
  },
  {
    group: "Quality docs smoke signals",
    command: "node",
    args: ["script/test_quality_docs_smoke_signals.mjs"]
  },
  {
    group: "Docs policy signal guards",
    command: "node",
    args: ["script/test_docs_policy_signal_guards.mjs"]
  },
  {
    group: "Release docs signals",
    command: "node",
    args: ["script/test_release_docs_signals.mjs"]
  },
  {
    group: "README quick start signal",
    command: "node",
    args: ["script/test_readme_quick_start_signal.mjs"]
  },
  {
    group: "Mockup docs and asset signals",
    command: "node",
    args: ["script/test_mockup_docs_asset_signals.mjs"]
  },
  {
    group: "README orientation asset signals",
    command: "node",
    args: ["script/test_readme_orientation_asset_signals.mjs"]
  },
  {
    group: "Public API docs signals",
    command: "node",
    args: ["script/test_public_api_docs_signals.mjs"]
  },
  {
    group: "Host lifecycle no-detail docs signals",
    command: "node",
    args: ["script/test_host_lifecycle_no_detail_docs_signals.mjs"]
  },
  {
    group: "tree_view_rows helper docs signals",
    command: "node",
    args: ["script/test_tree_view_rows_docs_signals.mjs"]
  },
  {
    group: "RenderState grouped option docs signals",
    command: "node",
    args: ["script/test_grouped_option_docs_signals.mjs"]
  },
  {
    group: "Public API manifest structure",
    command: "npm",
    args: ["run", "test:public-api-manifest-structure"]
  },
  {
    group: "Public API entrypoint guard signals",
    command: "node",
    args: ["script/test_public_api_entrypoint_guard_signals.mjs"]
  },
  {
    group: "Render window and resource table docs signals",
    command: "node",
    args: ["script/test_render_window_resource_table_docs_signals.mjs"]
  },
  {
    group: "Localized and hook docs signals",
    command: "node",
    args: ["script/test_localized_and_hook_docs_signals.mjs"]
  },
  {
    group: "Docs i18n parity",
    command: "npm",
    args: ["run", "test:docs-i18n"]
  },
  {
    group: "Docs entrypoint suite option contract",
    command: "node",
    args: ["script/test_docs_entrypoint_suite.mjs", "--self-test"]
  }
]

function commandLine({ command, args }) {
  return [command, ...args].join(" ")
}

function formatDuration(milliseconds) {
  if (milliseconds < 1000) return `${milliseconds}ms`

  return `${(milliseconds / 1000).toFixed(1)}s`
}

function formatAvailableGroups() {
  return checks.map((check, index) => `  ${index + 1}. ${check.group}`).join("\n")
}

function printCheckList(selectedChecks = checks) {
  console.log(`[docs-entrypoints] ${selectedChecks.length} checks configured`)

  selectedChecks.forEach((check, index) => {
    console.log(
      `[docs-entrypoints] ${index + 1}. ${check.group}: ${commandLine(check)}`
    )
  })
}

function usage() {
  console.error("[docs-entrypoints] usage: node script/test_docs_entrypoint_suite.mjs [--list] [--only <group-or-index>] [--self-test]")
  console.error("[docs-entrypoints] use --list to show available groups")
}

function resolveOnlyGroupResult(groupName) {
  if (/^\d+$/.test(groupName)) {
    const groupIndex = Number(groupName) - 1
    const indexedMatch = checks[groupIndex]
    if (indexedMatch) return { check: indexedMatch }

    return {
      error: "out_of_range",
      message: `[docs-entrypoints] --only index out of range: ${groupName}`
    }
  }

  const exactMatches = checks.filter((check) => check.group === groupName)
  if (exactMatches.length === 1) return { check: exactMatches[0] }

  const normalizedGroupName = groupName.toLowerCase()
  const caseInsensitiveExactMatches = checks.filter(
    (check) => check.group.toLowerCase() === normalizedGroupName
  )
  if (caseInsensitiveExactMatches.length === 1) return { check: caseInsensitiveExactMatches[0] }

  const partialMatches = checks.filter((check) =>
    check.group.toLowerCase().includes(normalizedGroupName)
  )

  if (partialMatches.length === 1) return { check: partialMatches[0] }

  if (partialMatches.length > 1) {
    return {
      error: "ambiguous",
      message: `[docs-entrypoints] ambiguous --only group: ${groupName}`,
      matches: partialMatches
    }
  }

  return {
    error: "unknown",
    message: `[docs-entrypoints] unknown --only group: ${groupName}`
  }
}

function printOnlyGroupError(result) {
  console.error(result.message)

  if (result.error === "ambiguous") {
    console.error("[docs-entrypoints] matching groups:")
    console.error(result.matches.map((check) => `  - ${check.group}`).join("\n"))
  }

  console.error("[docs-entrypoints] available groups:")
  console.error(formatAvailableGroups())
  console.error("[docs-entrypoints] run with --list to inspect commands")
}

function resolveOnlyGroup(groupName) {
  const result = resolveOnlyGroupResult(groupName)
  if (result.check) return result.check

  printOnlyGroupError(result)
  process.exit(1)
}

function runSelfTest() {
  const availableGroups = formatAvailableGroups()

  assert.match(
    availableGroups,
    /1\. Foundational docs entrypoints/,
    "available group list should include a stable first index"
  )
  assert.ok(
    availableGroups.includes(`${checks.length}. Docs entrypoint suite option contract`),
    "available group list should include the self-test group"
  )

  assert.equal(
    resolveOnlyGroupResult("1").check.group,
    "Foundational docs entrypoints",
    "numeric --only should resolve a one-based index"
  )
  assert.equal(
    resolveOnlyGroupResult("public api docs signals").check.group,
    "Public API docs signals",
    "case-insensitive exact --only should resolve a group"
  )
  assert.equal(
    resolveOnlyGroupResult("Localized and hook").check.group,
    "Localized and hook docs signals",
    "unique partial --only should resolve a group"
  )

  const outOfRange = resolveOnlyGroupResult("999")
  assert.equal(outOfRange.error, "out_of_range")
  assert.match(outOfRange.message, /--only index out of range: 999/)

  const unknown = resolveOnlyGroupResult("does-not-exist")
  assert.equal(unknown.error, "unknown")
  assert.match(unknown.message, /unknown --only group: does-not-exist/)

  const ambiguous = resolveOnlyGroupResult("Public API")
  assert.equal(ambiguous.error, "ambiguous")
  assert.deepEqual(
    ambiguous.matches.map((check) => check.group),
    [
      "Public API docs signals",
      "Public API manifest structure",
      "Public API entrypoint guard signals"
    ],
    "ambiguous --only should report all matching groups"
  )

  console.log("[docs-entrypoints] self-test passed")
}

function parseArgs(argv) {
  const options = { list: false, only: null, selfTest: false }

  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index]

    if (arg === "--list") {
      options.list = true
      continue
    }

    if (arg === "--self-test") {
      options.selfTest = true
      continue
    }

    if (arg === "--only") {
      const groupName = argv[index + 1]

      if (!groupName || groupName.startsWith("--")) {
        console.error("[docs-entrypoints] --only requires a group name or index")
        usage()
        console.error("[docs-entrypoints] available groups:")
        console.error(formatAvailableGroups())
        process.exit(1)
      }

      options.only = resolveOnlyGroup(groupName)
      index += 1
      continue
    }

    console.error(`[docs-entrypoints] unknown argument: ${arg}`)
    usage()
    process.exit(1)
  }

  return options
}

const options = parseArgs(process.argv.slice(2))

if (options.selfTest) {
  runSelfTest()
  process.exit(0)
}

if (options.list) {
  printCheckList()
  process.exit(0)
}

const selectedChecks = options.only ? [options.only] : checks
const suiteStartedAt = Date.now()
const passedChecks = []

printCheckList(selectedChecks)

for (const [index, check] of selectedChecks.entries()) {
  const checkStartedAt = Date.now()

  console.log(`\n[docs-entrypoints] ${index + 1}/${selectedChecks.length} ${check.group}`)
  console.log(`$ ${commandLine(check)}`)

  const result = spawnSync(check.command, check.args, { stdio: "inherit" })
  const elapsed = Date.now() - checkStartedAt

  if (result.error) {
    console.error(
      `[docs-entrypoints] ${check.group} failed to start after ${formatDuration(elapsed)}: ${result.error.message}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${selectedChecks.length} checks passed before failure`
    )
    process.exit(1)
  }

  if (result.signal) {
    console.error(
      `[docs-entrypoints] ${check.group} stopped by signal ${result.signal} after ${formatDuration(elapsed)}: ${commandLine(check)}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${selectedChecks.length} checks passed before failure`
    )
    process.exit(1)
  }

  if (result.status !== 0) {
    console.error(
      `[docs-entrypoints] ${check.group} failed with exit code ${result.status} after ${formatDuration(elapsed)}: ${commandLine(check)}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${selectedChecks.length} checks passed before failure`
    )
    process.exit(result.status ?? 1)
  }

  passedChecks.push(check.group)
  console.log(
    `[docs-entrypoints] ${check.group} passed in ${formatDuration(elapsed)}`
  )
}

console.log(
  `\n[docs-entrypoints] all ${selectedChecks.length} checks passed in ${formatDuration(Date.now() - suiteStartedAt)}`
)
