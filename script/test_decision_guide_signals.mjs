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

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => {
    assert(
      source.includes(signal),
      `${feature}: ${sourcePath} is missing representative signal ${JSON.stringify(signal)}`
    )
  })
}

const decisionGuideSignals = [
  {
    feature: "Decision guide flowchart and loading boundary",
    files: [
      [
        "docs/en/decision-guide.md",
        [
          "## Flowchart",
          "flowchart TD",
          "Render controls",
          "Data-loading controls",
          "Static rendering: Tree + RenderState + tree_view_rows",
          "Turbo rendering: UiConfigBuilder#build_turbo with show/hide path builders",
          "Client-side rendering: UiConfigBuilder#build_client_side",
          "Lazy Loading or Children Pagination",
          "RenderWindow or window: offset/limit",
          "Host-app JavaScript or external virtualization library",
          "GraphAdapter with host-app roots, children_resolver, and node_key_resolver"
        ]
      ],
      [
        "docs/ja/decision-guide.md",
        [
          "## Flowchart",
          "flowchart TD",
          "描画制御",
          "データ読み込み制御",
          "Static rendering: Tree + RenderState + tree_view_rows",
          "Turbo rendering: UiConfigBuilder#build_turbo と show/hide path builders",
          "Client-side rendering: UiConfigBuilder#build_client_side",
          "Lazy Loading または Children Pagination",
          "RenderWindow または window: offset/limit",
          "host app JavaScript または外部virtualization library",
          "GraphAdapter と host-app roots / children_resolver / node_key_resolver"
        ]
      ]
    ]
  },
  {
    feature: "Decision guide common combinations",
    files: [
      [
        "docs/en/decision-guide.md",
        [
          "## Common combinations",
          "Small admin taxonomy",
          "Large folder browser",
          "Heterogeneous project workspace",
          "Large scrolling browser",
          "Bulk action page",
          "Tree-wide action toolbar",
          "Row action menu",
          "Localized row display",
          "Reorderable hierarchy"
        ]
      ],
      [
        "docs/ja/decision-guide.md",
        [
          "## よくある組み合わせ",
          "小さな管理用taxonomy",
          "大きなfolder browser",
          "異種nodeを含むproject workspace",
          "大きなscrolling browser",
          "bulk action page",
          "tree全体のaction toolbar",
          "row action menu",
          "localized row display",
          "並び替え可能な階層"
        ]
      ]
    ]
  }
]

decisionGuideSignals.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
