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

const hostAppExtensionDiagnosticsSignals = [
  {
    feature: "Host app extension diagnostics reverse lookup",
    files: [
      [
        "docs/en/host-app-extension-points.md",
        [
          "Inspect tree data before rendering",
          "TreeView::Diagnostics.run",
          "validate_node_keys: true",
          "RenderState#validate_unique_dom_ids!",
          "cycle/orphan diagnostics",
          "duplicate node key",
          "tree-diagnostics.md",
          "Public API"
        ]
      ],
      [
        "docs/ja/host-app-extension-points.md",
        [
          "描画前に tree data を確認する",
          "TreeView::Diagnostics.run",
          "validate_node_keys: true",
          "RenderState#validate_unique_dom_ids!",
          "cycle / orphan diagnostics",
          "duplicate node key",
          "tree-diagnostics.md",
          "Public API"
        ]
      ]
    ]
  }
]

hostAppExtensionDiagnosticsSignals.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
