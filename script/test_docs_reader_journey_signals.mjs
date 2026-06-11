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
    feature: "Decision guide reader journey",
    files: [
      [
        "docs/en/decision-guide.md",
        [
          "Render controls",
          "Data-loading controls",
          "GraphAdapter",
          "reverse_tree_for",
          "Filtered Trees",
          "Lazy Loading",
          "Children Pagination",
          "RenderWindow",
          "Selection",
          "Toolbar helper",
          "Recommended path by project stage",
          "Common combinations"
        ]
      ],
      [
        "docs/ja/decision-guide.md",
        [
          "描画制御",
          "データ読み込み制御",
          "GraphAdapter",
          "reverse_tree_for",
          "Filtered Trees",
          "Lazy Loading",
          "Children Pagination",
          "RenderWindow",
          "Selection",
          "Toolbar helper",
          "project stageごとのおすすめ順",
          "よくある組み合わせ"
        ]
      ]
    ]
  },
  {
    feature: "Language README user journey",
    files: [
      [
        "docs/en/README.md",
        [
          "For users",
          "Goal-based shortcuts",
          "Set up TreeView for the first time",
          "Choose the right API or rendering mode",
          "Render large or partial trees",
          "Diagnose symptoms or responsibility boundaries",
          "Installation",
          "Minimal usage",
          "Usage",
          "Decision guide",
          "Troubleshooting",
          "FAQ",
          "Visual reference mockups",
          "Demo application boundary",
          "Reading order"
        ]
      ],
      [
        "docs/ja/README.md",
        [
          "利用者向け",
          "目的別ショートカット",
          "初めて TreeView を導入する",
          "使う API や描画方式を選ぶ",
          "大きな tree や一部描画を扱う",
          "症状や責務境界から調べる",
          "導入手順",
          "最小利用例",
          "使い方",
          "API判断ガイド",
          "トラブルシューティング",
          "FAQ",
          "視覚リファレンス mockup",
          "Demo application boundary",
          "読む順番"
        ]
      ]
    ]
  },
  {
    feature: "Selection and children pagination unloaded descendants boundary",
    files: [
      [
        "docs/en/selection.md",
        [
          "DOM-based",
          "rendered rows only",
          "unloaded descendants",
          "server-side intent or query filter",
          "Children Pagination",
          "children-pagination-selection-boundary.html"
        ]
      ],
      [
        "docs/ja/selection.md",
        [
          "DOMベース",
          "描画済み行だけ",
          "unloaded descendants",
          "server-side intent",
          "Children Pagination",
          "children-pagination-selection-boundary.html"
        ]
      ],
      [
        "docs/en/children-pagination.md",
        [
          "Selection and drag/drop interactions",
          "unloaded descendants",
          "server-side selection intent",
          "query-backed actions",
          "DOM-submitted checkbox values",
          "Selection](selection.md#linked-checkbox-behavior)",
          "children-pagination-selection-boundary.html"
        ]
      ],
      [
        "docs/ja/children-pagination.md",
        [
          "selection / drag-drop との相互作用",
          "unloaded descendants",
          "server-side selection intent",
          "query-backed action",
          "DOMから送られるcheckbox値",
          "Selection](selection.md#連動checkbox挙動)",
          "children-pagination-selection-boundary.html"
        ]
      ]
    ]
  },
  {
    feature: "Mockup README smoke and review policy",
    files: [
      [
        "docs/mockups/README.md",
        [
          "Automated smoke coverage",
          "npm run test:browser",
          "review gallery",
          "local links",
          "representative sample regions",
          "without adding screenshot baselines or visual diff review",
          "Review policy",
          "static HTML/CSS",
          "product-neutral",
          "source HTML/CSS should remain the canonical mockup",
          "playground app"
        ]
      ]
    ]
  }
]

signalGroups.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
