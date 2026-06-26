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

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => {
    assertIncludes(source, signal, `${feature}: ${sourcePath}`)
  })
}

const feature = "RenderState grouped option docs"
const manifest = read("config/public_api_manifest.yml")

const groupedOptionSignals = [
  "grouped_option_keys:",
  "initial_expansion:",
  "render_scope:",
  "toggle_scope:",
  "toggle_icons:",
  "selection:",
  "lazy_loading:",
  "row_status:",
  "auto_expand_ancestors",
  "max_leaf_distance",
  "payload_builder",
  "disabled_reason_builder",
  "row_disabled_builder",
  "row_readonly_builder",
  "row_disabled_reason_builder"
]

assertSignals("config/public_api_manifest.yml", feature, groupedOptionSignals)

const publicApiDocSignals = [
  "### RenderState grouped option keys",
  "config/public_api_manifest.yml",
  "spec/public_api_compatibility_spec.rb",
  "initial_expansion",
  "render_scope",
  "toggle_scope",
  "toggle_icons",
  "selection",
  "lazy_loading",
  "row_status",
  "auto_expand_ancestors",
  "max_leaf_distance",
  "payload_builder",
  "disabled_reason_builder",
  "row_readonly_builder"
]

;["docs/en/public-api.md", "docs/ja/public-api.md"].forEach((sourcePath) => {
  assertSignals(sourcePath, feature, publicApiDocSignals)
})

const rowStatusDocSignals = [
  "row_disabled_builder",
  "row_readonly_builder",
  "row_disabled_reason_builder",
  "tree-view-row--disabled",
  "tree-view-row--readonly",
  "data-tree-view-row-disabled-reason",
  "disabled_builder",
  "TreeView-owned status data keys",
  "business rule",
  "authorization",
  "action disabling",
  "disabled reason display"
]

;["docs/en/row-status.md", "docs/ja/row-status.md"].forEach((sourcePath) => {
  assertSignals(sourcePath, "RenderState row status docs", rowStatusDocSignals)
})

assert(
  /grouped_option_keys:\n(?:.|\n)*initial_expansion:\n(?:.|\n)*selection:\n(?:.|\n)*lazy_loading:\n(?:.|\n)*row_status:/.test(manifest),
  `${feature}: config/public_api_manifest.yml grouped option groups are missing or unexpectedly reordered`
)
