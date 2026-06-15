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

const readme = read("README.md")
const orientationAsset = read("docs/mockups/assets/readme-default-tree.svg")
const defaultTreeMockup = read("docs/mockups/default-tree.html")

const readmeSignals = [
  "docs/mockups/assets/readme-default-tree.svg",
  "Static TreeView mockup showing expanded and collapsed hierarchy rows",
  "single orientation asset derived from the `default-tree.html` baseline rows",
  "linked mockups for full static review paths and focused state comparisons",
  "docs/mockups/default-tree.html"
]

readmeSignals.forEach((signal) => {
  assert(
    readme.includes(signal),
    `README orientation asset signal is missing ${JSON.stringify(signal)}`
  )
})

assert(
  orientationAsset.trim().startsWith("<svg"),
  "README orientation asset should remain a non-empty SVG file"
)

assert(
  defaultTreeMockup.includes("tree-view-table"),
  "default-tree.html should remain the baseline mockup source for the README orientation asset"
)
