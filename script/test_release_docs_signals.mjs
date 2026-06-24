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

const releaseDocsRubyEvidenceSignals = [
  [
    "docs/en/release.md",
    [
      "main-push full CI is green",
      "Ruby version matrix",
      "Rails version matrix",
      "full compatibility matrices",
      "required Ruby version",
      "Ruby support",
      "release evidence"
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "main-push full CI が green",
      "Ruby version matrix",
      "Rails version matrix",
      "full compatibility matrices",
      "required Ruby version",
      "Ruby support",
      "release evidence"
    ]
  ]
]

releaseDocsRubyEvidenceSignals.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Release docs Ruby and Rails evidence signal", signals)
})

const gemPackageWorkflowSignals = [
  [
    ".github/workflows/ci.yml",
    [
      "gem_package:",
      "gem build tree_view.gemspec",
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "gem install tree_view-*.gem",
      "ruby -e \"require 'tree_view'\""
    ]
  ],
  [
    "docs/en/release.md",
    [
      "gem build tree_view.gemspec",
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "gem install tree_view-*.gem",
      "ruby -e \"require 'tree_view'\""
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "gem build tree_view.gemspec",
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "gem install tree_view-*.gem",
      "ruby -e \"require 'tree_view'\""
    ]
  ]
]

gemPackageWorkflowSignals.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Gem package install and require workflow signal", signals)
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
      "EXPECTED_RELEASE_METADATA",
      "EXPECTED_GEM_METADATA",
      "homepage_uri",
      "source_code_uri",
      "changelog_uri",
      "bug_tracker_uri",
      "EXPECTED_PUBLIC_SETUP_GENERATOR",
      "PUBLIC_SETUP_GENERATOR_SOURCE_SIGNALS",
      "lib/generators/tree_view/state/install_generator.rb",
      "lib/generators/tree_view/state/templates/create_tree_view_states.rb",
      "lib/generators/tree_view/state/templates/tree_view_state.rb",
      "lib/generators/tree_view/state/templates/tree_view_state_owner.rb",
      "required_ruby_version",
      "allowed_push_host",
      "runtime_dependencies",
      "Gem package contents verification failed"
    ]
  ],
  [
    "docs/en/release.md",
    [
      "ruby script/check_gem_package_contents.rb tree_view-*.gem",
      "representative Rails helper, view partial, locale, docs, JavaScript, CSS, importmap, public API manifest, public runtime files, and gem metadata URI surfaces",
      "required Ruby version, allowed push host, and runtime dependency metadata",
      "public setup generator files for `tree_view:state:install`",
      "lib/generators/tree_view/state/install_generator.rb",
      "lib/generators/tree_view/state/templates/create_tree_view_states.rb",
      "lib/generators/tree_view/state/templates/tree_view_state.rb",
      "lib/generators/tree_view/state/templates/tree_view_state_owner.rb",
      "Public Setup Surface",
      "Package-sensitive PR paths include `tree_view.gemspec`",
      ".github/dependabot.yml",
      "Dependabot configuration changes are package-sensitive",
      "Rails integration files under `app/helpers/**`, `app/views/**`, `app/assets/**`, and `app/javascript/**`",
      "`docs_entrypoint_sensitive`",
      "`package_sensitive`",
      "`README.md`, `CHANGELOG.md`, `docs/**`, and `config/public_api_manifest.yml`",
      "docs entrypoint smoke",
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
      "required Ruby version、allowed push host、runtime dependency metadata",
      "`tree_view:state:install` public setup generator files",
      "lib/generators/tree_view/state/install_generator.rb",
      "lib/generators/tree_view/state/templates/create_tree_view_states.rb",
      "lib/generators/tree_view/state/templates/tree_view_state.rb",
      "lib/generators/tree_view/state/templates/tree_view_state_owner.rb",
      "Public Setup Surface",
      "package-sensitive path には、`tree_view.gemspec`",
      ".github/dependabot.yml",
      "Dependabot 設定の変更は dependency automation routing",
      "Rails integration files である `app/helpers/**`、`app/views/**`、`app/assets/**`、`app/javascript/**`",
      "`docs_entrypoint_sensitive`",
      "`package_sensitive`",
      "`README.md`、`CHANGELOG.md`、`docs/**`、`config/public_api_manifest.yml`",
      "docs entrypoint smoke",
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

const releaseNoteCandidatePackageGuardSignals = [
  [
    "script/check_gem_package_contents.rb",
    [
      "Release note candidate docs",
      "docs/en/release-note-candidates.md",
      "docs/ja/release-note-candidates.md"
    ]
  ],
  [
    "docs/en/release.md",
    [
      "Release note candidate collector",
      "release-note-candidates.md",
      "package-sensitive",
      "docs/**"
    ]
  ],
  [
    "docs/ja/release.md",
    [
      "Release note candidate collector",
      "release-note-candidates.md",
      "package-sensitive",
      "docs/**"
    ]
  ]
]

releaseNoteCandidatePackageGuardSignals.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Release note candidate package guard signal", signals)
})

const controllerRegistrationDocsSignals = [
  [
    "config/public_api_manifest.yml",
    [
      "controller_registrations:",
      "TreeViewControllerEntries",
      "tree-view-state",
      "TreeViewStateController",
      "tree-view-remote-state",
      "TreeViewRemoteStateController"
    ]
  ],
  [
    "docs/en/controller-registration.md",
    [
      "TreeViewControllerEntries",
      "registerTreeViewControllers(application)",
      "identifier",
      "controller",
      "state",
      "client",
      "selection",
      "transfer",
      "remote state"
    ]
  ],
  [
    "docs/ja/controller-registration.md",
    [
      "TreeViewControllerEntries",
      "registerTreeViewControllers(application)",
      "identifier",
      "controller",
      "state",
      "client",
      "selection",
      "transfer",
      "remote state"
    ]
  ],
  [
    "docs/en/troubleshooting.md",
    [
      "TreeViewControllerIdentifiers",
      "TreeViewControllerEntries",
      "registerTreeViewControllers(application)",
      "selective registration or boot-order tests"
    ]
  ],
  [
    "docs/ja/troubleshooting.md",
    [
      "TreeViewControllerIdentifiers",
      "TreeViewControllerEntries",
      "registerTreeViewControllers(application)",
      "部分登録や boot-order test"
    ]
  ]
]

controllerRegistrationDocsSignals.forEach(([sourcePath, signals]) => {
  assertSignals(sourcePath, "Controller registration docs signal", signals)
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
