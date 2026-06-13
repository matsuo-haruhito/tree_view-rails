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

for (const check of checks) {
  console.log(`\n[docs-entrypoints] ${check.group}`)
  console.log(`$ ${commandLine(check)}`)

  const result = spawnSync(check.command, check.args, { stdio: "inherit" })

  if (result.error) {
    console.error(
      `[docs-entrypoints] ${check.group} failed to start: ${result.error.message}`
    )
    process.exit(1)
  }

  if (result.signal) {
    console.error(
      `[docs-entrypoints] ${check.group} stopped by signal ${result.signal}: ${commandLine(check)}`
    )
    process.exit(1)
  }

  if (result.status !== 0) {
    console.error(
      `[docs-entrypoints] ${check.group} failed with exit code ${result.status}: ${commandLine(check)}`
    )
    process.exit(result.status ?? 1)
  }
}

console.log("\n[docs-entrypoints] all checks passed")
