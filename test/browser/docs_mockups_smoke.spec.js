import { expect, test } from "@playwright/test"
import { existsSync, readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")
const mockupsReadmePath = path.join(mockupsRoot, "README.md")

function mockupPath(file) {
  return path.join(mockupsRoot, file)
}

function mockupUrl(file) {
  return pathToFileURL(mockupPath(file)).toString()
}

function readmeMockupFiles() {
  const readme = readFileSync(mockupsReadmePath, "utf8")
  const matches = readme.matchAll(/\[[^\]]+\.html\]\(([^)]+\.html)\)/g)
  return Array.from(new Set(Array.from(matches, (match) => match[1])))
}

async function openMockup(page, file) {
  await page.goto(mockupUrl(file))
  await expect(page.locator("main.mock-page")).toBeVisible()
}

async function expectNoDocumentHorizontalOverflow(page) {
  const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
  expect(overflow).toBeLessThanOrEqual(1)
}

const focusedMockupSmokeTargets = [
  {
    file: "default-tree.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "resource-table-bridge.html",
    sample: ".mock-bridge-table tbody tr",
    minimumCount: 4
  },
  {
    file: "narrow-sidebar-tree.html",
    sample: ".mock-narrow-frame",
    minimumCount: 2
  },
  {
    file: "current-branch-sidebar.html",
    sample: ".tree-row.is-selected[aria-current='page']",
    minimumCount: 1
  },
  {
    file: "row-status-depth-labels.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 3
  },
  {
    file: "toggle-icon-states.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 7
  },
  {
    file: "interaction-states.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 5
  },
  {
    file: "keyboard-focus-states.html",
    sample: ".focus-sample, .focus-sample--soft",
    minimumCount: 5
  },
  {
    file: "lazy-loading-handoff.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "drop-positions.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 3
  },
  {
    file: "persisted-state-boundary.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "turbo-frame-target.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 3
  },
  {
    file: "drag-interactive-controls.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "interactive-marker-behaviors.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "windowed-rendering.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "breadcrumb-paths.html",
    sample: ".mock-breadcrumb-path",
    minimumCount: 2
  },
  {
    file: "filtered-tree-modes.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "path-tree-builder-rows.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "form-editing-rows.html",
    sample: ".tree-view-table tbody tr",
    minimumCount: 4
  },
  {
    file: "toolbar-actions.html",
    sample: ".mock-toolbar-frame",
    minimumCount: 3
  },
  {
    file: "selection-max-count.html",
    sample: ".mock-limit-state",
    minimumCount: 3
  },
  {
    file: "empty-state.html",
    sample: "[data-tree-view-empty-state='true']",
    minimumCount: 2
  }
]

test.describe("docs mockup browser smoke", () => {
  test("review gallery loads representative navigation, previews, and local links", async ({ page }) => {
    await openMockup(page, "review-gallery.html")

    await expect(page.getByRole("heading", { name: "TreeView mockup review gallery", level: 1 })).toBeVisible()
    await expect(page.getByRole("navigation", { name: "Documentation entry points" })).toBeVisible()
    await expect(page.getByRole("link", { name: "Baseline" })).toHaveAttribute("href", "#gallery-default-heading")
    await expect(page.getByRole("link", { name: "Interaction states" })).toHaveAttribute("href", "#gallery-interaction-heading")
    await expect(page.getByRole("link", { name: "Current branch" })).toHaveAttribute("href", "#gallery-current-branch-heading")
    await expect(page.frameLocator("iframe[title='Default tree mock preview']").getByRole("heading", { name: "Default TreeView rendering mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Current branch sidebar mock preview']").getByRole("heading", { name: "Current branch sidebar mock", level: 1 })).toBeVisible()

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
    expect(linkedFiles).toContain("current-branch-sidebar.html")
    expect(linkedFiles).toContain("empty-state.html")
    expect(missingLinks).toEqual([])
  })

  test("README mockup file list stays aligned with focused browser smoke targets", () => {
    const expectedFiles = readmeMockupFiles().filter((file) => file !== "review-gallery.html").sort()
    const coveredFiles = focusedMockupSmokeTargets.map((mockup) => mockup.file).sort()

    expect(coveredFiles).toEqual(expectedFiles)
  })

  for (const mockup of focusedMockupSmokeTargets) {
    test(`${mockup.file} exposes its main heading, return link, and representative sample region`, async ({ page }) => {
      await openMockup(page, mockup.file)

      await expect(page.locator("h1").first()).toBeVisible()
      await expect(page.locator("a[href='review-gallery.html']").first()).toBeVisible()
      expect(await page.locator(mockup.sample).count()).toBeGreaterThanOrEqual(mockup.minimumCount)
    })
  }

  for (const viewport of [
    { name: "desktop", width: 1280, height: 900 },
    { name: "narrow", width: 390, height: 900 }
  ]) {
    test(`lazy-loading-handoff.html keeps loading state readable at ${viewport.name} width`, async ({ page }) => {
      await page.setViewportSize({ width: viewport.width, height: viewport.height })
      await openMockup(page, "lazy-loading-handoff.html")

      await expect(page.getByRole("heading", { name: "Loading in progress" })).toBeVisible()
      await expect(page.locator("#project_delta[aria-busy='true']")).toBeVisible()
      await expect(page.getByText("Loading child rows...")).toBeVisible()
      await expectNoDocumentHorizontalOverflow(page)
    })
  }
})
