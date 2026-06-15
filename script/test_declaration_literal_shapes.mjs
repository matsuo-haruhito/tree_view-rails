import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"

function loadJavascriptPackageManifest() {
  const manifestJson = execFileSync(
    "ruby",
    [
      "-e",
      [
        'require "json"',
        'require "yaml"',
        'data = YAML.load_file("config/public_api_manifest.yml")',
        'print JSON.generate(data.fetch("javascript_package_root"))'
      ].join("; ")
    ],
    { encoding: "utf8" }
  )

  return JSON.parse(manifestJson)
}

function camelizeKey(value) {
  return value.replace(/_([a-z])/g, (_match, character) => character.toUpperCase())
}

function deepCamelizeKeys(value) {
  if (Array.isArray(value)) return value.map((item) => deepCamelizeKeys(item))
  if (value && typeof value === "object") {
    return Object.fromEntries(
      Object.entries(value).map(([key, item]) => [camelizeKey(key), deepCamelizeKeys(item)])
    )
  }

  return value
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function declarationBlock(declarationSource, exportName) {
  const marker = `export declare const ${exportName}:`
  const start = declarationSource.indexOf(marker)
  assert(start !== -1, `${exportName} declaration is missing`)

  const nextExport = declarationSource.indexOf("\n\nexport declare", start + marker.length)
  return nextExport === -1 ? declarationSource.slice(start) : declarationSource.slice(start, nextExport)
}

function escapeRegExp(value) {
  return String(value).replace(/[\\^$.*+?()[\]{}|]/g, "\\$&")
}

function assertBlockContains(block, pattern, message) {
  assert(pattern.test(block), message)
}

function assertSameMembers(actual, expected, message) {
  const actualSet = new Set(actual)
  const expectedSet = new Set(expected)
  const missing = expected.filter((item) => !actualSet.has(item))
  const unexpected = actual.filter((item) => !expectedSet.has(item))

  assert(
    missing.length === 0 && unexpected.length === 0,
    [
      message,
      missing.length > 0 ? `Missing: ${missing.join(", ")}` : null,
      unexpected.length > 0 ? `Unexpected: ${unexpected.join(", ")}` : null
    ].filter(Boolean).join("\n")
  )
}

function assertDeclarationShape(block, expectedValue, path = []) {
  Object.entries(expectedValue).forEach(([key, value]) => {
    const currentPath = [...path, key]
    const keyPattern = escapeRegExp(key)

    if (Array.isArray(value)) {
      const tupleBody = value.map((item) => `"${escapeRegExp(item)}"`).join(", ")
      assertBlockContains(
        block,
        new RegExp(`${keyPattern}:\\s+readonly \\[${tupleBody}\\]`),
        `${currentPath.join(".")} tuple declaration is out of sync`
      )
      return
    }

    if (value && typeof value === "object") {
      assertBlockContains(
        block,
        new RegExp(`${keyPattern}:\\s+Readonly<\\{`),
        `${currentPath.join(".")} object declaration is missing`
      )
      assertDeclarationShape(block, value, currentPath)
      return
    }

    assertBlockContains(
      block,
      new RegExp(`${keyPattern}:\\s+"${escapeRegExp(value)}"`),
      `${currentPath.join(".")} literal declaration is out of sync`
    )
  })
}

const manifest = loadJavascriptPackageManifest()
const declarationSource = readFileSync("app/javascript/tree_view/index.d.ts", "utf8")
const nonLiteralManifestGroups = new Set([
  "named_exports",
  "controller_registrations",
  "event_names_without_detail"
])
const expectedManifestLiteralGroups = Object.keys(manifest)
  .filter((manifestGroup) => !nonLiteralManifestGroups.has(manifestGroup))
  .sort()
const literalExportsByManifestGroup = {
  event_names: {
    exportName: "TreeViewEventNames",
    expectedShape: deepCamelizeKeys(manifest.event_names)
  },
  event_detail_keys: {
    exportName: "TreeViewEventDetailKeys",
    expectedShape: deepCamelizeKeys(manifest.event_detail_keys)
  },
  remote_state_values: {
    exportName: "TreeViewRemoteStateValues",
    expectedShape: manifest.remote_state_values
  },
  remote_state_data_hooks: {
    exportName: "TreeViewRemoteStateDataHooks",
    expectedShape: deepCamelizeKeys(manifest.remote_state_data_hooks)
  },
  toolbar_data_hooks: {
    exportName: "TreeViewToolbarDataHooks",
    expectedShape: deepCamelizeKeys(manifest.toolbar_data_hooks)
  },
  transfer_drop_positions: {
    exportName: "TreeViewTransferDropPositions",
    expectedShape: manifest.transfer_drop_positions
  },
  transfer_data_mime_types: {
    exportName: "TreeViewTransferDataMimeTypes",
    expectedShape: deepCamelizeKeys(manifest.transfer_data_mime_types)
  },
  integration_hooks: {
    exportName: "TreeViewIntegrationHooks",
    expectedShape: deepCamelizeKeys(manifest.integration_hooks)
  },
  selection_data_hooks: {
    exportName: "TreeViewSelectionDataHooks",
    expectedShape: deepCamelizeKeys(manifest.selection_data_hooks)
  },
  selection_checkbox_hooks: {
    exportName: "TreeViewSelectionCheckboxHooks",
    expectedShape: deepCamelizeKeys(manifest.selection_checkbox_hooks)
  },
  empty_state_hooks: {
    exportName: "TreeViewEmptyStateHooks",
    expectedShape: deepCamelizeKeys(manifest.empty_state_hooks)
  }
}
const controllerRegistrationExports = {
  TreeViewControllerIdentifiers: Object.fromEntries(
    manifest.controller_registrations.map(({ key, identifier }) => [key, identifier])
  )
}

assertSameMembers(
  Object.keys(literalExportsByManifestGroup),
  expectedManifestLiteralGroups,
  "script/test_declaration_literal_shapes.mjs must cover every javascript_package_root literal export group"
)

Object.values(literalExportsByManifestGroup).forEach(({ exportName, expectedShape }) => {
  assertDeclarationShape(declarationBlock(declarationSource, exportName), expectedShape, [exportName])
})

Object.entries(controllerRegistrationExports).forEach(([exportName, expectedShape]) => {
  assertDeclarationShape(declarationBlock(declarationSource, exportName), expectedShape, [exportName])
})

console.log("TypeScript declaration literal shape smoke passed")
