import { execFileSync } from "node:child_process"

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

function assertFrozenObject(value, name, { deep = false } = {}) {
  assert(Object.isFrozen(value), `${name} export is not frozen`)

  if (!deep) return

  Object.entries(value).forEach(([key, item]) => {
    if (item && typeof item === "object") {
      assert(Object.isFrozen(item), `${name}.${key} export group is not frozen`)
    }
  })
}

const javascriptPackageManifest = loadJavascriptPackageManifest()
const entrypointModule = await import(new URL("../app/javascript/tree_view/index.js", import.meta.url).href)

assert(
  typeof entrypointModule.registerTreeViewControllers === "function",
  "registerTreeViewControllers export is missing"
)

const missingNamedExports = javascriptPackageManifest.named_exports.filter((exportName) => !(exportName in entrypointModule))
assert(
  missingNamedExports.length === 0,
  `named exports are out of sync: ${missingNamedExports.join(", ")}`
)

const expectedIdentifiers = Object.fromEntries(
  javascriptPackageManifest.controller_registrations.map(({ key, identifier }) => [key, identifier])
)
assert(
  JSON.stringify(entrypointModule.TreeViewControllerIdentifiers) === JSON.stringify(expectedIdentifiers),
  "TreeViewControllerIdentifiers export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewControllerIdentifiers, "TreeViewControllerIdentifiers")

const expectedSelectionDataHooks = deepCamelizeKeys(javascriptPackageManifest.selection_data_hooks)
assert(
  JSON.stringify(entrypointModule.TreeViewSelectionDataHooks) === JSON.stringify(expectedSelectionDataHooks),
  "TreeViewSelectionDataHooks export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewSelectionDataHooks, "TreeViewSelectionDataHooks")

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
assert(
  JSON.stringify(entrypointModule.TreeViewEventNames) === JSON.stringify(expectedEventNames),
  "TreeViewEventNames export is out of sync"
)
assertFrozenObject(entrypointModule.TreeViewEventNames, "TreeViewEventNames", { deep: true })
assertFrozenObject(entrypointModule.TreeViewTransferDropPositions, "TreeViewTransferDropPositions")