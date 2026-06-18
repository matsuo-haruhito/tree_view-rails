import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

const manifest = read("config/public_api_manifest.yml")
const publicApiDocs = [
  ["docs/en/public-api.md", read("docs/en/public-api.md")],
  ["docs/ja/public-api.md", read("docs/ja/public-api.md")]
]
const renderLogLevelDocs = [
  ["docs/en/render-log-level.md", read("docs/en/render-log-level.md")],
  ["docs/ja/render-log-level.md", read("docs/ja/render-log-level.md")]
]

const configurationOptionSignals = ["initial_state", "render_log_level"]
const configurationEntrypointSignals = [
  "TreeView.configure",
  "TreeView.configuration",
  "TreeView.reset_configuration!"
]

assertIncludes(manifest, "configuration_options:", "public API manifest configuration option surface")
assertIncludes(manifest, "tree_view_configure:", "public API manifest TreeView.configure option surface")
configurationOptionSignals.forEach((signal) => {
  assertIncludes(manifest, `- ${signal}`, "public API manifest TreeView.configure option names")
})

publicApiDocs.forEach(([relativePath, document]) => {
  configurationEntrypointSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} configuration entrypoint docs`)
  })

  configurationOptionSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} configuration option docs`)
  })

  assertIncludes(document, "render-log-level.md", `${relativePath} render_log_level docs link`)
  assertIncludes(document, "config/public_api_manifest.yml", `${relativePath} manifest-backed configuration docs`)
  assertIncludes(document, "accepted value", `${relativePath} configuration accepted-value boundary docs`)

  assert(
    /manifest.*option names|manifest.*option 名|option names.*manifest|option 名.*manifest/.test(document),
    `${relativePath}: configuration docs must say the manifest tracks option names rather than a separate value schema`
  )
})

renderLogLevelDocs.forEach(([relativePath, document]) => {
  assertIncludes(document, "TreeView.configure", `${relativePath} configuration entrypoint docs`)
  assertIncludes(document, "config/public_api_manifest.yml", `${relativePath} manifest-backed option docs`)

  configurationOptionSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} configuration option docs`)
  })

  ;[":expanded", ":collapsed", ":debug", ":info", ":warn", ":error", ":fatal", ":unknown", "nil"].forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} accepted configuration value docs`)
  })

  assertIncludes(document, "Rails.logger.level", `${relativePath} host-app logging boundary docs`)
  assertIncludes(document, "TreeView::ConfigurationError", `${relativePath} invalid initial_state boundary docs`)
})

console.log("Checked configuration option manifest and docs signals.")
