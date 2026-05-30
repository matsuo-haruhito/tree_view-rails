import { expect, test } from "@playwright/test"
import { existsSync } from "node:fs"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")

function mockupPath(file) {
  return path.join(mockupsRoot, file)
}

function mockupUrl(file) {
  return pathToFileURL(mockupPath(file)).toString()
}

async function openMockup(page, file) {
  await page.goto(mockupUrl(file))
  await expect(page.locator("main.mock-page")).toBeVisible()
}

test.describe("docs mockup browser smoke", () => {
  test("review gallery loads representative navigation, previews, and local links", async ({ page }) => {
    await openMockup(page, "review-gallery.html")

    await expect(page.getByRole("heading", { name: "TreeView mockup review gallery", level: 1 })).toBeVisible()
    await expect(page.getByRole("navigation", { name: "Documentation entry points" })).toBeVisible()
    await expect(page.getByRole("navigation", { name: "Mockup comparison gallery" })).toBeHidden({ timeout: 1 }).catch(() => {})
    await expect(page.getByRole("link", { name: "Baseline" })).toHaveAttribute("href", "#gallery-default-heading")
    await expect(page.getByRole("link", { name: "Interaction states" })).toHaveAttribute("href", "#gallery-interaction-heading")
    await expect(page.frameLocator("iframe[title='Default tree mock preview']").getByRole("heading", { name: "Default TreeView rendering mock", level: 1 })).toBeVisible()

    const linkedFiles = await page.locator("a[href]").evaluateAll((anchors) =>
      Array.from(new Set(
        anchors
          .map((anchor) => anchor.getAttribute("href"))
          .filter((href) => href && !href.startsWith("#"))
      ))
    )
    const missingLinks = linkedFiles.filter((href) => !existsSync(path.resolve(mockupsRoot, href)))

    expect(linkedFiles).toContain("default-tree.html")
    expect(linkedFiles).toContain("interaction-states.html")
    expect(linkedFiles).toContain("empty-state.html")
    expect(missingLinks).toEqual([])
  })

  for (const mockup of [
    {
      file: "default-tree.html",
      heading: "Default TreeView rendering mock",
      section: "Standard table structure",
      sample: ".tree-view-table tbody tr",
      minimumCount: 4
    },
    {
      file: "interaction-states.html",
      heading: "TreeView interaction states mock",
      section: "Lazy loading and retry states",
      sample: ".tree-view-table tbody tr",
      minimumCount: 5
    },
    {
      file: "empty-state.html",
      heading: "TreeView empty state mock",
      section: "No root items",
      sample: "[data-tree-view-empty-state='true']",
      minimumCount: 2
    }
  ]) {
    test(`${mockup.file} exposes its main heading and representative sample region`, async ({ page }) => {
      await openMockup(page, mockup.file)

      await expect(page.getByRole("heading", { name: mockup.heading, level: 1 })).toBeVisible()
      await expect(page.getByRole("heading", { name: mockup.section })).toBeVisible()
      await expect(page.locator(mockup.sample)).toHaveCount(mockup.minimumCount)
      await expect(page.getByRole("link", { name: "Back to review gallery" })).toHaveAttribute("href", "review-gallery.html")
    })
  }
})
