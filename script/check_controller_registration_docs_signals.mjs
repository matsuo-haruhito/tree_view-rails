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

function assertIncludes(source, needle, label) {
  assert(source.includes(needle), `${label}: missing ${needle}`)
}

const manifest = read("config/public_api_manifest.yml")
const controllerRegistrationDocs = [
  ["docs/en/controller-registration.md", read("docs/en/controller-registration.md")],
  ["docs/ja/controller-registration.md", read("docs/ja/controller-registration.md")]
]

const manifestSignals = [
  "javascript_package_root:",
  "TreeViewControllerEntries",
  "controller_registrations:",
  "key: state",
  "identifier: tree-view-state",
  "export: TreeViewStateController",
  "key: client",
  "identifier: tree-view-client",
  "export: TreeViewClientController",
  "key: selection",
  "identifier: tree-view-selection",
  "export: TreeViewSelectionController",
  "key: transfer",
  "identifier: tree-view-transfer",
  "export: TreeViewTransferController",
  "key: remoteState",
  "identifier: tree-view-remote-state",
  "export: TreeViewRemoteStateController"
]

manifestSignals.forEach((signal) => {
  assertIncludes(manifest, signal, "public API manifest controller registration surface")
})

controllerRegistrationDocs.forEach(([relativePath, document]) => {
  assertIncludes(
    document,
    "registerTreeViewControllers(application)",
    `${relativePath} default registration helper docs`
  )
  assertIncludes(
    document,
    "TreeViewControllerEntries",
    `${relativePath} controller entries export docs`
  )
  assertIncludes(
    document,
    "application.register(identifier, controller)",
    `${relativePath} custom registration example docs`
  )

  assert(
    /state.*client.*selection.*transfer.*remote state/s.test(document),
    `${relativePath}: controller registration docs no longer preserve the documented controller order`
  )

  assert(
    /filter.*reorder.*host app|host app.*filter.*reorder|host app.*boot sequence|host app 側.*boot sequence|host app は entry を filter \/ reorder/.test(document),
    `${relativePath}: controller registration docs no longer preserve the host-app-owned custom boot boundary`
  )

  assert(
    /does not rename identifiers|identifier の rename/.test(document),
    `${relativePath}: controller registration docs no longer state that identifiers and behavior are unchanged`
  )
})
