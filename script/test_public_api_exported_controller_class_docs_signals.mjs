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

const publicApiDocs = [
  ["docs/en/public-api.md", read("docs/en/public-api.md")],
  ["docs/ja/public-api.md", read("docs/ja/public-api.md")]
]

const exportedControllerClassSignals = [
  "TreeViewStateController",
  "TreeViewClientController",
  "TreeViewSelectionController",
  "TreeViewTransferController",
  "TreeViewRemoteStateController"
]

publicApiDocs.forEach(([relativePath, document]) => {
  assertIncludes(
    document,
    "exported controller classes",
    `${relativePath} exported controller class surface label`
  )

  assertIncludes(
    document,
    "registerTreeViewControllers(application)",
    `${relativePath} standard controller registration entrypoint`
  )

  exportedControllerClassSignals.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} exported controller class docs`)
  })
})

console.log(
  `[public-api-exported-controller-class-docs] checked ${exportedControllerClassSignals.length} controller classes across ${publicApiDocs.length} public API docs`
)
