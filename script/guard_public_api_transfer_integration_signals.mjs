import fs from "node:fs"

const manifest = fs.readFileSync("config/public_api_manifest.yml", "utf8")
const publicApiDocs = [
  ["docs/en/public-api.md", fs.readFileSync("docs/en/public-api.md", "utf8")],
  ["docs/ja/public-api.md", fs.readFileSync("docs/ja/public-api.md", "utf8")]
]
const dragAndDropDocs = [
  [
    "docs/en/drag-and-drop.md",
    fs.readFileSync("docs/en/drag-and-drop.md", "utf8"),
    ["persistence"]
  ],
  [
    "docs/ja/drag-and-drop.md",
    fs.readFileSync("docs/ja/drag-and-drop.md", "utf8"),
    ["保存"]
  ]
]

const requiredManifestSignals = [
  "transfer_drop_positions:",
  "before: before",
  "inside: inside",
  "after: after",
  "integration_hooks:",
  "view_key_value: data-tree-view-state-view-key-value",
  "node_key: data-tree-view-state-node-key",
  "children_url: data-tree-children-url",
  "payload: data-tree-transfer-payload"
]

const requiredPublicApiSignals = [
  "TreeViewTransferDropPositions",
  "before",
  "inside",
  "after",
  "TreeViewIntegrationHooks",
  "state.viewKeyValue",
  "state.nodeKey",
  "remoteState.childrenUrl",
  "transfer.payload",
  "TreeViewRemoteStateDataHooks.childrenUrlAttribute",
  "TreeViewIntegrationHooks.remoteState.childrenUrl",
  "data-tree-children-url"
]

const requiredDragAndDropSignals = [
  "TreeViewTransferDropPositions",
  "TreeViewEventNames.transfer.*",
  "TreeViewEventDetailKeys.transfer.*",
  "before",
  "inside",
  "after",
  "position",
  "authorization",
  "TreeViewIntegrationHooks.transfer.payload",
  "data-tree-transfer-payload"
]

const missingSignals = []

for (const signal of requiredManifestSignals) {
  if (!manifest.includes(signal)) {
    missingSignals.push(`config/public_api_manifest.yml: ${signal}`)
  }
}

for (const [docPath, doc] of publicApiDocs) {
  for (const signal of requiredPublicApiSignals) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: ${signal}`)
    }
  }
}

for (const [docPath, doc, localizedSignals] of dragAndDropDocs) {
  for (const signal of [...requiredDragAndDropSignals, ...localizedSignals]) {
    if (!doc.includes(signal)) {
      missingSignals.push(`${docPath}: ${signal}`)
    }
  }
}

if (missingSignals.length > 0) {
  console.error("[public-api-transfer-integration-signals] missing documentation signals:")
  for (const signal of missingSignals) {
    console.error(`- ${signal}`)
  }
  process.exit(1)
}

console.log(
  `[public-api-transfer-integration-signals] ${requiredManifestSignals.length} manifest signals, ${requiredPublicApiSignals.length} Public API signals, and ${requiredDragAndDropSignals.length} Drag and Drop signals are present`
)
