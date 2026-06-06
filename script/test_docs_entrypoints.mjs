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

function assertRootSignal(feature, rootPattern, message) {
  if (!rootPattern) return

  assert(rootPattern.test(rootReadme), `${feature}: ${message}`)
}

const rootReadme = read("README.md")

const foundationalEntrypoints = [
  {
    feature: "First-time setup docs",
    rootPattern: /Installation[\s\S]*Minimal usage[\s\S]*Usage/,
    links: [
      ["README.md", "docs/en/installation.md"],
      ["README.md", "docs/ja/installation.md"],
      ["README.md", "docs/en/minimal-usage.md"],
      ["README.md", "docs/ja/minimal-usage.md"],
      ["README.md", "docs/en/usage.md"],
      ["README.md", "docs/ja/usage.md"],
      ["docs/README.md", "en/installation.md"],
      ["docs/README.md", "ja/installation.md"],
      ["docs/README.md", "en/minimal-usage.md"],
      ["docs/README.md", "ja/minimal-usage.md"],
      ["docs/README.md", "en/usage.md"],
      ["docs/README.md", "ja/usage.md"],
      ["docs/en/README.md", "installation.md"],
      ["docs/en/README.md", "minimal-usage.md"],
      ["docs/en/README.md", "usage.md"],
      ["docs/ja/README.md", "installation.md"],
      ["docs/ja/README.md", "minimal-usage.md"],
      ["docs/ja/README.md", "usage.md"]
    ]
  },
  {
    feature: "Decision guide docs",
    rootPattern: /Decision guide|API判断ガイド/,
    links: [
      ["README.md", "docs/en/decision-guide.md"],
      ["README.md", "docs/ja/decision-guide.md"],
      ["docs/README.md", "en/decision-guide.md"],
      ["docs/README.md", "ja/decision-guide.md"],
      ["docs/en/README.md", "decision-guide.md"],
      ["docs/ja/README.md", "decision-guide.md"]
    ]
  },
  {
    feature: "FAQ and troubleshooting docs",
    rootPattern: /FAQ[\s\S]*Troubleshooting|Troubleshooting[\s\S]*FAQ/,
    links: [
      ["README.md", "docs/en/faq.md"],
      ["README.md", "docs/ja/faq.md"],
      ["README.md", "docs/en/troubleshooting.md"],
      ["README.md", "docs/ja/troubleshooting.md"],
      ["docs/README.md", "en/faq.md"],
      ["docs/README.md", "ja/faq.md"],
      ["docs/README.md", "en/troubleshooting.md"],
      ["docs/README.md", "ja/troubleshooting.md"],
      ["docs/en/README.md", "faq.md"],
      ["docs/en/README.md", "troubleshooting.md"],
      ["docs/ja/README.md", "faq.md"],
      ["docs/ja/README.md", "troubleshooting.md"]
    ]
  }
]

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
    feature: "Turbo Frame option",
    rootPattern: /Turbo Frame option/,
    links: [
      ["README.md", "docs/en/turbo-frame.md"],
      ["README.md", "docs/ja/turbo-frame.md"],
      ["docs/README.md", "en/turbo-frame.md"],
      ["docs/README.md", "ja/turbo-frame.md"],
      ["docs/en/README.md", "turbo-frame.md"],
      ["docs/ja/README.md", "turbo-frame.md"]
    ]
  },
  {
    feature: "Selection",
    rootPattern: /checkbox selection|selection hooks/i,
    links: [
      ["README.md", "docs/en/selection.md"],
      ["README.md", "docs/ja/selection.md"],
      ["docs/README.md", "en/selection.md"],
      ["docs/README.md", "ja/selection.md"],
      ["docs/en/README.md", "selection.md"],
      ["docs/ja/README.md", "selection.md"]
    ]
  },
  {
    feature: "Toolbar helper",
    rootPattern: /tree_view_toolbar|Toolbar helper/,
    links: [
      ["README.md", "docs/en/toolbar.md"],
      ["README.md", "docs/ja/toolbar.md"],
      ["docs/en/README.md", "toolbar.md"],
      ["docs/ja/README.md", "toolbar.md"]
    ]
  },
  {
    feature: "Breadcrumb helper",
    links: [
      ["docs/en/README.md", "breadcrumb.md"],
      ["docs/ja/README.md", "breadcrumb.md"]
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
    feature: "Drag and Drop / Host App Extension Points",
    rootPattern: /Drag and drop[\s\S]*Host app extension boundary|Host app extension boundary[\s\S]*Drag and drop/i,
    links: [
      ["README.md", "docs/en/drag-and-drop.md"],
      ["README.md", "docs/ja/drag-and-drop.md"],
      ["README.md", "docs/en/host-app-extension-points.md"],
      ["README.md", "docs/ja/host-app-extension-points.md"],
      ["docs/README.md", "en/drag-and-drop.md"],
      ["docs/README.md", "ja/drag-and-drop.md"],
      ["docs/README.md", "en/host-app-extension-points.md"],
      ["docs/README.md", "ja/host-app-extension-points.md"],
      ["docs/en/README.md", "drag-and-drop.md"],
      ["docs/en/README.md", "host-app-extension-points.md"],
      ["docs/ja/README.md", "drag-and-drop.md"],
      ["docs/ja/README.md", "host-app-extension-points.md"]
    ]
  },
  {
    feature: "Accessibility Semantics",
    rootPattern: /Accessibility Semantics[\s\S]*ARIA|accessibility-oriented row semantics/i,
    links: [
      ["README.md", "docs/en/accessibility-semantics.md"],
      ["README.md", "docs/ja/accessibility-semantics.md"],
      ["docs/README.md", "en/accessibility-semantics.md"],
      ["docs/README.md", "ja/accessibility-semantics.md"],
      ["docs/en/README.md", "accessibility-semantics.md"],
      ["docs/ja/README.md", "accessibility-semantics.md"]
    ]
  },
  {
    feature: "Direction-aware styling boundary",
    rootPattern: /Direction-aware styling boundary/i,
    links: [
      ["README.md", "docs/en/direction-aware-styling.md"],
      ["README.md", "docs/ja/direction-aware-styling.md"],
      ["docs/README.md", "en/direction-aware-styling.md"],
      ["docs/README.md", "ja/direction-aware-styling.md"],
      ["docs/en/README.md", "direction-aware-styling.md"],
      ["docs/ja/README.md", "direction-aware-styling.md"]
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

foundationalEntrypoints.forEach(({ feature, rootPattern, links }) => {
  assertRootSignal(feature, rootPattern, "README.md no longer exposes the representative docs signal")

  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
})

featureEntrypoints.forEach(({ feature, rootPattern, links }) => {
  assertRootSignal(feature, rootPattern, "README.md no longer exposes the representative feature signal")

  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
})

maintainerEntrypoints.forEach(({ feature, links }) => {
  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
})
