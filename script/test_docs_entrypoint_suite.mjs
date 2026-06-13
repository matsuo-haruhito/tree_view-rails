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
    group: "Public setup surface docs signals",
    command: "node",
    args: ["script/test_public_setup_surface_docs_signals.mjs"]
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
    group: "Public API docs signals",
    command: "node",
    args: ["script/test_public_api_docs_signals.mjs"]
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
  }
]

function commandLine({ command, args }) {
  return [command, ...args].join(" ")
}

function formatDuration(milliseconds) {
  if (milliseconds < 1000) return `${milliseconds}ms`

  return `${(milliseconds / 1000).toFixed(1)}s`
}

function printCheckList() {
  console.log(`[docs-entrypoints] ${checks.length} checks configured`)

  checks.forEach((check, index) => {
    console.log(
      `[docs-entrypoints] ${index + 1}. ${check.group}: ${commandLine(check)}`
    )
  })
}

if (process.argv.includes("--list")) {
  printCheckList()
  process.exit(0)
}

const suiteStartedAt = Date.now()
const passedChecks = []

printCheckList()

for (const [index, check] of checks.entries()) {
  const checkStartedAt = Date.now()

  console.log(`\n[docs-entrypoints] ${index + 1}/${checks.length} ${check.group}`)
  console.log(`$ ${commandLine(check)}`)

  const result = spawnSync(check.command, check.args, { stdio: "inherit" })
  const elapsed = Date.now() - checkStartedAt

  if (result.error) {
    console.error(
      `[docs-entrypoints] ${check.group} failed to start after ${formatDuration(elapsed)}: ${result.error.message}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${checks.length} checks passed before failure`
    )
    process.exit(1)
  }

  if (result.signal) {
    console.error(
      `[docs-entrypoints] ${check.group} stopped by signal ${result.signal} after ${formatDuration(elapsed)}: ${commandLine(check)}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${checks.length} checks passed before failure`
    )
    process.exit(1)
  }

  if (result.status !== 0) {
    console.error(
      `[docs-entrypoints] ${check.group} failed with exit code ${result.status} after ${formatDuration(elapsed)}: ${commandLine(check)}`
    )
    console.error(
      `[docs-entrypoints] summary: ${passedChecks.length}/${checks.length} checks passed before failure`
    )
    process.exit(result.status ?? 1)
  }

  passedChecks.push(check.group)
  console.log(
    `[docs-entrypoints] ${check.group} passed in ${formatDuration(elapsed)}`
  )
}

console.log(
  `\n[docs-entrypoints] all ${checks.length} checks passed in ${formatDuration(Date.now() - suiteStartedAt)}`
)
