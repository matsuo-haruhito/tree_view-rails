import { expect, test } from "@playwright/test"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")

function mockupUrl(file) {
  return pathToFileURL(path.join(mockupsRoot, file)).toString()
}

async function expectNoDocumentHorizontalOverflow(page) {
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
  expect(overflow).toBeLessThanOrEqual(1)
}

test.describe("direction-aware tree cues mockup", () => {
  for (const viewport of [
    { name: "desktop", width: 1280, height: 900 },
    { name: "narrow", width: 390, height: 900 }
  ]) {
    test(`keeps LTR and RTL hierarchy cues readable at ${viewport.name} width`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height })
      await page.goto(mockupUrl("direction-aware-tree-cues/index.html"))

      await expect(page.getByRole("heading", { name: "TreeView direction-aware hierarchy cue mock", level: 1 })).toBeVisible()
      await expect(page.getByRole("heading", { name: "Left-to-right baseline" })).toBeVisible()
      await expect(page.getByRole("heading", { name: "Right-to-left review frame" })).toBeVisible()
      await expect(page.locator("[data-tree-view-sample='rtl-hierarchy-cues'] .direction-frame[dir='rtl'] .tree-row")).toHaveCount(3)
      await expect(page.getByText("Branch connectors mirror toward inline-start")).toBeVisible()
      await expectNoDocumentHorizontalOverflow(page)
    })
  }
})
