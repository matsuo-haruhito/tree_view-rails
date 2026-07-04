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

const docs = [
  ["docs/en/public-api-immutable-exports.md", read("docs/en/public-api-immutable-exports.md")],
  ["docs/ja/public-api-immutable-exports.md", read("docs/ja/public-api-immutable-exports.md")]
]

const publicApiDocs = [
  ["docs/en/public-api.md", read("docs/en/public-api.md")],
  ["docs/ja/public-api.md", read("docs/ja/public-api.md")]
]

const representativeExports = [
  "TreeViewEventNames",
  "TreeViewEventDetailKeys",
  "TreeViewRemoteStateValues",
  "TreeViewStateChangeReasons",
  "TreeViewTransferDropPositions"
]

const representativeHookObjects = [
  "TreeViewRemoteStateDataHooks",
  "TreeViewToolbarDataHooks",
  "TreeViewSelectionDataHooks",
  "TreeViewSelectionCheckboxHooks",
  "TreeViewEmptyStateHooks"
]

docs.forEach(([relativePath, document]) => {
  assertIncludes(document, "immutable reference constants", `${relativePath} immutable export contract`)
  assertIncludes(document, "Object.isFrozen", `${relativePath} runtime frozen guard route`)
  assertIncludes(document, "script/test_entrypoints.mjs", `${relativePath} runtime guard script route`)
  assertIncludes(document, "script/test_declaration_literal_shapes.mjs", `${relativePath} declaration-shape guard route`)
  assertIncludes(document, "Public API", `${relativePath} public API route`)

  representativeExports.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} representative immutable export docs`)
  })

  representativeHookObjects.forEach((signal) => {
    assertIncludes(document, signal, `${relativePath} representative data hook object docs`)
  })

  assert(
    /Do not mutate these objects|mutate する設定 object ではありません/.test(document),
    `${relativePath}: immutable export docs no longer warn that host apps must not mutate package-root constants`
  )

  assert(
    /does not change runtime values|runtime value.*変更しません/.test(document),
    `${relativePath}: immutable export docs no longer separate reader-facing guidance from runtime values`
  )
})

publicApiDocs.forEach(([relativePath, document]) => {
  assertIncludes(document, "public-api-immutable-exports.md", `${relativePath} immutable export guide route`)
  assertIncludes(document, "TreeViewEventNames", `${relativePath} package-root event constants route`)
  assertIncludes(document, "TreeViewEventDetailKeys", `${relativePath} package-root detail-key constants route`)
  assertIncludes(document, "data hook", `${relativePath} package-root data-hook object route`)
})
