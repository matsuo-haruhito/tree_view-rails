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
const jsEventDocs = [
  ["docs/en/js-events.md", read("docs/en/js-events.md")],
  ["docs/ja/js-events.md", read("docs/ja/js-events.md")]
]

const eventNameManifestSignals = [
  ["state event-name manifest group", "event_names:"],
  ["state event-name manifest group", "state_changed: tree-view-state:state-changed"],
  ["selection event-name manifest group", "change: tree-view-selection:change"],
  ["selection event-name manifest group", "selected: tree-view-selection:selected"],
  ["selection event-name manifest group", "limit_exceeded: tree-view-selection:limit-exceeded"],
  ["selection event-name manifest group", "invalid_payload: tree-view-selection:invalid-payload"],
  ["remote-state event-name manifest group", "change: tree-view-remote-state:change"],
  ["remote-state event-name manifest group", "retry: tree-view-remote-state:retry"],
  ["host lifecycle event-name manifest group", "loading: tree-view:loading"],
  ["host lifecycle event-name manifest group", "loaded: tree-view:loaded"],
  ["host lifecycle event-name manifest group", "error: tree-view:error"],
  ["host lifecycle event-name manifest group", "retry: tree-view:retry"],
  ["transfer event-name manifest group", "drag_start: tree-view-transfer:drag-start"],
  ["transfer event-name manifest group", "drag_over: tree-view-transfer:drag-over"],
  ["transfer event-name manifest group", "drop: tree-view-transfer:drop"],
  ["transfer event-name manifest group", "invalid_transfer: tree-view-transfer:invalid-transfer"]
]

const documentedEventNameSignals = [
  "tree-view-state:state-changed",
  "tree-view-selection:change",
  "tree-view-selection:selected",
  "tree-view-selection:limit-exceeded",
  "tree-view-selection:invalid-payload",
  "tree-view-remote-state:change",
  "tree-view-remote-state:retry",
  "tree-view:loading",
  "tree-view:loaded",
  "tree-view:error",
  "tree-view:retry",
  "tree-view-transfer:drag-start",
  "tree-view-transfer:drag-over",
  "tree-view-transfer:drop",
  "tree-view-transfer:invalid-payload",
  "tree-view-transfer:invalid-transfer"
]

const packageRootEventNameSignals = [
  "TreeViewEventNames",
  "TreeViewEventNames.selection.change",
  "TreeViewEventNames.remoteState.change",
  "TreeViewEventNames.hostLifecycle.*",
  "TreeViewEventNames.remoteState.*"
]

eventNameManifestSignals.forEach(([label, signal]) => {
  assertIncludes(manifest, signal, `config/public_api_manifest.yml ${label}`)
})

jsEventDocs.forEach(([relativePath, document]) => {
  documentedEventNameSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} canonical event-name docs`)
  })

  packageRootEventNameSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} package-root event-name docs`)
  })

  assert(
    /raw event strings?|raw event string|event string/.test(document),
    `${relativePath}: event-name docs no longer mention the raw event-name contract`
  )

  assert(
    document.includes("TreeViewEventDetailKeys") && /payload field|公開payload/.test(document),
    `${relativePath}: event-name docs no longer separate event names from detail-key payload fields`
  )
})
