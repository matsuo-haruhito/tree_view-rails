import assert from "node:assert/strict"
import {
  existsSync,
  readdirSync,
  readFileSync,
  statSync
} from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

const markdownSourcePaths = [
  "README.md",
  ...walkFiles("docs").filter((relativePath) => relativePath.endsWith(".md"))
].sort()

const htmlSourcePaths = ["docs/mockups/review-gallery.html"]

function walkFiles(relativeDirectory) {
  const directory = path.join(repoRoot, relativeDirectory)
  if (!existsSync(directory)) return []

  return readdirSync(directory, { withFileTypes: true })
    .flatMap((entry) => {
      const relativePath = path.join(relativeDirectory, entry.name).replaceAll(path.sep, "/")

      if (entry.isDirectory()) return walkFiles(relativePath)
      if (entry.isFile()) return [relativePath]

      return []
    })
    .sort()
}

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function withoutCodeFences(markdown) {
  return markdown.replace(/```[\s\S]*?```/g, "")
}

function markdownLinks(markdown) {
  const source = withoutCodeFences(markdown)
  const links = []

  for (const match of source.matchAll(/!?\[[^\]\n]*\]\(\s*<?([^\s)>]+)>?(?:\s+"[^"]*")?\s*\)/g)) {
    links.push(match[1])
  }

  for (const match of source.matchAll(/^\s{0,3}\[[^\]\n]+\]:\s+<?([^\s>]+)>?/gm)) {
    links.push(match[1])
  }

  return links
}

function htmlLinks(html) {
  return [...html.matchAll(/\b(?:href|src)=["']([^"']+)["']/g)].map((match) => match[1])
}

function isExternalTarget(target) {
  return /^(?:[a-z][a-z0-9+.-]*:)?\/\//i.test(target) ||
    /^(?:mailto|tel|data|javascript):/i.test(target)
}

function decodePathSegment(segment) {
  try {
    return decodeURIComponent(segment)
  } catch {
    return segment
  }
}

function splitTarget(target) {
  const [withoutQuery] = target.split("?")
  const [fileTarget = "", fragment = ""] = withoutQuery.split("#")

  return {
    fileTarget: decodePathSegment(fileTarget),
    fragment: decodePathSegment(fragment)
  }
}

function resolveTargetPath(sourcePath, fileTarget) {
  const sourceDirectory = path.dirname(sourcePath)
  const targetPath = fileTarget || sourcePath
  const resolvedPath = path.normalize(
    targetPath.startsWith("/")
      ? targetPath.slice(1)
      : path.join(sourceDirectory, targetPath)
  )

  if (resolvedPath.startsWith("..")) return null

  return resolvedPath.replaceAll(path.sep, "/")
}

function headingTextToSlug(text) {
  return text
    .replace(/\[([^\]]+)\]\([^)]+\)/g, "$1")
    .replace(/<[^>]+>/g, "")
    .replace(/[`*~[\]]/g, "")
    .trim()
    .toLowerCase()
    .replace(/[^\p{Letter}\p{Number}\p{Mark}_\s-]/gu, "")
    .replace(/\s+/g, "-")
}

function markdownAnchors(relativePath) {
  const source = withoutCodeFences(read(relativePath))
  const anchors = new Set()
  const seenSlugs = new Map()

  for (const match of source.matchAll(/^#{1,6}\s+(.+?)\s*#*\s*$/gm)) {
    const baseSlug = headingTextToSlug(match[1])
    if (!baseSlug) continue

    const count = seenSlugs.get(baseSlug) || 0
    seenSlugs.set(baseSlug, count + 1)
    anchors.add(count === 0 ? baseSlug : `${baseSlug}-${count}`)
  }

  for (const match of source.matchAll(/\bid=["']([^"']+)["']/g)) {
    anchors.add(match[1])
  }

  return anchors
}

function htmlAnchors(relativePath) {
  const source = read(relativePath)
  return new Set([...source.matchAll(/\bid=["']([^"']+)["']/g)].map((match) => match[1]))
}

function anchorsFor(relativePath) {
  if (relativePath.endsWith(".md")) return markdownAnchors(relativePath)
  if (relativePath.endsWith(".html")) return htmlAnchors(relativePath)

  return new Set()
}

function assertLocalTargetExists({ sourcePath, target, kind }) {
  if (!target || target.startsWith("#") || isExternalTarget(target)) return

  const { fileTarget, fragment } = splitTarget(target)
  const resolvedPath = resolveTargetPath(sourcePath, fileTarget)

  assert.ok(
    resolvedPath,
    `${kind}: ${sourcePath} has repository-escaping local link target ${JSON.stringify(target)}`
  )

  const absolutePath = path.join(repoRoot, resolvedPath)

  assert.ok(
    existsSync(absolutePath),
    `${kind}: ${sourcePath} links to missing local target ${JSON.stringify(target)} resolved as ${resolvedPath}`
  )

  assert.ok(
    statSync(absolutePath).isFile(),
    `${kind}: ${sourcePath} links to non-file local target ${JSON.stringify(target)} resolved as ${resolvedPath}`
  )

  if (!fragment) return

  const anchors = anchorsFor(resolvedPath)

  assert.ok(
    anchors.has(fragment),
    `${kind}: ${sourcePath} links to missing local anchor ${JSON.stringify(fragment)} in ${resolvedPath} via ${JSON.stringify(target)}`
  )
}

for (const sourcePath of markdownSourcePaths) {
  for (const target of markdownLinks(read(sourcePath))) {
    assertLocalTargetExists({
      sourcePath,
      target,
      kind: "markdown local link"
    })
  }
}

for (const sourcePath of htmlSourcePaths) {
  for (const target of htmlLinks(read(sourcePath))) {
    assertLocalTargetExists({
      sourcePath,
      target,
      kind: "mockup gallery local link"
    })
  }
}

console.log(
  `[docs-link-integrity] checked ${markdownSourcePaths.length} markdown files and ${htmlSourcePaths.length} mockup gallery file`
)
