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

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => {
    assert(
      source.includes(signal),
      `${feature}: ${sourcePath} is missing representative signal ${JSON.stringify(signal)}`
    )
  })
}

const categories = [
  "Added",
  "Changed",
  "Fixed",
  "Deprecated",
  "Removed",
  "Documentation",
  "Tests"
]

assertSignals("CHANGELOG.md", "CHANGELOG release category policy", [
  "## Unreleased",
  "Release preparation notes:",
  "public API manifest",
  "package-root export",
  "migration note"
])

categories.forEach((category) => {
  assertSignals("CHANGELOG.md", "CHANGELOG release category policy", [`${category}`])
})

const releaseDocs = [
  [
    "docs/en/release.md",
    [
      "CHANGELOG.md",
      "config/public_api_manifest.yml",
      "public API manifest change",
      "release-facing trail",
      "breaking changes, removals, or deprecations include migration notes",
      "Record public API manifest changes by their user-visible effect"
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "CHANGELOG.md",
      "config/public_api_manifest.yml",
      "public API manifest",
      "release-facing",
      "breaking change、削除、deprecation",
      "migration note",
      "user-visible な影響"
    ]
  ]
]

releaseDocs.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Release checklist changelog policy", signals)
})

const packageContentsVerificationSignals = [
  [
    "script/check_gem_package_contents.rb",
    [
      "REQUIRED_PACKAGED_PATHS",
      "INSTALLATION_REQUIRED_SIGNALS",
      "app/helpers/tree_view_helper.rb",
      "app/views/tree_view/_tree_row.html.erb",
      "app/assets/stylesheets/tree_view.scss",
      "app/javascript/tree_view/index.js",
      "config/importmap.tree_view.rb",
      "config/locales/tree_view.toolbar.en.yml",
      "config/locales/tree_view.toolbar.ja.yml",
      "config/public_api_manifest.yml",
      "docs/en/release.md",
      "docs/ja/release.md",
      "docs/mockups/review-gallery.html",
      "Gem package contents verification failed"
    ]
  ],
  [
    "docs/en/release.md",
    [
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "representative Rails helper, view partial, locale, docs, JavaScript, CSS, importmap, public API manifest, public runtime files, and gem metadata URI surfaces",
      "Package-sensitive PR paths include `tree_view.gemspec`",
      "Rails integration files under `app/helpers/**`, `app/views/**`, `app/assets/**`, and `app/javascript/**`",
      "config/importmap.tree_view.rb",
      "config/public_api_manifest.yml",
      "config/locales/**",
      "docs/en/release.md",
      "docs/ja/release.md"
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "Rails helper / view partial / locale / docs / JavaScript / CSS / importmap / public API manifest / public runtime files / gem metadata URI",
      "package-sensitive path には、`tree_view.gemspec`",
      "Rails integration files である `app/helpers/**`、`app/views/**`、`app/assets/**`、`app/javascript/**`",
      "config/importmap.tree_view.rb",
      "config/public_api_manifest.yml",
      "config/locales/**",
      "docs/en/release.md",
      "docs/ja/release.md"
    ]
  ]
]

packageContentsVerificationSignals.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Gem package release docs category signal", signals)
})

assertSignals("script/release_note_candidates.rb", "Release note candidate helper output", [
  "# Release note candidates for #{repo}",
  "Source: #{source}",
  "This is a maintainer review aid. It does not rewrite CHANGELOG.md and does not decide the final release notes.",
  "Merged pull requests",
  "Closed issues",
  "--since DATE",
  "--since-tag TAG"
])

const releaseNoteCandidateDocs = [
  [
    "docs/en/release-note-candidates.md",
    [
      "script/release_note_candidates.rb",
      "candidate collector only",
      "It does not edit `CHANGELOG.md`.",
      "It does not decide the final release notes.",
      "--since 2026-06-01",
      "--since-tag v0.1.0",
      "# Release note candidates for matsuo-haruhito/tree_view-rails",
      "## Merged pull requests",
      "## Closed issues",
      "release preparation notes, not committed as the final release text"
    ]
  ],
  [
    "docs/ja/release-note-candidates.md",
    [
      "script/release_note_candidates.rb",
      "candidate collector に限定します",
      "`CHANGELOG.md` は編集しません。",
      "最終的な release notes を自動判断しません。",
      "--since 2026-06-01",
      "--since-tag v0.1.0",
      "# Release note candidates for matsuo-haruhito/tree_view-rails",
      "## Merged pull requests",
      "## Closed issues",
      "release preparation の確認メモへ貼るためのもの"
    ]
  ]
]

releaseNoteCandidateDocs.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Release note candidate docs", signals)
})
