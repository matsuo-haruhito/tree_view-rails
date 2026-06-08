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
  },
  {
    feature: "Drag/drop visual reference routing",
    files: [
      [
        "docs/en/drag-and-drop.md",
        [
          "drag-interactive-controls.html",
          "interactive-marker-behaviors.html",
          "drop-positions.html",
          "before",
          "inside",
          "after"
        ]
      ],
      [
        "docs/ja/drag-and-drop.md",
        [
          "drag-interactive-controls.html",
          "interactive-marker-behaviors.html",
          "drop-positions.html",
          "before",
          "inside",
          "after"
        ]
      ]
    ]
  },
  {
    feature: "Design policy responsibility and promotion boundaries",
    files: [
      [
        "docs/en/design-policy.md",
        [
          "CRUD",
          "authorization",
          "queries, filtering, and pagination",
          "business behavior remains in the host app",
          "Prefer adding cookbook guidance before adding new rendering DSLs",
          "thin resolver, helper, or configuration object",
          "not coupled to authorization"
        ]
      ],
      [
        "docs/ja/design-policy.md",
        [
          "CRUD",
          "authorization",
          "query / filtering / pagination",
          "業務処理はhost appに残します",
          "まず cookbook として整理することを優先します",
          "薄い resolver、helper、configuration object",
          "authorization、forms、modals、downloads、domain workflows と密結合しない"
        ]
      ]
    ]
  },
  {
    feature: "Node keys and UI identifiers responsibility boundary",
    files: [
      [
        "docs/en/node-keys.md",
        [
          "Tree node key",
          "UI identifier / DOM ID",
          "expanded_keys",
          "collapsed_keys",
          "persisted state",
          "diagnostics",
          "UiConfig"
        ]
      ],
      [
        "docs/ja/node-keys.md",
        [
          "Tree node key",
          "UI識別子 / DOM ID",
          "expanded_keys",
          "collapsed_keys",
          "persisted state",
          "diagnostics",
          "UiConfig"
        ]
      ],
      [
        "docs/en/api-overview.md",
        [
          "Node keys and UI identifiers",
          "Tree node key",
          "UI identifier / DOM ID",
          "expanded_keys",
          "collapsed_keys",
          "Changing a UI DOM ID builder",
          "does not change the keys"
        ]
      ],
      [
        "docs/ja/api-overview.md",
        [
          "node keyとUI識別子",
          "Tree node key",
          "UI識別子 / DOM ID",
          "expanded_keys",
          "collapsed_keys",
          "UI側のDOM ID builderを変更しても",
          "keyは変わりません"
        ]
      ]
    ]
  }
]

signalGroups.forEach(({ feature, files }) => {
  files.forEach(([sourcePath, signals]) => assertSignals(sourcePath, feature, signals))
})
