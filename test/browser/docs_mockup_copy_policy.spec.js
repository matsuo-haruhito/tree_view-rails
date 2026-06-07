import { expect, test } from "@playwright/test"
import { existsSync, readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")
const mockupsReadmePath = path.join(mockupsRoot, "README.md")
const mockupsSmokePath = path.join(repoRoot, "test/browser/docs_mockups_smoke.spec.js")

function readmeMockupFiles() {
  const readme = readFileSync(mockupsReadmePath, "utf8")
  const filesTable = readme.split("## Recommended review flow")[0]
  const matches = filesTable.matchAll(/\[[^\]]+\.html\]\(([^)]+\.html)\)/g)

  return Array.from(new Set(Array.from(matches, (match) => match[1])))
}

function mockupCopyExceptionRows() {
  const readme = readFileSync(mockupsReadmePath, "utf8")
  const policySection = readme.split("## Copy and language policy")[1]?.split("## Selection form guidance")[0] || ""
  const rows = policySection
    .split("\n")
    .filter((line) => /^\| `[^`]+\.html` \|/.test(line))

  return rows.map((line) => {
    const [, mockup, exception, reason] = line.split("|").map((part) => part.trim())
    return {
      exception,
      mockup: mockup.replace(/^`|`$/g, ""),
      reason
    }
  })
}

test.describe("mockup copy and language policy", () => {
  test("deliberate copy exceptions stay tied to listed browser-smoke mockups", () => {
    const listedMockups = readmeMockupFiles()
    const smokeSource = readFileSync(mockupsSmokePath, "utf8")
    const exceptionRows = mockupCopyExceptionRows()

    expect(exceptionRows.map((row) => row.mockup).sort()).toEqual([
      "localized-row-labels.html",
      "toolbar-actions.html"
    ])

    for (const row of exceptionRows) {
      expect(row.exception, `${row.mockup} must describe its deliberate copy exception`).not.toEqual("")
      expect(row.reason, `${row.mockup} must keep a review reason`).not.toEqual("")
      expect(listedMockups).toContain(row.mockup)
      expect(existsSync(path.join(mockupsRoot, row.mockup))).toBe(true)
      expect(smokeSource).toContain(`file: "${row.mockup}"`)
    }
  })
})
