import { existsSync, readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertRelativeLink(sourcePath, href, feature) {
  const source = read(sourcePath)
  const target = href.split("#", 1)[0]
  const resolvedTarget = path.resolve(path.dirname(path.join(repoRoot, sourcePath)), target)

  assert(source.includes(href), `${feature}: ${sourcePath} does not link to ${href}`)
  assert(
    resolvedTarget.startsWith(repoRoot) && existsSync(resolvedTarget),
    `${feature}: ${sourcePath} links to missing local target ${href}`
  )
}

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => {
    assert(
      source.includes(signal),
      `${feature}: ${sourcePath} is missing representative signal ${JSON.stringify(signal)}`
    )
  })
}

const feature = "Breadcrumb docs and visual reference"

;[
  ["README.md", "docs/en/breadcrumb.md"],
  ["README.md", "docs/ja/breadcrumb.md"],
  ["docs/README.md", "en/breadcrumb.md"],
  ["docs/README.md", "ja/breadcrumb.md"],
  ["docs/en/README.md", "breadcrumb.md"],
  ["docs/ja/README.md", "breadcrumb.md"],
  ["docs/en/breadcrumb.md", "../mockups/breadcrumb-paths.html"],
  ["docs/ja/breadcrumb.md", "../mockups/breadcrumb-paths.html"],
  ["docs/mockups/README.md", "breadcrumb-paths.html"]
].forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))

assertSignals("docs/en/breadcrumb.md", feature, [
  "tree_view_breadcrumb(tree, item, ...)",
  "label_builder:",
  "path_builder:",
  "records-mode",
  "helper_option_keys.tree_view_breadcrumb",
  "host app remains responsible for routes, authorization",
  "layout placement",
  "breadcrumb-paths.html"
])

assertSignals("docs/ja/breadcrumb.md", feature, [
  "tree_view_breadcrumb(tree, item, ...)",
  "label_builder:",
  "path_builder:",
  "records mode",
  "helper_option_keys.tree_view_breadcrumb",
  "route、認可、現在nodeの決定",
  "layout",
  "breadcrumb-paths.html"
])

assertSignals("docs/mockups/README.md", feature, [
  "breadcrumb-paths.html",
  "breadcrumb-path context",
  "current-row cue",
  "without modeling host-app routes or Turbo navigation"
])
