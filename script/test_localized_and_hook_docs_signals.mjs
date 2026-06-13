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

function assertMatches(source, pattern, label) {
  assert(pattern.test(source), `${label}: missing ${pattern}`)
}

const manifest = read("config/public_api_manifest.yml")
const publicApiDocs = [
  ["docs/en/public-api.md", read("docs/en/public-api.md")],
  ["docs/ja/public-api.md", read("docs/ja/public-api.md")]
]
const localizedNameDocs = [
  ["docs/en/localized-names.md", read("docs/en/localized-names.md")],
  ["docs/ja/localized-names.md", read("docs/ja/localized-names.md")]
]

const localizedNameManifestSignals = [
  "localized_name_i18n_keys:",
  "model_name_for",
  "attribute_name_for",
  "type_name_for",
  "activerecord.models",
  "activemodel.models",
  "activerecord.attributes",
  "activemodel.attributes",
  "tree_view.node_types",
  "humanized_class_name_or_default",
  "humanized_attribute_name_or_default",
  "humanized_node_type_or_default"
]

localizedNameManifestSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "LocalizedNames public API manifest surface")
})

localizedNameDocs.forEach(([relativePath, document]) => {
  [
    "TreeView.model_name_for",
    "TreeView.attribute_name_for",
    "TreeView.type_name_for",
    "TreeView::LocalizedNames",
    "config/public_api_manifest.yml",
    "activerecord.models",
    "activemodel.models",
    "activerecord.attributes",
    "activemodel.attributes",
    "tree_view.node_types"
  ].forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} LocalizedNames docs`)
  })

  assertMatches(
    document,
    /fallback|humanize|humanized|fallback label|fallback copy/,
    `${relativePath}: LocalizedNames docs no longer describe fallback behavior`
  )

  assertMatches(
    document,
    /host app.*translation|host app.*locale|translation file|translation completeness|host app の translation file|host app の責務/,
    `${relativePath}: LocalizedNames docs no longer keep translation ownership with the host app`
  )

  assertMatches(
    document,
    /only resolve display names|表示名を解決するだけ/,
    `${relativePath}: LocalizedNames docs no longer separate name resolution from UI rendering`
  )
})

const publicApiHookExports = [
  {
    name: "TreeViewRemoteStateDataHooks",
    docs: ["data-tree-lazy", "data-tree-children-url", "data-tree-loaded", "data-tree-remote-state"],
    boundary: /request dispatch|response handling|retry UI|authorization-safe copy|request dispatch、response handling、retry UI、authorization-safe copy/
  },
  {
    name: "TreeViewToolbarDataHooks",
    docs: ["data-tree-view-toolbar", "data-tree-view-toolbar-action", "data-tree-view-toolbar-disabled"],
    boundary: /action policy|authorization copy|final UI|action policy、label、authorization copy、最終 UI/
  }
]

publicApiHookExports.forEach(({ name }) => {
  assertIncludes(manifest, name, `public API manifest JavaScript export surface (${name})`)
})

publicApiDocs.forEach(([relativePath, document]) => {
  publicApiHookExports.forEach(({ name, docs, boundary }) => {
    assertIncludes(document, name, `${relativePath} JavaScript hook export docs`)

    docs.forEach((signal) => {
      assertIncludes(document, signal, `${relativePath} ${name} documented hook values`)
    })

    assertMatches(document, boundary, `${relativePath}: ${name} docs no longer name the host-app responsibility boundary`)
  })
})
