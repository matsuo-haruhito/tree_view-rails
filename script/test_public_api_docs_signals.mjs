import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const __dirname = path.dirname(fileURLToPath(import.meta.url))
const root = path.resolve(__dirname, "..")

function read(relativePath) {
  return readFileSync(path.join(root, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message)
  }
}

function assertIncludes(document, needle, context) {
  assert(
    document.includes(needle),
    `${context} should mention ${JSON.stringify(needle)} so public API docs keep covering manifest-backed surfaces.`
  )
}

const manifest = read("config/public_api_manifest.yml")
const publicApiDocs = read("docs/en/public_api.md")
const lazyLoadingDocs = read("docs/en/lazy_loading.md")
const selectionDocs = read("docs/en/selection.md")
const diagnosticsDocs = read("docs/en/diagnostics.md")
const developmentDocs = [
  ["docs/en/development.md", read("docs/en/development.md")],
  ["docs/ja/development.md", read("docs/ja/development.md")]
]

const manifestBackedDocsSignalSurfaces = [
  ["RenderState callback builder keys", "render_state_callback_builder_keys:"],
  ["event names without payload", "event_names_without_detail:"],
  ["remote state value constants", "remote_state_value_keys:"],
  ["selection data hook exports", "selection_data_hooks:"],
  ["empty-state hook exports", "empty_state_hooks:"]
]

for (const [label, manifestSignal] of manifestBackedDocsSignalSurfaces) {
  assertIncludes(manifest, manifestSignal, `public API manifest for ${label}`)
}

const callbackBuilderSignals = [
  "TreeViewRenderStateCallbackBuilder",
  "ancestors",
  "children",
  "selected",
  "metadata",
  "loading",
  "expanded",
  "TreeViewRenderState"
]

const hostLifecycleSignals = [
  "TreeViewClickEvent",
  "TreeViewExpandEvent",
  "TreeViewCollapseEvent",
  "TreeViewToggleEvent",
  "treeView:click",
  "treeView:expand",
  "treeView:collapse",
  "treeView:toggle",
  "Event detail payloads",
  "node",
  "event",
  "metadata"
]

const remoteStateValueSignals = [
  "remoteStateValue",
  "setRemoteStateValue",
  "loading",
  "success",
  "error"
]

const selectionDataHookSignals = [
  "TreeViewSelectionDataHooks",
  "selectionDataAction",
  "selectionDataParam",
  "selectionDataValuesParam",
  "selectionDataValue"
]

const emptyStateHookSignals = [
  "TreeViewEmptyStateHooks",
  "emptyStateTitle",
  "emptyStateDescription"
]

const diagnosticsReaderSignals = [
  "TreeViewDiagnostics",
  "findTreeViewRoot",
  "getTreeViewDiagnostics",
  "readTreeViewDatasetDiagnostics"
]

const diagnosticsPayloadSignals = [
  "treeView:diagnostics",
  "version",
  "action",
  "timestamp",
  "metadata"
]

const diagnosticsControllerSignals = [
  "TreeViewDiagnosticsController",
  "connect",
  "disconnect",
  "emit",
  "emitDiagnostics"
]

const lazyLoadingRemoteStateSignals = [
  "remoteStateValue",
  "setRemoteStateValue",
  "loading",
  "success",
  "error",
  "remote state"
]

const selectionDataHookDocsSignals = [
  "TreeViewSelectionDataHooks",
  "selectionDataAction",
  "selectionDataParam",
  "selectionDataValuesParam",
  "selectionDataValue"
]

const developmentManifestTrackingSignals = [
  "config/public_api_manifest.yml",
  "RenderState callback builder keys",
  "event_names_without_detail",
  "remote-state values",
  "selection data hooks",
  "empty-state hooks"
]

const developmentEntrypointGuardSignals = [
  "script/test_public_api_docs_signals.mjs",
  "script/test_entrypoints.mjs",
  "script/test_declaration_literal_shapes.mjs",
  "payload shape",
  "transfer values"
]

for (const signal of callbackBuilderSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md RenderState callback builder section")
}

for (const signal of hostLifecycleSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md host lifecycle event section")
}

for (const signal of remoteStateValueSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md remote state value section")
}

for (const signal of selectionDataHookSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md selection data hooks section")
}

for (const signal of emptyStateHookSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md empty-state hooks section")
}

for (const signal of diagnosticsReaderSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md diagnostics readers section")
}

for (const signal of diagnosticsPayloadSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md diagnostics payload section")
}

for (const signal of diagnosticsControllerSignals) {
  assertIncludes(publicApiDocs, signal, "docs/en/public_api.md diagnostics controller section")
}

for (const signal of lazyLoadingRemoteStateSignals) {
  assertIncludes(lazyLoadingDocs, signal, "docs/en/lazy_loading.md remote state documentation")
}

for (const signal of selectionDataHookDocsSignals) {
  assertIncludes(selectionDocs, signal, "docs/en/selection.md selection data hook documentation")
}

for (const signal of diagnosticsReaderSignals) {
  assertIncludes(diagnosticsDocs, signal, "docs/en/diagnostics.md diagnostics reader documentation")
}

for (const signal of diagnosticsPayloadSignals) {
  assertIncludes(diagnosticsDocs, signal, "docs/en/diagnostics.md diagnostics event payload documentation")
}

for (const signal of diagnosticsControllerSignals) {
  assertIncludes(diagnosticsDocs, signal, "docs/en/diagnostics.md diagnostics controller documentation")
}

for (const [relativePath, document] of developmentDocs) {
  for (const signal of developmentManifestTrackingSignals) {
    assertIncludes(document, signal, `${relativePath} public API manifest tracking summary`)
  }

  for (const signal of developmentEntrypointGuardSignals) {
    assertIncludes(document, signal, `${relativePath} public API smoke guard summary`)
  }
}
