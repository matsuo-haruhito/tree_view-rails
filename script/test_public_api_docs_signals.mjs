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
const lazyLoadingDocs = [
  ["docs/en/lazy-loading.md", read("docs/en/lazy-loading.md")],
  ["docs/ja/lazy-loading.md", read("docs/ja/lazy-loading.md")]
]
const selectionDocs = [
  ["docs/en/selection.md", read("docs/en/selection.md")],
  ["docs/ja/selection.md", read("docs/ja/selection.md")]
]
const diagnosticsDocs = [
  ["docs/en/tree-diagnostics.md", read("docs/en/tree-diagnostics.md")],
  ["docs/ja/tree-diagnostics.md", read("docs/ja/tree-diagnostics.md")]
]
const developmentDocs = [
  ["docs/en/development.md", read("docs/en/development.md")],
  ["docs/ja/development.md", read("docs/ja/development.md")]
]

const callbackBuilderSignals = [
  "render_state_callback_builder_keys",
  "row_event_payload_builder",
  "depth_label_builder",
  "toggle_icon_builder"
]

const hostLifecycleSignals = [
  "TreeViewEventNames.hostLifecycle",
  "loading",
  "loaded",
  "error",
  "retry",
  "TreeViewEventNames.remoteState",
  "TreeViewEventDetailKeys"
]

const remoteStateValueSignals = [
  "TreeViewRemoteStateValues",
  "loading",
  "loaded",
  "error"
]

const selectionDataHookSignals = [
  "TreeViewSelectionDataHooks",
  "TreeViewSelectionDataHooks.hiddenInputNameValue",
  "data-tree-view-selection-hidden-input-name-value"
]

const emptyStateHookSignals = [
  "TreeViewEmptyStateHooks",
  "wrapperAttribute",
  "contentClass",
  "messageClass",
  "data-tree-view-empty-state"
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

const manifestBackedDocsSignalSurfaces = [
  ["RenderState callback builder keys", "render_state_callback_builder_keys:"],
  ["host lifecycle no-detail events", "event_names_without_detail:"],
  ["host lifecycle event names", "host_lifecycle:"],
  ["remote-state values", "remote_state_values:"],
  ["selection data hooks", "selection_data_hooks:"],
  ["empty-state hooks", "empty_state_hooks:"],
  ["diagnostics accepted checks", "diagnostics:"],
  ["diagnostics accepted checks", "accepted_checks:"],
  ["diagnostics run options", "run_options:"],
  ["diagnostics Result surface", "result_surface:"]
]

manifestBackedDocsSignalSurfaces.forEach(([label, manifestNeedle]) => {
  assertIncludes(manifest, manifestNeedle, `public API docs signal manifest surface (${label})`)
})

callbackBuilderSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest callback builder key surface")
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

assertIncludes(manifest, "event_names_without_detail", "public API manifest no-detail event surface")
assertIncludes(manifest, "host_lifecycle", "public API manifest no-detail event surface")
hostLifecycleSignals.slice(1, 5).forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest host lifecycle no-detail event names")
})

publicApiDocs.forEach(([relativePath, document]) => {
  callbackBuilderSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} RenderState callback builder docs`)
  })

  assert(
    /callback arity|return[- ]value|return value|callback arity|戻り値/.test(document),
    `${relativePath}: RenderState callback builder docs no longer mention callback arity or return-value boundary`
  )

  hostLifecycleSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} host lifecycle event docs`)
  })

  assert(
    /host app|host-app|host app 側|host-app 側/.test(document),
    `${relativePath}: host lifecycle event docs no longer name the host-app ownership boundary`
  )

  selectionDataHookSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} selection data hook docs`)
  })

  emptyStateHookSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} empty-state hook docs`)
  })

  assert(
    /final empty-state copy|permission message|filter-reset behavior|最終的な empty-state copy|permission message/.test(document),
    `${relativePath}: empty-state hook docs no longer preserve the host-app-owned final-copy boundary`
  )
})

lazyLoadingDocs.forEach(([relativePath, document]) => {
  remoteStateValueSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} remote-state value docs`)
  })

  assert(
    /not event names|event 名ではありません/.test(document),
    `${relativePath}: remote-state value docs no longer separate state values from event names`
  )
})

selectionDocs.forEach(([relativePath, document]) => {
  selectionDataHookSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} selection data hook docs`)
  })
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

developmentDocs.forEach(([relativePath, document]) => {
  developmentManifestTrackingSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} public API manifest tracking summary`)
  })

  developmentEntrypointGuardSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} public API smoke guard summary`)
  })
})
