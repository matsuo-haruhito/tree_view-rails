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
