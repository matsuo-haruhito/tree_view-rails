import { readdirSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const validLanguages = new Set(["en", "ja"])

const parityExceptions = new Map([
  // ["en:temporary-page.md", {
  //   affectedLanguage: "ja",
  //   reason: "Short reason why the peer page is intentionally absent.",
  //   review: "Planned review timing or removal condition."
  // }]
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

function validateExceptionMetadata(sourceLanguage, page, metadata, pagesByLanguage) {
  const exceptionKey = `${sourceLanguage}:${page}`

  assert(
    validLanguages.has(sourceLanguage),
    `docs i18n parity exception ${exceptionKey} must start with en: or ja:`
  )
  assert(
    page && page.endsWith(".md"),
    `docs i18n parity exception ${exceptionKey} must include a Markdown page path`
  )
  assert(
    pagesByLanguage[sourceLanguage].has(page),
    `docs i18n parity exception ${exceptionKey} references a missing ${sourceLanguage} source page`
  )
  assert(
    metadata && typeof metadata === "object" && !Array.isArray(metadata),
    `docs i18n parity exception ${exceptionKey} must include metadata`
  )
  assert(
    validLanguages.has(metadata.affectedLanguage) && metadata.affectedLanguage !== sourceLanguage,
    `docs i18n parity exception ${exceptionKey} must name the missing peer language as affectedLanguage`
  )

  ;["reason", "review"].forEach((field) => {
    assert(
      typeof metadata[field] === "string" && metadata[field].trim().length > 0,
      `docs i18n parity exception ${exceptionKey} must include a non-empty ${field}`
    )
  })
}

function validateParityExceptions(englishPages, japanesePages) {
  const pagesByLanguage = {
    en: new Set(englishPages),
    ja: new Set(japanesePages)
  }

  parityExceptions.forEach((metadata, exceptionKey) => {
    const [sourceLanguage, ...pageParts] = exceptionKey.split(":")
    validateExceptionMetadata(sourceLanguage, pageParts.join(":"), metadata, pagesByLanguage)
  })
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

validateParityExceptions(englishPages, japanesePages)

const failures = [
  ...missingPeers("en", "ja", englishPages, japanesePages),
  ...missingPeers("ja", "en", japanesePages, englishPages)
]

assert(
  failures.length === 0,
  `docs i18n page-set parity failed:\n${failures.map((failure) => `- ${failure}`).join("\n")}`
)
