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
    feature: "FAQ host responsibility boundary",
    files: [
      [
        "docs/en/faq.md",
        ["host app", "records, controllers, forms, routes, authorization", "queries"]
      ],
      ["docs/ja/faq.md", ["host app", "authorization", "query"]]
    ]
  },
  {
    feature: "Troubleshooting host responsibility boundary",
    files: [
      [
        "docs/en/troubleshooting.md",
        ["host app still owns routes", "authorization", "business actions"]
      ],
      [
        "docs/ja/troubleshooting.md",
        ["routes、controller action、authorization、query", "business action", "host app の責務"]
      ]
    ]
  },
  {
    feature: "Troubleshooting JavaScript event reverse lookup",
    files: [
      [
        "docs/en/troubleshooting.md",
        [
          "tree-view-selection:invalid-payload",
          "tree-view-remote-state:retry",
          "js-events.md#tree-view-remote-stateretry",
          "js-events.md#transfer-events"
        ]
      ],
      [
        "docs/ja/troubleshooting.md",
        [
          "tree-view-selection:invalid-payload",
          "tree-view-remote-state:retry",
          "js-events.md#tree-view-remote-stateretry",
          "js-events.md#transfer-events"
        ]
      ]
    ]
  },
  {
    feature: "Demo application boundary direct-link policy",
    files: [
      [
        "README.md",
        ["docs/en/demo-application-boundary.md", "docs/ja/demo-application-boundary.md"]
      ],
      [
        "docs/README.md",
        ["en/demo-application-boundary.md", "ja/demo-application-boundary.md"]
      ],
      [
        "docs/en/demo-application-boundary.md",
        [
          "Do not add a direct demo repository link",
          "static mockups",
          "real Rails demo application",
          "Publication checklist"
        ]
      ],
      [
        "docs/ja/demo-application-boundary.md",
        [
          "demo repository へ直接 link しません",
          "static mockup",
          "real Rails demo application",
          "Publication checklist"
        ]
      ]
    ]
  }
]

signalGroups.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
