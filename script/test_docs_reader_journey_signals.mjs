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
