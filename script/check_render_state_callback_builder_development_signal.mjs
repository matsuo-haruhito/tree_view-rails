import fs from "node:fs"

const packageJson = JSON.parse(fs.readFileSync("package.json", "utf8"))
const docsEntrypointSuite = fs.readFileSync("script/test_docs_entrypoint_suite.mjs", "utf8")

const docs = [
  {
    path: "docs/en/development.md",
    content: fs.readFileSync("docs/en/development.md", "utf8"),
    signals: [
      "npm run test:docs-entrypoints -- --list",
      "npm run test:docs-entrypoints -- --only <group-or-index>",
      "RenderState callback builder keys are a manifest-backed key surface",
      "render_state_callback_builder_keys",
      "not a full callback behavior contract",
      "callback arity",
      "return-value validation",
      "row rendering semantics"
    ]
  },
  {
    path: "docs/ja/development.md",
    content: fs.readFileSync("docs/ja/development.md", "utf8"),
    signals: [
      "npm run test:docs-entrypoints -- --list",
      "npm run test:docs-entrypoints -- --only <group-or-index>",
      "RenderState callback builder keys は manifest-backed な key surface",
      "render_state_callback_builder_keys",
      "callback behavior 全体の contract ではありません",
      "callback arity",
      "return-value validation",
      "row rendering semantics"
    ]
  }
]

const expectedSuiteGroup = "RenderState callback builder docs signals"
const expectedSuiteScript = "script/test_render_state_callback_builder_docs_signals.mjs"
const expectedDevelopmentGuard = "script/check_render_state_callback_builder_development_signal.mjs"

const missingSignals = []

function requireSignal(sourceName, source, signal) {
  if (!source.includes(signal)) {
    missingSignals.push(`${sourceName}: ${signal}`)
  }
}

requireSignal(
  "package.json scripts.test:entrypoints",
  packageJson.scripts?.["test:entrypoints"] || "",
  expectedSuiteScript
)
requireSignal(
  "package.json scripts.test:development-docs-commands",
  packageJson.scripts?.["test:development-docs-commands"] || "",
  expectedDevelopmentGuard
)
requireSignal("script/test_docs_entrypoint_suite.mjs", docsEntrypointSuite, expectedSuiteGroup)
requireSignal("script/test_docs_entrypoint_suite.mjs", docsEntrypointSuite, expectedSuiteScript)

for (const doc of docs) {
  for (const signal of doc.signals) {
    requireSignal(doc.path, doc.content, signal)
  }
}

if (missingSignals.length > 0) {
  console.error("[render-state-callback-builder-development-signal] missing Development docs triage signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[render-state-callback-builder-development-signal] ${docs.length} Development docs, ${expectedSuiteGroup}, and ${expectedDevelopmentGuard} stay aligned`
)
