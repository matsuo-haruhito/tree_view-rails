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

function assertAll(source, needles, label) {
  needles.forEach((needle) => assertIncludes(source, needle, label))
}

function assertDocs(paths, needles, label) {
  paths.forEach((relativePath) => {
    assertAll(read(relativePath), needles, `${relativePath} ${label}`)
  })
}

const manifest = read("config/public_api_manifest.yml")

const publicConstantSignals = [
  "public_constants:",
  "- Error",
  "- ConfigurationError",
  "- InvalidTreeError",
  "- DuplicateNodeKeyError",
  "- CycleDetectedError",
  "- InvalidRenderWindowError"
]

const publicConstantDocsSignals = [
  "TreeView::Error",
  "TreeView::ConfigurationError",
  "TreeView::InvalidTreeError",
  "TreeView::DuplicateNodeKeyError",
  "TreeView::CycleDetectedError",
  "TreeView::InvalidRenderWindowError"
]

const localizedNameManifestSignals = [
  "localized_name_i18n_keys:",
  "helper: model_name_for",
  "activerecord.models",
  "activemodel.models",
  "helper: attribute_name_for",
  "activerecord.attributes",
  "activemodel.attributes",
  "helper: type_name_for",
  "tree_view.node_types",
  "fallback: humanized_node_type_or_default"
]

const localizedNameDocsSignals = [
  "TreeView.model_name_for",
  "TreeView.attribute_name_for",
  "TreeView.type_name_for",
  "activerecord.models",
  "activemodel.models",
  "activerecord.attributes",
  "activemodel.attributes",
  "tree_view.node_types",
  "fallback"
]

const setupGeneratorManifestSignals = [
  "setup_generators:",
  "persisted_state_install:",
  "name: tree_view:state:install",
  "class_name: TreeView::Generators::State::InstallGenerator",
  "banner: OWNER_MODEL",
  "db/migrate/*_create_tree_view_states.rb",
  "app/models/tree_view_state.rb",
  "app/models/concerns/tree_view_state_owner.rb"
]

const setupGeneratorDocsSignals = [
  "tree_view:state:install",
  "bin/rails generate tree_view:state:install User",
  "config/public_api_manifest.yml",
  "db/migrate/*_create_tree_view_states.rb",
  "app/models/tree_view_state.rb",
  "app/models/concerns/tree_view_state_owner.rb",
  "host app"
]

const stateEventDetailManifestSignals = [
  "event_detail_keys:",
  "state_changed:",
  "- viewKey",
  "- expandedKeys",
  "- reason",
  "remote_state:",
  "change:",
  "retry:",
  "- row",
  "- state",
  "- childrenUrl",
  "- nodeKey"
]

const stateEventDocsSignals = [
  "tree-view-state:state-changed",
  "viewKey",
  "expandedKeys",
  "reason",
  "tree-view-remote-state:change",
  "tree-view-remote-state:retry",
  "childrenUrl",
  "nodeKey",
  "TreeViewEventDetailKeys"
]

const lazyLoadingRemoteStateSignals = [
  "data-tree-children-url",
  "TreeViewEventNames.remoteState.*",
  "TreeViewEventNames.hostLifecycle",
  "TreeViewRemoteStateValues",
  "host app"
]

assertAll(manifest, publicConstantSignals, "public API manifest public constants surface")
assertAll(manifest, localizedNameManifestSignals, "public API manifest localized-name surface")
assertAll(manifest, setupGeneratorManifestSignals, "public API manifest setup-generator surface")
assertAll(manifest, stateEventDetailManifestSignals, "public API manifest state and remote-state event detail surface")

assertDocs(
  ["docs/en/errors.md", "docs/ja/errors.md"],
  publicConstantDocsSignals,
  "public error hierarchy docs"
)

assertDocs(
  ["docs/en/public-api.md", "docs/ja/public-api.md"],
  [...publicConstantDocsSignals, "TreeView.model_name_for", "TreeView.attribute_name_for", "TreeView.type_name_for"],
  "public API manifest-backed public surface docs"
)

assertDocs(
  ["docs/en/localized-names.md", "docs/ja/localized-names.md"],
  localizedNameDocsSignals,
  "localized-name lookup and fallback docs"
)

assertDocs(
  ["docs/en/public-setup-surface.md", "docs/ja/public-setup-surface.md"],
  setupGeneratorDocsSignals,
  "setup generator public surface docs"
)

assertDocs(
  ["docs/en/js-events.md", "docs/ja/js-events.md"],
  stateEventDocsSignals,
  "state and remote-state event detail docs"
)

assertDocs(
  ["docs/en/lazy-loading.md", "docs/ja/lazy-loading.md"],
  lazyLoadingRemoteStateSignals,
  "lazy-loading remote-state boundary docs"
)
