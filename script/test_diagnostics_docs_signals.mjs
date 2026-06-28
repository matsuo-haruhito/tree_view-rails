import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const manifest = read("config/public_api_manifest.yml")
const diagnosticsDocs = [
  ["docs/en/tree-diagnostics.md", read("docs/en/tree-diagnostics.md")],
  ["docs/ja/tree-diagnostics.md", read("docs/ja/tree-diagnostics.md")]
]

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

const diagnosticsManifestSurfaceSignals = [
  ["diagnostics accepted checks", "diagnostics:"],
  ["diagnostics accepted checks", "accepted_checks:"],
  ["diagnostics run options", "run_options:"],
  ["diagnostics Result surface", "result_surface:"]
]

const diagnosticsAcceptedCheckSignals = [
  "node_keys",
  "dom_ids",
  "orphans",
  "cycles"
]

const diagnosticsRunOptionSignals = [
  "run_options",
  "checks",
  "raise_errors"
]

const diagnosticsResultSurfaceSignals = [
  "checks",
  "errors",
  "warnings",
  "success?"
]

diagnosticsManifestSurfaceSignals.forEach(([label, signal]) => {
  assertIncludes(manifest, signal, `public API manifest diagnostics surface (${label})`)
})

diagnosticsAcceptedCheckSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest diagnostics accepted checks")
})

diagnosticsRunOptionSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest diagnostics run options")
})

diagnosticsResultSurfaceSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest diagnostics Result surface")
})

diagnosticsDocs.forEach(([relativePath, document]) => {
  assertIncludes(document, "TreeView::Diagnostics.run", `${relativePath} diagnostics aggregate entrypoint docs`)
  assertIncludes(document, "checks:", `${relativePath} diagnostics accepted checks docs`)
  assertIncludes(document, "raise_errors:", `${relativePath} diagnostics run option docs`)
  assertIncludes(document, "Result", `${relativePath} diagnostics Result surface docs`)

  diagnosticsAcceptedCheckSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} diagnostics accepted check docs`)
  })

  diagnosticsRunOptionSignals.slice(1).forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} diagnostics run option docs`)
  })

  diagnosticsResultSurfaceSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} diagnostics Result reader docs`)
  })

  assert(
    /manifest-backed.*diagnostics contract|manifest-backed な diagnostics contract/.test(document),
    `${relativePath}: diagnostics docs no longer identify the manifest-backed contract boundary`
  )

  assert(
    /run option key surface|option key surface/.test(document),
    `${relativePath}: diagnostics docs no longer identify the run option key surface boundary`
  )

  assert(
    /individual error entry internals|warning detail shape|orphan warning semantics|cycle validation policy|個々の error entry 内部|warning detail shape|orphan warning semantics|cycle validation policy/.test(document),
    `${relativePath}: diagnostics docs no longer keep detailed error and warning shapes outside the manifest schema`
  )
})

console.log("Checked diagnostics docs signals.")
