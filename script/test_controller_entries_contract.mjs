import { execFileSync } from "node:child_process"

function loadJavascriptPackageManifest() {
  try {
    return JSON.parse(
      execFileSync(
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
    )
  } catch (error) {
    const rubyOutput = [error.stdout, error.stderr]
      .filter((output) => output && output.length > 0)
      .join("\n")
      .trim()
    const detail = rubyOutput || error.message

    throw new Error(
      [
        "Could not load config/public_api_manifest.yml for the controller entries contract smoke.",
        "Run this command from the repository root with Ruby available, or inspect javascript_package_root.controller_registrations.",
        `Loader output: ${detail}`
      ].join("\n"),
      { cause: error }
    )
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertControllerEntry(entry, expected, index) {
  const label = `TreeViewControllerEntries[${index}] (${expected.key})`

  assert(entry && typeof entry === "object" && !Array.isArray(entry), `${label} must be an object entry`)
  assert(Object.isFrozen(entry), `${label} is not frozen`)
  assert(entry.key === expected.key, `${label} key drift: expected ${expected.key}, actual ${entry.key}`)
  assert(
    entry.identifier === expected.identifier,
    `${label} identifier drift: expected ${expected.identifier}, actual ${entry.identifier}`
  )
  assert(
    entry.controller === expected.controller,
    `${label} controller drift: expected ${expected.exportName}, actual controller reference changed`
  )
}

const javascriptPackageManifest = loadJavascriptPackageManifest()
const entrypointModule = await import(new URL("../app/javascript/tree_view/index.js", import.meta.url).href)

const expectedEntries = javascriptPackageManifest.controller_registrations.map(
  ({ key, identifier, export: exportName }) => {
    assert(exportName in entrypointModule, `${exportName} export is missing for controller entry ${key}`)

    return {
      key,
      identifier,
      exportName,
      controller: entrypointModule[exportName]
    }
  }
)

const actualEntries = entrypointModule.TreeViewControllerEntries
assert(Array.isArray(actualEntries), "TreeViewControllerEntries must be an array")
assert(Object.isFrozen(actualEntries), "TreeViewControllerEntries array is not frozen")
assert(
  actualEntries.length === expectedEntries.length,
  `TreeViewControllerEntries count drift: expected ${expectedEntries.length}, actual ${actualEntries.length}`
)

expectedEntries.forEach((expected, index) => {
  assertControllerEntry(actualEntries[index], expected, index)
})

const application = {
  calls: [],
  register(identifier, controller) {
    this.calls.push([identifier, controller])
  }
}

entrypointModule.registerTreeViewControllers(application)
assert(
  application.calls.length === actualEntries.length,
  `registerTreeViewControllers call count drift: expected ${actualEntries.length}, actual ${application.calls.length}`
)

actualEntries.forEach((entry, index) => {
  const [identifier, controller] = application.calls[index] || []
  const label = `registerTreeViewControllers call ${index + 1} (${entry.key})`

  assert(
    identifier === entry.identifier,
    `${label} identifier drift: expected ${entry.identifier}, actual ${identifier}`
  )
  assert(
    controller === entry.controller,
    `${label} controller drift: expected TreeViewControllerEntries.${entry.key}.controller`
  )
})
