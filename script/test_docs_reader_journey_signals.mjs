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
    feature: "Tree diagnostics reader journey",
    files: [
      [
        "README.md",
        [
          "Tree identity and diagnostics",
          "docs/en/tree-diagnostics.md",
          "docs/ja/tree-diagnostics.md"
        ]
      ],
      [
        "docs/README.md",
        [
          "en/tree-diagnostics.md",
          "ja/tree-diagnostics.md"
        ]
      ],
      [
        "docs/en/README.md",
        [
          "Tree diagnostics",
          "tree-diagnostics.md",
          "Structure inspection APIs for node keys, DOM IDs, orphans, and cycles",
          "Diagnose symptoms or responsibility boundaries"
        ]
      ],
      [
        "docs/ja/README.md",
        [
          "Tree diagnostics",
          "tree-diagnostics.md",
          "node_key、DOM ID、orphan、cycle などの構造確認 API",
          "症状や責務境界から調べる"
        ]
      ],
      [
        "docs/en/tree-diagnostics.md",
        [
          "TreeView::Diagnostics.run",
          "pre-render validation",
          "Result",
          "data policy"
        ]
      ],
      [
        "docs/ja/tree-diagnostics.md",
        [
          "TreeView::Diagnostics.run",
          "pre-render validation",
          "Result",
          "data policy"
        ]
      ]
    ]
  },
  {
    feature: "Render log level reader journey",
    files: [
      [
        "README.md",
        [
          "docs/en/render-log-level.md",
          "docs/ja/render-log-level.md",
          "accepted values",
          "host app's global Rails logger level"
        ]
      ],
      [
        "docs/README.md",
        [
          "en/render-log-level.md",
          "ja/render-log-level.md",
          "host app's global Rails logger level"
        ]
      ],
      [
        "docs/en/README.md",
        [
          "Render log level",
          "render-log-level.md",
          "Configure TreeView partial render log silencing",
          "TreeView render log verbosity in host app logs"
        ]
      ],
      [
        "docs/ja/README.md",
        [
          "render log レベル",
          "render-log-level.md",
          "TreeView partial render log の抑制設定",
          "host app log 上の TreeView render log"
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
    feature: "Accessibility semantics mockup reader journey",
    files: [
      [
        "docs/en/accessibility-semantics.md",
        [
          "accessibility-semantics.html",
          "table-first ARIA policy",
          "toggle `aria-expanded`",
          "omitted `aria-controls`",
          "host-app-owned page-structure boundaries"
        ]
      ],
      [
        "docs/ja/accessibility-semantics.md",
        [
          "accessibility-semantics.html",
          "table-first ARIA policy",
          "toggle の `aria-expanded`",
          "`aria-controls` 非採用",
          "host-app-owned page structure boundary"
        ]
      ],
      [
        "docs/mockups/accessibility-semantics.html",
        [
          "data-tree-view-sample=\"accessibility-semantics\"",
          "Table-first, not treegrid",
          "aria-controls",
          "host-app decisions"
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
