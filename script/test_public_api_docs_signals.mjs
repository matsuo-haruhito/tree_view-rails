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

callbackBuilderSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest callback builder key surface")
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
