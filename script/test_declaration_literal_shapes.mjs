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
const literalExports = {
  TreeViewEventNames: deepCamelizeKeys(manifest.event_names),
  TreeViewEventDetailKeys: deepCamelizeKeys(manifest.event_detail_keys),
  TreeViewStateChangeReasons: manifest.state_change_reasons,
  TreeViewRemoteStateValues: manifest.remote_state_values,
  TreeViewRemoteStateDataHooks: deepCamelizeKeys(manifest.remote_state_data_hooks),
  TreeViewToolbarDataHooks: deepCamelizeKeys(manifest.toolbar_data_hooks),
  TreeViewTransferDropPositions: manifest.transfer_drop_positions,
  TreeViewTransferDataMimeTypes: deepCamelizeKeys(manifest.transfer_data_mime_types),
  TreeViewControllerIdentifiers: Object.fromEntries(
    manifest.controller_registrations.map(({ key, identifier }) => [key, identifier])
  ),
  TreeViewSelectionDataHooks: deepCamelizeKeys(manifest.selection_data_hooks),
  TreeViewEmptyStateHooks: deepCamelizeKeys(manifest.empty_state_hooks)
}

Object.entries(literalExports).forEach(([exportName, expectedShape]) => {
  assertDeclarationShape(declarationBlock(declarationSource, exportName), expectedShape, [exportName])
})

console.log("TypeScript declaration literal shape smoke passed")
