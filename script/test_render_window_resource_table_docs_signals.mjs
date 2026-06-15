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
  assert(source.includes(needle), `${label}: missing ${JSON.stringify(needle)}`)
}

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => assertIncludes(source, signal, `${feature} (${sourcePath})`))
}

const manifest = read("config/public_api_manifest.yml")

const renderWindowMetadataSignals = [
  "render_window_metadata:",
  "rows",
  "offset",
  "limit",
  "total_count",
  "before_count",
  "after_count",
  "start_index",
  "end_index",
  "previous?",
  "next?",
  "previous_offset",
  "next_offset",
  "empty?"
]

const resourceTableCallSignals = [
  "resource_table_render_state_call:",
  "required_keywords:",
  "records",
  "context",
  "optional_keywords:",
  "row_partial",
  "parent_id_method",
  "id_method",
  "table_key",
  "columns",
  "table_state",
  "ui_config",
  "render_options_contract: render_state_pass_through"
]

renderWindowMetadataSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest RenderWindow metadata surface")
})

resourceTableCallSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest ResourceTableRenderState call surface")
})

const windowedRenderingDocs = [
  [
    "docs/en/windowed-rendering.md",
    [
      "tree_view_window",
      "TreeView::RenderWindow",
      "render_window_metadata",
      "before_count",
      "after_count",
      "previous_offset",
      "next_offset",
      "route helper",
      "URL parameters",
      "disabled button behavior",
      "infinite scroll",
      "virtual scrolling",
      "host-app decisions"
    ]
  ],
  [
    "docs/ja/windowed-rendering.md",
    [
      "tree_view_window",
      "TreeView::RenderWindow",
      "render_window_metadata",
      "before_count",
      "after_count",
      "previous_offset",
      "next_offset",
      "route helper",
      "URL parameter",
      "disabled button",
      "infinite scroll",
      "virtual scrolling",
      "host app 側で決めます"
    ]
  ]
]

const resourceTableBridgeDocs = [
  [
    "docs/en/resource-table-bridge.md",
    [
      "ResourceTableRenderState.call",
      "manifest-backed public bridge",
      "required keywords are `records:` and `context:`",
      "documented optional bridge keywords",
      "columns:",
      "table_state:",
      "visible_columns",
      "**render_options",
      "RenderState option surface",
      "row_data_builder:",
      "bridge writes these keys last",
      "column inference",
      "saved table state"
    ]
  ],
  [
    "docs/ja/resource-table-bridge.md",
    [
      "ResourceTableRenderState.call",
      "manifest-backed な public bridge",
      "required keyword は `records:` と `context:`",
      "optional bridge keyword",
      "columns:",
      "table_state:",
      "visible_columns",
      "**render_options",
      "RenderState option surface",
      "row_data_builder:",
      "bridge が次の key を最後に書き込みます",
      "カラム推論",
      "保存済みtable state"
    ]
  ]
]

windowedRenderingDocs.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "RenderWindow metadata docs signal", signals)
})

resourceTableBridgeDocs.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "ResourceTableRenderState bridge docs signal", signals)
})
