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
  const target = decodeURIComponent(href.split("#", 1)[0])
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

function assertDocumentSignal(sourcePath, signalPattern, feature, message) {
  const source = read(sourcePath)

  assert(signalPattern.test(source), `${feature}: ${message}`)
}

const repositoryOnlyEntrypoints = [
  {
    feature: "Root docs repository-only maintainer entrypoints",
    links: [
      ["docs/README.md", "en/README.md"],
      ["docs/README.md", "ja/README.md"],
      ["docs/README.md", "i18n-audit.md"],
      ["docs/README.md", "../CHANGELOG.md"]
    ],
    signals: [
      [
        "docs/README.md",
        /Maintainer entry points[\s\S]*gem-packaged docs[\s\S]*repository-only files[\s\S]*Product Profile[\s\S]*AGENTS\.md[\s\S]*Documentation maintenance checklist[\s\S]*CHANGELOG\.md/,
        "docs/README.md no longer keeps repository-only maintainer files distinct from packaged docs"
      ]
    ]
  },
  {
    feature: "English repository-only maintainer entrypoints",
    links: [
      ["docs/en/README.md", "../../Product%20Profile.md"],
      ["docs/en/README.md", "../../AGENTS.md"],
      ["docs/en/README.md", "../README.md"],
      ["docs/en/README.md", "../../CHANGELOG.md"],
      ["docs/en/README.md", "../i18n-audit.md"]
    ],
    signals: [
      [
        "docs/en/README.md",
        /For maintainers[\s\S]*Product Profile[\s\S]*AGENTS\.md[\s\S]*Root docs index[\s\S]*CHANGELOG\.md[\s\S]*Documentation i18n audit/,
        "English docs README no longer exposes the repository-only maintainer table"
      ]
    ]
  },
  {
    feature: "Japanese repository-only maintainer entrypoints",
    links: [
      ["docs/ja/README.md", "../../Product%20Profile.md"],
      ["docs/ja/README.md", "../../AGENTS.md"],
      ["docs/ja/README.md", "../README.md"],
      ["docs/ja/README.md", "../../CHANGELOG.md"],
      ["docs/ja/README.md", "../i18n-audit.md"]
    ],
    signals: [
      [
        "docs/ja/README.md",
        /保守者向け[\s\S]*Product Profile[\s\S]*AGENTS\.md[\s\S]*root docs index[\s\S]*CHANGELOG\.md[\s\S]*Documentation i18n audit/,
        "Japanese docs README no longer exposes the repository-only maintainer table"
      ]
    ]
  }
]

repositoryOnlyEntrypoints.forEach(({ feature, links, signals = [] }) => {
  links.forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))
  signals.forEach(([sourcePath, signalPattern, message]) => {
    assertDocumentSignal(sourcePath, signalPattern, feature, message)
  })
})
