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
const toolbarDocs = [
  ["docs/en/toolbar.md", read("docs/en/toolbar.md")],
  ["docs/ja/toolbar.md", read("docs/ja/toolbar.md")]
]
const graphAdapterDocs = [
  ["docs/en/graph-adapter.md", read("docs/en/graph-adapter.md")],
  ["docs/ja/graph-adapter.md", read("docs/ja/graph-adapter.md")]
]
const diagnosticsDocs = [
  ["docs/en/tree-diagnostics.md", read("docs/en/tree-diagnostics.md")],
  ["docs/ja/tree-diagnostics.md", read("docs/ja/tree-diagnostics.md")]
]
const pathTreeBuilderDocs = [
  ["docs/en/path-tree-builder.md", read("docs/en/path-tree-builder.md")],
  ["docs/ja/path-tree-builder.md", read("docs/ja/path-tree-builder.md")]
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

const lazyLoadingHostLifecycleSignals = [
  "TreeViewEventNames.hostLifecycle",
  "tree-view:loading",
  "tree-view:loaded",
  "tree-view:error",
  "tree-view:retry",
  "TreeViewEventNames.remoteState",
  "TreeViewRemoteStateValues"
]

const remoteStateValueSignals = [
  "TreeViewRemoteStateValues",
  "loading",
  "loaded",
  "error"
]

const remoteStateDataHookSignals = [
  "TreeViewRemoteStateDataHooks",
  "data-tree-lazy",
  "data-tree-children-url",
  "data-tree-loaded",
  "data-tree-remote-state"
]

const selectionDataHookSignals = [
  "TreeViewSelectionDataHooks",
  "TreeViewSelectionDataHooks.hiddenInputNameValue",
  "data-tree-view-selection-hidden-input-name-value"
]

const selectionHiddenInputSubmissionBoundarySignals = [
  "TreeView.parse_selection_params",
  "data-tree-view-selection-hidden-input-name-value",
  "TreeViewSelectionDataHooks.hiddenInputNameValue",
  "selection-multi-tree-form.html"
]

const selectionHiddenInputBookkeepingSignals = [
  "data-tree-view-selection-source-id",
  "data-tree-view-selection-generated-hidden-input"
]

const toolbarDataHookSignals = [
  "TreeViewToolbarDataHooks",
  "data-tree-view-toolbar",
  "data-tree-view-toolbar-action",
  "data-tree-view-toolbar-disabled"
]

const toolbarActionMetadataSignals = [
  "toolbar_actions",
  "toolbar_action_metadata",
  "tree_view_toolbar_action_metadata",
  "action",
  "state",
  "label",
  "path",
  "disabled",
  "data",
  "tree_view_toolbar_action",
  "tree_view_toolbar_disabled",
  "path: nil",
  "disabled: true"
]

const emptyStateHookSignals = [
  "TreeViewEmptyStateHooks",
  "wrapperAttribute",
  "contentClass",
  "messageClass",
  "data-tree-view-empty-state"
]

const graphAdapterInitializerSignals = [
  "graph_adapter_initializer",
  "roots",
  "children_resolver",
  "node_key_resolver"
]

const graphAdapterBoundarySignals = [
  "authorization",
  "query planning",
  "host-app responsibility"
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

const pathTreeBuilderNodeShapeSignals = [
  "FolderNode",
  "RecordNode",
  "key",
  "parent_key",
  "label",
  "path",
  "node_type",
  "record",
  "folder_node?",
  "record_node?"
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
  ["remote-state data hooks", "remote_state_data_hooks:"],
  ["selection data hooks", "selection_data_hooks:"],
  ["empty-state hooks", "empty_state_hooks:"],
  ["toolbar data hooks", "toolbar_data_hooks:"],
  ["toolbar actions", "toolbar_actions:"],
  ["toolbar action metadata", "toolbar_action_metadata:"],
  ["GraphAdapter initializer", "graph_adapter_initializer:"],
  ["diagnostics accepted checks", "diagnostics:"],
  ["diagnostics accepted checks", "accepted_checks:"],
  ["diagnostics run options", "run_options:"],
  ["diagnostics Result surface", "result_surface:"],
  ["PathTreeBuilder node shapes", "path_tree_builder_node_shapes:"]
]

manifestBackedDocsSignalSurfaces.forEach(([label, manifestNeedle]) => {
  assertIncludes(manifest, manifestNeedle, `public API docs signal manifest surface (${label})`)
})

callbackBuilderSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest callback builder key surface")
})

graphAdapterInitializerSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest GraphAdapter initializer surface")
})

remoteStateDataHookSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest remote-state data hook surface")
})

toolbarDataHookSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest toolbar data hook surface")
})

toolbarActionMetadataSignals.slice(0, 10).forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest toolbar action metadata surface")
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

pathTreeBuilderNodeShapeSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest PathTreeBuilder node shape surface")
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

  assertIncludes(document, "TreeViewRemoteStateDataHooks", `${relativePath} remote-state data hook docs`)
  assertIncludes(document, "TreeViewToolbarDataHooks", `${relativePath} toolbar data hook docs`)

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

  remoteStateDataHookSignals.slice(1).forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} remote-state data hook docs`)
  })

  assert(
    /not event names|event 名ではありません/.test(document),
    `${relativePath}: remote-state value docs no longer separate state values from event names`
  )

  lazyLoadingHostLifecycleSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} host lifecycle event reader-journey docs`)
  })

  assert(
    /The host app can dispatch these events|host app側は、fetchやTurbo requestの状態に応じてこれらのeventをdispatchできます/.test(document),
    `${relativePath}: Lazy Loading docs no longer say host apps dispatch the lifecycle events`
  )

  assert(
    /host app remains responsible for fetch behavior|実際のfetch、Turbo request、controller action、認可、query、retry UI、children pagination/.test(document),
    `${relativePath}: Lazy Loading docs no longer preserve the host-app-owned remote loading boundary`
  )

  assert(
    /separate surface|別 surface/.test(document),
    `${relativePath}: Lazy Loading docs no longer separate host lifecycle events from remote-state controller events`
  )
})

selectionDocs.forEach(([relativePath, document]) => {
  selectionDataHookSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} selection data hook docs`)
  })

  selectionHiddenInputSubmissionBoundarySignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} selection hidden input submission docs`)
  })

  selectionHiddenInputBookkeepingSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} selection hidden input bookkeeping boundary docs`)
  })

  assert(
    /hidden input `name` stays host-app controlled|hidden input の `name` は host app 側で決められます/.test(document),
    `${relativePath}: selection hidden input docs no longer state that submitted param names are host-app controlled`
  )

  assert(
    /Values are written as JSON strings|value は JSON 文字列で書き込まれる/.test(document),
    `${relativePath}: selection hidden input docs no longer preserve the JSON submitted-value contract`
  )

  assert(
    /Disabled checkboxes and invalid JSON payloads are skipped|disabled checkbox と不正な JSON payload は.*skip/.test(document),
    `${relativePath}: selection hidden input docs no longer match the disabled and invalid-payload skip boundary`
  )

  assert(
    /TreeView-owned bookkeeping|TreeView 側の bookkeeping/.test(document),
    `${relativePath}: selection hidden input docs no longer keep generated marker and source-id attributes as TreeView-owned bookkeeping`
  )
})

toolbarDocs.forEach(([relativePath, document]) => {
  toolbarDataHookSignals.slice(1).forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} toolbar data hook docs`)
  })

  toolbarActionMetadataSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} toolbar action metadata docs`)
  })

  assert(
    /Authorization, route availability, and final fallback copy still belong to the host app|authorization、route availability、fallback copy の最終判断は引き続き host app 側の責務/.test(document),
    `${relativePath}: toolbar action metadata docs no longer preserve the host-app-owned fallback boundary`
  )

  assert(
    /final labels, locale files|最終 label、locale file/.test(document),
    `${relativePath}: toolbar data hook docs no longer preserve the host-app-owned label and locale boundary`
  )

  assert(
    /compatibility checks and integration audits|compatibility check と integration audit/.test(document),
    `${relativePath}: toolbar action metadata docs no longer point readers at the manifest-backed integration contract`
  )
})

graphAdapterDocs.forEach(([relativePath, document]) => {
  assertIncludes(document, "TreeView::GraphAdapter", `${relativePath} GraphAdapter guide entrypoint docs`)

  graphAdapterInitializerSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} GraphAdapter initializer manifest boundary docs`)
  })

  graphAdapterBoundarySignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} GraphAdapter host-app responsibility boundary docs`)
  })

  assert(
    /constructor surface|constructor surface|constructor surface/.test(document),
    `${relativePath}: GraphAdapter docs no longer identify the initializer constructor surface boundary`
  )

  assert(
    /traversal semantics|traversal semantics|traversal semantics/.test(document),
    `${relativePath}: GraphAdapter docs no longer separate traversal semantics from the manifest schema`
  )
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

pathTreeBuilderDocs.forEach(([relativePath, document]) => {
  assertIncludes(document, "TreeView::PathTreeBuilder", `${relativePath} PathTreeBuilder docs`)

  pathTreeBuilderNodeShapeSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} PathTreeBuilder node shape docs`)
  })

  assert(
    /public API manifest|public API manifest/.test(document),
    `${relativePath}: PathTreeBuilder docs no longer identify the manifest-backed node shape contract`
  )

  assert(
    /folder key generation strategy|sort algorithm|file-manager behavior|row action design|folder key generation strategy|sort algorithm|file-manager behavior|row action design/.test(document),
    `${relativePath}: PathTreeBuilder docs no longer keep generated-key, sorting, file-manager, and row-action behavior outside the node shape contract`
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
