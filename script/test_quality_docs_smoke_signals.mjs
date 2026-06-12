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

const signalGroups = [
  {
    feature: "Decision guide and troubleshooting reader journey",
    files: [
      [
        "README.md",
        [
          "If you already know the symptom and want a faster reverse-lookup entry point",
          "docs/en/troubleshooting.md",
          "docs/ja/troubleshooting.md"
        ]
      ],
      [
        "docs/README.md",
        [
          "choose APIs and options by use case",
          "use caseからAPIやoptionを選ぶための入口",
          "reverse-lookup entry point for common integration symptoms",
          "よくある統合トラブルを症状から逆引きする入口"
        ]
      ],
      [
        "docs/en/decision-guide.md",
        [
          "Use this guide when you know what you want to build",
          "Start from the use case",
          "Troubleshooting](troubleshooting.md#toggle-links-do-not-expand-or-collapse)"
        ]
      ],
      [
        "docs/ja/decision-guide.md",
        [
          "何を作りたいか",
          "やりたいことから選ぶ",
          "Troubleshooting](troubleshooting.md#toggle-links-do-not-expand-or-collapse)"
        ]
      ],
      [
        "docs/en/troubleshooting.md",
        [
          "symptom-based entry point",
          "already know what is going wrong",
          "Read next:",
          "Host App Extension Points"
        ]
      ],
      [
        "docs/ja/troubleshooting.md",
        [
          "症状ベース",
          "どの API 文書から読み直せばよいか",
          "次に読む文書:",
          "Host App 拡張ポイント"
        ]
      ]
    ]
  },
  {
    feature: "Resource-table empty colspan boundary mockup",
    files: [
      [
        "docs/mockups/README.md",
        [
          "resource-table-empty-colspan-boundary.html",
          "broad `colspan=\"999\"` fallback",
          "host-owned exact colspan",
          "selection/action columns",
          "TreeView empty-state wrapper boundaries"
        ]
      ],
      [
        "docs/mockups/resource-table-empty-colspan-boundary.html",
        [
          "data-tree-view-sample=\"resource-table-empty-colspan-boundary\"",
          "colspan=\"999\"",
          "exact colspan: 6",
          "selection: host app",
          "actions: host app",
          "data-tree-view-empty-state=\"true\"",
          "TreeView still only owns the reusable wrapper hook",
          "Host apps own final recovery"
        ]
      ]
    ]
  }
]

signalGroups.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
