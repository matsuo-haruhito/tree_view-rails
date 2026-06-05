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

  assert(
    source.includes(href),
    `${feature}: ${sourcePath} does not link to ${href}`
  )
  assert(
    resolvedTarget.startsWith(repoRoot) && existsSync(resolvedTarget),
    `${feature}: ${sourcePath} links to missing local target ${href}`
  )
}

const rootReadme = read("README.md")

const featureEntrypoints = [
  {
    feature: "GraphAdapter",
    rootPattern: /Use `GraphAdapter`/,
    links: [
      ["docs/README.md", "en/graph-adapter.md"],
      ["docs/README.md", "ja/graph-adapter.md"]
    ]
  },
  {
    feature: "PathTreeBuilder",
    rootPattern: /PathTreeBuilder/,
    links: [
      ["docs/README.md", "en/path-tree-builder.md"],
      ["docs/README.md", "ja/path-tree-builder.md"],
      ["docs/en/README.md", "path-tree-builder.md"],
      ["docs/ja/README.md", "path-tree-builder.md"]
    ]
  },
  {
    feature: "ReverseTree",
    rootPattern: /ReverseTree/,
    links: [
      ["docs/README.md", "en/reverse-tree.md"],
      ["docs/README.md", "ja/reverse-tree.md"],
      ["docs/en/README.md", "reverse-tree.md"],
      ["docs/ja/README.md", "reverse-tree.md"]
    ]
  },
  {
    feature: "VisibleRows / RenderWindow",
    rootPattern: /VisibleRows[\s\S]*RenderWindow|RenderWindow[\s\S]*VisibleRows/,
    links: [
      ["docs/README.md", "en/windowed-rendering.md"],
      ["docs/README.md", "ja/windowed-rendering.md"],
      ["docs/en/README.md", "windowed-rendering.md"],
      ["docs/ja/README.md", "windowed-rendering.md"]
    ]
  },
  {
    feature: "Filtered Trees",
    rootPattern: /Filtered Trees/,
    links: [
      ["README.md", "docs/en/filtered-trees.md"],
      ["README.md", "docs/ja/filtered-trees.md"],
      ["docs/README.md", "en/filtered-trees.md"],
      ["docs/README.md", "ja/filtered-trees.md"],
      ["docs/en/README.md", "filtered-trees.md"],
      ["docs/ja/README.md", "filtered-trees.md"]
    ]
  },
  {
    feature: "Render Scale strategy",
    rootPattern: /Render Scale[\s\S]*Lazy Loading[\s\S]*Children Pagination/,
    links: [
      ["README.md", "docs/en/render-scale.md"],
      ["README.md", "docs/en/lazy-loading.md"],
      ["README.md", "docs/en/children-pagination.md"],
      ["docs/README.md", "en/lazy-loading.md"],
      ["docs/README.md", "ja/lazy-loading.md"],
      ["docs/README.md", "en/windowed-rendering.md"],
      ["docs/README.md", "ja/windowed-rendering.md"],
      ["docs/README.md", "en/children-pagination.md"],
      ["docs/README.md", "ja/children-pagination.md"],
      ["docs/en/README.md", "render-scale.md"],
      ["docs/en/README.md", "lazy-loading.md"],
      ["docs/en/README.md", "windowed-rendering.md"],
      ["docs/en/README.md", "children-pagination.md"],
      ["docs/ja/README.md", "render-scale.md"],
      ["docs/ja/README.md", "lazy-loading.md"],
      ["docs/ja/README.md", "windowed-rendering.md"],
      ["docs/ja/README.md", "children-pagination.md"]
    ]
  },
  {
    feature: "Selection",
    rootPattern: /checkbox selection|selection hooks/i,
    links: [
      ["docs/README.md", "en/selection.md"],
      ["docs/README.md", "ja/selection.md"],
      ["docs/en/README.md", "selection.md"],
      ["docs/ja/README.md", "selection.md"]
    ]
  },
  {
    feature: "Persisted State",
    rootPattern: /PersistedState|StateStore|Persisted State/,
    links: [
      ["docs/README.md", "en/persisted-state.md"],
      ["docs/README.md", "ja/persisted-state.md"],
      ["docs/en/README.md", "persisted-state.md"],
      ["docs/ja/README.md", "persisted-state.md"]
    ]
  },
  {
    feature: "Render log level",
    rootPattern: /render log silencing|render_log_level/i,
    links: [
      ["README.md", "docs/en/render-log-level.md"],
      ["README.md", "docs/ja/render-log-level.md"],
      ["docs/en/README.md", "render-log-level.md"],
      ["docs/ja/README.md", "render-log-level.md"]
    ]
  },
  {
    feature: "JavaScript controllers and events",
    rootPattern: /Register JavaScript controllers/,
    links: [
      ["docs/README.md", "en/public-api.md"],
      ["docs/README.md", "ja/public-api.md"],
      ["docs/en/README.md", "js-events.md"],
      ["docs/ja/README.md", "js-events.md"]
    ]
  },
  {
    feature: "Visual reference mockups",
    rootPattern: /TreeView mockups|Visual reference mockups/,
    links: [
      ["README.md", "docs/mockups/README.md"],
      ["README.md", "docs/mockups/review-gallery.html"],
      ["docs/README.md", "mockups/README.md"],
      ["docs/en/README.md", "../mockups/README.md"],
      ["docs/ja/README.md", "../mockups/README.md"]
    ]
  }
]

const maintainerEntrypoints = [
  {
    feature: "Maintainer release docs",
    links: [
      ["docs/README.md", "en/release.md"],
      ["docs/README.md", "ja/release.md"],
      ["docs/en/README.md", "release.md"],
      ["docs/ja/README.md", "release.md"],
      ["docs/README.md", "../CHANGELOG.md"],
      ["docs/en/README.md", "../../CHANGELOG.md"],
      ["docs/ja/README.md", "../../CHANGELOG.md"]
    ]
  },
  {
    feature: "Maintainer development docs",
    links: [
      ["docs/README.md", "en/development.md"],
      ["docs/README.md", "ja/development.md"],
      ["docs/en/README.md", "development.md"],
      ["docs/ja/README.md", "development.md"],
      ["docs/README.md", "en/code-quality.md"],
      ["docs/README.md", "ja/code-quality.md"],
      ["docs/en/README.md", "code-quality.md"],
      ["docs/ja/README.md", "code-quality.md"]
    ]
  }
]

featureEntrypoints.forEach(({ feature, rootPattern, links }) => {
  assert(rootPattern.test(rootReadme), `${feature}: README.md no longer exposes the representative feature signal`)

  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
})

maintainerEntrypoints.forEach(({ feature, links }) => {
  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
})
