import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"

function loadJavascriptPackageManifest() {
  const manifestJson = loadManifestJson()

  try {
    return JSON.parse(manifestJson)
  } catch (error) {
    throw new Error(
      [
        "Could not parse config/public_api_manifest.yml javascript_package_root as JSON.",
        "The entrypoint smoke uses Ruby to load YAML and prints that manifest section as JSON before Node assertions run.",
        `Parser error: ${error.message}`
      ].join("\n"),
      { cause: error }
    )
  }
}

function loadManifestJson() {
  try {
    return execFileSync(
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
  } catch (error) {
    const rubyOutput = [error.stdout, error.stderr]
      .filter((output) => output && output.length > 0)
      .join("\n")
      .trim()
    const detail = rubyOutput || error.message

    throw new Error(
      [
        "Could not load config/public_api_manifest.yml for the entrypoint smoke.",
        "Run this command from the repository root with Ruby available, or inspect the manifest YAML around javascript_package_root.",
        `Ruby loader output: ${detail}`
      ].join("\n"),
      { cause: error }
    )
  }
}

function loadDeclarationExportNames() {
  const declarationPath = new URL("../app/javascript/tree_view/index.d.ts", import.meta.url)
  const declarationSource = readFileSync(declarationPath, "utf8")
  const exportPattern = /^export\s+declare\s+(?:class|const|function)\s+([A-Za-z0-9_]+)/gm
  const exportNames = [...declarationSource.matchAll(exportPattern)].map((match) => match[1])

  return [...new Set(exportNames)]
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

function formatValue(value) {
  return JSON.stringify(value)
}

function valueType(value) {
  if (Array.isArray(value)) return "array"
  if (value === null) return "null"

  return typeof value
}

function isPlainObject(value) {
  return value && typeof value === "object" && !Array.isArray(value)
}

function diffValues(expected, actual, path) {
  if (Array.isArray(expected) || Array.isArray(actual)) {
    if (!Array.isArray(expected) || !Array.isArray(actual)) {
      return [`${path}: expected ${valueType(expected)}, actual ${valueType(actual)}`]
    }

    if (JSON.stringify(expected) !== JSON.stringify(actual)) {
      return [`${path}: expected ${formatValue(expected)}, actual ${formatValue(actual)}`]
    }

    return []
  }

  if (isPlainObject(expected) || isPlainObject(actual)) {
    if (!isPlainObject(expected) || !isPlainObject(actual)) {
      return [`${path}: expected ${valueType(expected)}, actual ${valueType(actual)}`]
    }

    const diffs = []
    const expectedKeys = Object.keys(expected)
    const actualKeys = Object.keys(actual)

    expectedKeys
      .filter((key) => !(key in actual))
      .forEach((key) => diffs.push(`${path}.${key}: missing, expected ${formatValue(expected[key])}`))

    actualKeys
      .filter((key) => !(key in expected))
      .forEach((key) => diffs.push(`${path}.${key}: extra, actual ${formatValue(actual[key])}`))

    expectedKeys
      .filter((key) => key in actual)
      .forEach((key) => diffs.push(...diffValues(expected[key], actual[key], `${path}.${key}`)))

    return diffs
  }

  if (expected !== actual) {
    return [`${path}: expected ${formatValue(expected)}, actual ${formatValue(actual)}`]
  }

  return []
}

function assertDeepEqualExport(actual, expected, name) {
  const diffs = diffValues(expected, actual, name)

  assert(
    diffs.length === 0,
    [
      `${name} export is out of sync`,
      ...diffs.slice(0, 10),
      ...(diffs.length > 10 ? [`...and ${diffs.length - 10} more differences`] : [])
    ].join("\n")
  )
}

function assertFrozenObject(value, name, { deep = false } = {}) {
  assert(Object.isFrozen(value), `${name} export is not frozen`)

  if (!deep) return

  Object.entries(value).forEach(([key, item]) => {
    if (item && typeof item === "object") {
      assert(Object.isFrozen(item), `${name}.${key} export group is not frozen`)
    }
  })
}

function assertFrozenEventDetailKeys(value, name) {
  assertFrozenObject(value, name, { deep: true })

  Object.entries(value).forEach(([group, events]) => {
    Object.entries(events).forEach(([eventKey, detailKeys]) => {
      assert(Object.isFrozen(detailKeys), `${name}.${group}.${eventKey} detail key list is not frozen`)
    })
  })
}

function assertUniqueStringList(values, name) {
  assert(Array.isArray(values), `${name} must be an array`)
  assert(values.length > 0, `${name} must not be empty`)

  const seenValues = new Set()

  values.forEach((value) => {
    assert(typeof value === "string" && value.length > 0, `${name} contains a non-string value`)
    assert(!seenValues.has(value), `${name} contains duplicate value: ${value}`)
    seenValues.add(value)
  })
}

function assertEventDetailKeysMatchEventNames(eventNames, eventDetailKeys) {
  Object.entries(eventDetailKeys).forEach(([group, events]) => {
    assert(group in eventNames, `event_detail_keys.${group} does not match an exported event group`)
    assert(events && typeof events === "object" && !Array.isArray(events), `event_detail_keys.${group} must be an object`)

    Object.entries(events).forEach(([eventKey, detailKeys]) => {
      assert(
        eventKey in eventNames[group],
        `event_detail_keys.${group}.${eventKey} does not match an exported event name`
      )
      assertUniqueStringList(detailKeys, `event_detail_keys.${group}.${eventKey}`)
    })
  })
}

function assertEventDetailCoverage(eventNames, eventDetailKeys, eventNamesWithoutDetail) {
  assert(
    eventNamesWithoutDetail && typeof eventNamesWithoutDetail === "object" && !Array.isArray(eventNamesWithoutDetail),
    "event_names_without_detail must be an object"
  )

  Object.entries(eventNamesWithoutDetail).forEach(([group, eventKeys]) => {
    assert(group in eventNames, `event_names_without_detail.${group} does not match an exported event group`)
    assertUniqueStringList(eventKeys, `event_names_without_detail.${group}`)

    eventKeys.forEach((eventKey) => {
      assert(
        eventKey in eventNames[group],
        `event_names_without_detail.${group}.${eventKey} does not match an exported event name`
      )
      assert(
        !(eventKey in (eventDetailKeys[group] || {})),
        `event_names_without_detail.${group}.${eventKey} is also listed in event_detail_keys`
      )
    })
  })

  Object.entries(eventNames).forEach(([group, events]) => {
    Object.keys(events).forEach((eventKey) => {
      const hasDetailKeys = eventKey in (eventDetailKeys[group] || {})
      const isMarkedWithoutDetail = (eventNamesWithoutDetail[group] || []).includes(eventKey)

      assert(
        hasDetailKeys || isMarkedWithoutDetail,
        [
          `event_names.${group}.${eventKey} is not classified for detail coverage`,
          "List it under event_detail_keys when it has documented public detail fields, or under event_names_without_detail when it intentionally has no public detail fields."
        ].join("\n")
      )
    })
  })
}

const javascriptPackageManifest = loadJavascriptPackageManifest()
const entrypointModule = await import(new URL("../app/javascript/tree_view/index.js", import.meta.url).href)

assert(
  typeof entrypointModule.registerTreeViewControllers === "function",
  "registerTreeViewControllers export is missing"
)

const documentedNamedExports = new Set(javascriptPackageManifest.named_exports)
const missingNamedExports = javascriptPackageManifest.named_exports.filter((exportName) => !(exportName in entrypointModule))
assert(
  missingNamedExports.length === 0,
  `named exports are out of sync: ${missingNamedExports.join(", ")}`
)

const undocumentedNamedExports = Object.keys(entrypointModule).filter((exportName) => !documentedNamedExports.has(exportName))
assert(
  undocumentedNamedExports.length === 0,
  [
    `entrypoint exports are missing from config/public_api_manifest.yml: ${undocumentedNamedExports.join(", ")}`,
    "Add the export to javascript_package_root.named_exports and the relevant docs/smoke coverage, or stop exporting it from app/javascript/tree_view/index.js."
  ].join("\n")
)

const declarationExportNames = loadDeclarationExportNames()
const missingDeclarationExports = javascriptPackageManifest.named_exports.filter(
  (exportName) => !declarationExportNames.includes(exportName)
)
const undocumentedDeclarationExports = declarationExportNames.filter(
  (exportName) => !javascriptPackageManifest.named_exports.includes(exportName)
)
assert(
  missingDeclarationExports.length === 0,
  `TypeScript declaration exports are missing manifest exports: ${missingDeclarationExports.join(", ")}`
)
assert(
  undocumentedDeclarationExports.length === 0,
  `TypeScript declaration exports are not listed in the manifest: ${undocumentedDeclarationExports.join(", ")}`
)

const expectedIdentifiers = Object.fromEntries(
  javascriptPackageManifest.controller_registrations.map(({ key, identifier }) => [key, identifier])
)
assert(
  JSON.stringify(entrypointModule.TreeViewControllerIdentifiers) === JSON.stringify(expectedIdentifiers),
  "TreeViewControllerIdentifiers export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewControllerIdentifiers, "TreeViewControllerIdentifiers")

const expectedIntegrationHooks = deepCamelizeKeys(javascriptPackageManifest.integration_hooks)
assertDeepEqualExport(entrypointModule.TreeViewIntegrationHooks, expectedIntegrationHooks, "TreeViewIntegrationHooks")
assertFrozenObject(entrypointModule.TreeViewIntegrationHooks, "TreeViewIntegrationHooks", { deep: true })

const expectedSelectionDataHooks = deepCamelizeKeys(javascriptPackageManifest.selection_data_hooks)
assert(
  JSON.stringify(entrypointModule.TreeViewSelectionDataHooks) === JSON.stringify(expectedSelectionDataHooks),
  "TreeViewSelectionDataHooks export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewSelectionDataHooks, "TreeViewSelectionDataHooks")

const expectedSelectionCheckboxHooks = deepCamelizeKeys(javascriptPackageManifest.selection_checkbox_hooks)
assertDeepEqualExport(
  entrypointModule.TreeViewSelectionCheckboxHooks,
  expectedSelectionCheckboxHooks,
  "TreeViewSelectionCheckboxHooks"
)
assertFrozenObject(entrypointModule.TreeViewSelectionCheckboxHooks, "TreeViewSelectionCheckboxHooks")

const expectedEmptyStateHooks = deepCamelizeKeys(javascriptPackageManifest.empty_state_hooks)
assert(
  JSON.stringify(entrypointModule.TreeViewEmptyStateHooks) === JSON.stringify(expectedEmptyStateHooks),
  "TreeViewEmptyStateHooks export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewEmptyStateHooks, "TreeViewEmptyStateHooks")

const expectedRemoteStateDataHooks = deepCamelizeKeys(javascriptPackageManifest.remote_state_data_hooks)
assertDeepEqualExport(
  entrypointModule.TreeViewRemoteStateDataHooks,
  expectedRemoteStateDataHooks,
  "TreeViewRemoteStateDataHooks"
)
assertFrozenObject(entrypointModule.TreeViewRemoteStateDataHooks, "TreeViewRemoteStateDataHooks")

const expectedToolbarDataHooks = deepCamelizeKeys(javascriptPackageManifest.toolbar_data_hooks)
assertDeepEqualExport(
  entrypointModule.TreeViewToolbarDataHooks,
  expectedToolbarDataHooks,
  "TreeViewToolbarDataHooks"
)
assertFrozenObject(entrypointModule.TreeViewToolbarDataHooks, "TreeViewToolbarDataHooks")

const expectedRegistrations = javascriptPackageManifest.controller_registrations.map(({ identifier, export: exportName }) => {
  assert(exportName in entrypointModule, `${exportName} export is missing`)
  return [identifier, entrypointModule[exportName]]
})

const application = {
  calls: [],
  register(identifier, controller) {
    this.calls.push([identifier, controller])
  }
}

entrypointModule.registerTreeViewControllers(application)
assert(application.calls.length === expectedRegistrations.length, "documented tree_view entrypoint exports are out of sync")
assert(
  expectedRegistrations.every(
    ([identifier, controller], index) =>
      application.calls[index]?.[0] === identifier && application.calls[index]?.[1] === controller
  ),
  "documented tree_view entrypoint exports are out of sync"
)

const expectedEventNames = deepCamelizeKeys(javascriptPackageManifest.event_names)
assertDeepEqualExport(entrypointModule.TreeViewEventNames, expectedEventNames, "TreeViewEventNames")
assertFrozenObject(entrypointModule.TreeViewEventNames, "TreeViewEventNames", { deep: true })

const expectedEventDetailKeys = deepCamelizeKeys(javascriptPackageManifest.event_detail_keys)
assertDeepEqualExport(entrypointModule.TreeViewEventDetailKeys, expectedEventDetailKeys, "TreeViewEventDetailKeys")
assertFrozenEventDetailKeys(entrypointModule.TreeViewEventDetailKeys, "TreeViewEventDetailKeys")
assertEventDetailKeysMatchEventNames(entrypointModule.TreeViewEventNames, entrypointModule.TreeViewEventDetailKeys)

const expectedEventNamesWithoutDetail = deepCamelizeKeys(javascriptPackageManifest.event_names_without_detail)
assertEventDetailCoverage(
  entrypointModule.TreeViewEventNames,
  entrypointModule.TreeViewEventDetailKeys,
  expectedEventNamesWithoutDetail
)

const expectedTransferDropPositions = javascriptPackageManifest.transfer_drop_positions
assertDeepEqualExport(
  entrypointModule.TreeViewTransferDropPositions,
  expectedTransferDropPositions,
  "TreeViewTransferDropPositions"
)
assertFrozenObject(entrypointModule.TreeViewTransferDropPositions, "TreeViewTransferDropPositions")

const expectedTransferDataMimeTypes = deepCamelizeKeys(javascriptPackageManifest.transfer_data_mime_types)
assertDeepEqualExport(
  entrypointModule.TreeViewTransferDataMimeTypes,
  expectedTransferDataMimeTypes,
  "TreeViewTransferDataMimeTypes"
)
assertFrozenObject(entrypointModule.TreeViewTransferDataMimeTypes, "TreeViewTransferDataMimeTypes")

const expectedRemoteStateValues = javascriptPackageManifest.remote_state_values
assert(
  JSON.stringify(entrypointModule.TreeViewRemoteStateValues) === JSON.stringify(expectedRemoteStateValues),
  "TreeViewRemoteStateValues export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewRemoteStateValues, "TreeViewRemoteStateValues")
