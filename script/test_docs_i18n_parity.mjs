import { readdirSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

const parityExceptions = new Map([
  // Keep intentional one-language Markdown pages visible here with a short reason.
])

function markdownPages(relativeDirectory) {
  const absoluteDirectory = path.join(repoRoot, relativeDirectory)
  const pages = []

  readdirSync(absoluteDirectory, { withFileTypes: true }).forEach((entry) => {
    const relativePath = path.join(relativeDirectory, entry.name)

    if (entry.isDirectory()) {
      markdownPages(relativePath).forEach((page) => pages.push(path.join(entry.name, page)))
      return
    }

    if (entry.isFile() && entry.name.endsWith(".md")) {
      pages.push(entry.name)
    }
  })

  return pages.sort()
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function missingPeers(sourceLanguage, targetLanguage, sourcePages, targetPages) {
  const targetSet = new Set(targetPages)

  return sourcePages.filter((page) => {
    const exceptionKey = `${sourceLanguage}:${page}`
    return !targetSet.has(page) && !parityExceptions.has(exceptionKey)
  }).map((page) => `${targetLanguage} missing ${page}`)
}

const englishPages = markdownPages("docs/en")
const japanesePages = markdownPages("docs/ja")

const failures = [
  ...missingPeers("en", "ja", englishPages, japanesePages),
  ...missingPeers("ja", "en", japanesePages, englishPages)
]

assert(
  failures.length === 0,
  `docs i18n page-set parity failed:\n${failures.map((failure) => `- ${failure}`).join("\n")}`
)
