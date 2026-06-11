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

function galleryReturnHref(file) {
  const relativePath = path.posix.relative(path.posix.dirname(file), "review-gallery.html")
  return relativePath || "review-gallery.html"
}

function readmeMockupFiles() {
  const readme = readFileSync(mockupsReadmePath, "utf8")
  const filesTable = readme.split("## Recommended review flow")[0]
  const matches = filesTable.matchAll(/\[[^\]]+\.html\]\(([^)]+\.html)\)/g)
  return Array.from(new Set(Array.from(matches, (match) => match[1])))
}

function reviewGalleryMockupFiles() {
  const gallery = readFileSync(mockupPath("review-gallery.html"), "utf8")
  const matches = gallery.matchAll(/\b(?:href|src)="([^"#?]+\.html)"/g)

  return Array.from(new Set(Array.from(matches, (match) => match[1])))
}

async function openMockup(page, file) {
  await page.goto(mockupUrl(file))
  await expect(page.locator("main.mock-page")).toBeVisible()
}

async function documentHorizontalOverflow(page) {
  return page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth)
}

async function expectNoDocumentHorizontalOverflow(page) {
  const overflow = await documentHorizontalOverflow(page)
  expect(overflow).toBeLessThanOrEqual(1)
}

const focusedMockupSmokeTargets = [
  { file: "default-tree.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "minimal-usage-first-render.html", sample: "[data-tree-view-sample='minimal-usage-first-render'] .tree-view-table tbody tr", minimumCount: 3 },
  { file: "resource-table-bridge.html", sample: ".mock-bridge-table tbody tr", minimumCount: 4 },
  { file: "resource-table-empty-colspan-boundary.html", sample: "[data-tree-view-sample='resource-table-empty-colspan-boundary'] .tree-view-empty-row__content", minimumCount: 2 },
  { file: "table-caption-context.html", sample: ".tree-view-table caption", minimumCount: 1 },
  { file: "narrow-sidebar-tree.html", sample: ".mock-narrow-frame", minimumCount: 2 },
  { file: "current-branch-sidebar.html", sample: ".tree-row.is-selected[aria-current='page']", minimumCount: 1 },
  { file: "row-status-depth-labels.html", sample: ".tree-view-table tbody tr", minimumCount: 3 },
  { file: "toggle-icon-states.html", sample: ".tree-view-table tbody tr", minimumCount: 7 },
  { file: "interaction-states.html", sample: ".tree-view-table tbody tr", minimumCount: 5 },
  { file: "children-pagination.html", sample: ".mock-pagination-card", minimumCount: 3 },
  { file: "reduced-motion-state-cues.html", sample: "[data-tree-view-sample='reduced-motion-state-cues'] .tree-view-table tbody tr", minimumCount: 5 },
  { file: "keyboard-focus-states.html", sample: ".focus-sample, .focus-sample--soft", minimumCount: 5 },
  { file: "accessibility-semantics.html", sample: "[data-tree-view-sample='accessibility-semantics'] .tree-view-table tbody tr", minimumCount: 5 },
  { file: "keyboard-current-row/index.html", sample: ".keyboard-current-row, .keyboard-current-focus", minimumCount: 3 },
  { file: "high-contrast-state-cues/index.html", sample: "[data-tree-view-sample='high-contrast-state-cues']", minimumCount: 1 },
  { file: "direction-aware-cues/index.html", sample: ".direction-frame .tree-view-table tbody tr", minimumCount: 10 },
  { file: "lazy-loading-handoff.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "drop-positions.html", sample: ".tree-view-table tbody tr", minimumCount: 3 },
  { file: "persisted-state-boundary.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "turbo-frame-target.html", sample: ".tree-view-table tbody tr", minimumCount: 3 },
  { file: "drag-interactive-controls.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "interactive-marker-behaviors.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "windowed-rendering.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "breadcrumb-paths.html", sample: ".mock-breadcrumb-path", minimumCount: 2 },
  { file: "filtered-tree-modes.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "path-tree-builder-rows.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "node-presenter-row-partials.html", sample: ".tree-view-table tbody tr", minimumCount: 3 },
  { file: "localized-row-labels.html", sample: ".tree-view-table tbody tr", minimumCount: 3 },
  { file: "form-editing-rows.html", sample: ".tree-view-table tbody tr", minimumCount: 4 },
  { file: "toolbar-actions.html", sample: ".mock-toolbar-frame", minimumCount: 3 },
  { file: "selection-max-count.html", sample: ".mock-limit-state", minimumCount: 3 },
  { file: "selection-multi-tree-form.html", sample: ".mock-selection-group", minimumCount: 2 },
  { file: "children-pagination-selection-boundary.html", sample: ".mock-pagination-selection-state", minimumCount: 3 },
  { file: "empty-state.html", sample: "[data-tree-view-empty-state='true']", minimumCount: 2 }
]

const narrowOverflowExpectedMockups = new Map([
  ["default-tree.html", "wide baseline table columns are intentionally visible in the reference mockup"],
  ["resource-table-bridge.html", "resource-table comparison keeps fuller columns visible for review"],
  ["resource-table-empty-colspan-boundary.html", "resource-table colspan boundary keeps selection, metadata, and action columns visible for review"],
  ["table-caption-context.html", "table caption reference keeps host-owned action and status columns visible"],
  ["row-status-depth-labels.html", "status/depth table columns are intentionally preserved"],
  ["toggle-icon-states.html", "toggle-state comparison uses a wide table matrix"],
  ["interaction-states.html", "interaction-state table keeps multiple state columns visible"],
  ["children-pagination.html", "children pagination examples keep branch page-state columns visible"],
  ["reduced-motion-state-cues.html", "state-cue comparison keeps the table matrix visible"],
  ["keyboard-focus-states.html", "focus samples include multiple side-by-side controls"],
  ["accessibility-semantics.html", "table-first ARIA comparison keeps state and boundary columns visible"],
  ["keyboard-current-row/index.html", "keyboard current-row comparison keeps focus/current/action columns visible"],
  ["high-contrast-state-cues/index.html", "high-contrast state-cue panels stay side by side for comparison"],
  ["direction-aware-cues/index.html", "direction-aware examples keep multiple writing directions visible for comparison"],
  ["drop-positions.html", "drop-position comparison keeps before/inside/after states side by side"],
  ["persisted-state-boundary.html", "persisted-state comparison keeps multiple state columns visible"],
  ["turbo-frame-target.html", "Turbo Frame reference keeps target and row columns visible"],
  ["drag-interactive-controls.html", "interactive-control rows keep native controls visible"],
  ["interactive-marker-behaviors.html", "marker-behavior comparison keeps multiple controls visible"],
  ["windowed-rendering.html", "window metadata columns are intentionally visible"],
  ["breadcrumb-paths.html", "breadcrumb path examples keep long path segments inspectable"],
  ["filtered-tree-modes.html", "filtered-mode comparison keeps mode columns visible"],
  ["path-tree-builder-rows.html", "PathTreeBuilder examples keep generated path columns inspectable"],
  ["node-presenter-row-partials.html", "NodePresenter partial examples keep host-owned columns visible"],
  ["localized-row-labels.html", "localized label comparison keeps multilingual columns visible"],
  ["form-editing-rows.html", "bulk-edit controls are intentionally visible in the reference"],
  ["toolbar-actions.html", "toolbar action labels include long/localized stress cases"],
  ["selection-max-count.html", "selection limit comparison keeps multiple state panels visible"],
  ["selection-multi-tree-form.html", "multi-tree form comparison keeps source groups side by side"],
  ["children-pagination-selection-boundary.html", "pagination selection boundary keeps rendered and unloaded state columns visible"],
  ["empty-state.html", "empty-state comparison keeps table wrappers inspectable"]
])

test.describe("docs mockup browser smoke", () => {
  test("review gallery loads representative navigation, previews, and local links", async ({ page }) => {
    await openMockup(page, "review-gallery.html")

    await expect(page.getByRole("heading", { name: "TreeView mockup review gallery", level: 1 })).toBeVisible()
    await expect(page.getByRole("navigation", { name: "Documentation entry points" })).toBeVisible()
    await expect(page.getByRole("link", { name: "Baseline" })).toHaveAttribute("href", "#gallery-default-heading")
    await expect(page.getByRole("link", { name: "Minimal usage" })).toHaveAttribute("href", "#gallery-minimal-usage-heading")
    await expect(page.getByRole("link", { name: "Interaction states" })).toHaveAttribute("href", "#gallery-interaction-heading")
    await expect(page.getByRole("link", { name: "Current branch" })).toHaveAttribute("href", "#gallery-current-branch-heading")
    await expect(page.getByRole("link", { name: "Keyboard current row" })).toHaveAttribute("href", "#gallery-keyboard-current-heading")
    await expect(page.getByRole("link", { name: "Direction-aware cues" })).toHaveAttribute("href", "#gallery-direction-heading")
    await expect(page.getByRole("link", { name: "Presenter row partials" })).toHaveAttribute("href", "#gallery-node-presenter-heading")
    await expect(page.getByRole("link", { name: "Localized labels" })).toHaveAttribute("href", "#gallery-localized-heading")
    await expect(page.getByRole("link", { name: "Selection form" })).toHaveAttribute("href", "#gallery-selection-form-heading")
    await expect(page.getByRole("link", { name: "Pagination selection" })).toHaveAttribute("href", "#gallery-pagination-selection-heading")
    await expect(page.frameLocator("iframe[title='Default tree mock preview']").getByRole("heading", { name: "Default TreeView rendering mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Minimal usage first render mock preview']").getByRole("heading", { name: "Minimal usage first render mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Resource table empty colspan boundary mock preview']").getByRole("heading", { name: "Resource table empty colspan boundary mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Table caption context mock preview']").getByRole("heading", { name: "Table caption context mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Current branch sidebar mock preview']").getByRole("heading", { name: "Current branch sidebar mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Keyboard current row mock preview']").getByRole("heading", { name: "Keyboard focus and current-row cues", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Direction-aware cues mock preview']").getByRole("heading", { name: "Direction-aware current-row and hierarchy cues", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='NodePresenter row partials mock preview']").getByRole("heading", { name: "NodePresenter row partial mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Localized row labels mock preview']").getByRole("heading", { name: "Localized row labels mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Multi-tree selection form mock preview']").getByRole("heading", { name: "TreeView multi-tree selection form mock", level: 1 })).toBeVisible()
    await expect(page.frameLocator("iframe[title='Children pagination selection boundary mock preview']").getByRole("heading", { name: "Children pagination selection boundary mock", level: 1 })).toBeVisible()

    const linkedFiles = await page.locator("a[href]").evaluateAll((anchors) =>
      Array.from(new Set(
        anchors
          .map((anchor) => anchor.getAttribute("href"))
          .filter((href) => href && !href.startsWith("#"))
      ))
    )
    const missingLinks = linkedFiles.filter((href) => !existsSync(path.resolve(mockupsRoot, href)))

    expect(linkedFiles).toContain("default-tree.html")
    expect(linkedFiles).toContain("minimal-usage-first-render.html")
    expect(linkedFiles).toContain("resource-table-empty-colspan-boundary.html")
    expect(linkedFiles).toContain("table-caption-context.html")
    expect(linkedFiles).toContain("interaction-states.html")
    expect(linkedFiles).toContain("children-pagination.html")
    expect(linkedFiles).toContain("reduced-motion-state-cues.html")
    expect(linkedFiles).toContain("current-branch-sidebar.html")
    expect(linkedFiles).toContain("accessibility-semantics.html")
    expect(linkedFiles).toContain("keyboard-current-row/index.html")
    expect(linkedFiles).toContain("direction-aware-cues/index.html")
    expect(linkedFiles).toContain("node-presenter-row-partials.html")
    expect(linkedFiles).toContain("localized-row-labels.html")
    expect(linkedFiles).toContain("selection-multi-tree-form.html")
    expect(linkedFiles).toContain("children-pagination-selection-boundary.html")
    expect(linkedFiles).toContain("empty-state.html")
    expect(missingLinks).toEqual([])
  })

  test("README mockup file list stays aligned with focused browser smoke targets", () => {
    const expectedFiles = readmeMockupFiles().filter((file) => file !== "review-gallery.html").sort()
    const coveredFiles = focusedMockupSmokeTargets.map((mockup) => mockup.file).sort()

    expect(coveredFiles).toEqual(expectedFiles)
  })

  test("review gallery links every focused mockup listed in README", () => {
    const expectedFiles = readmeMockupFiles().filter((file) => file !== "review-gallery.html").sort()
    const galleryFiles = reviewGalleryMockupFiles().sort()
    const missingGalleryFiles = expectedFiles.filter((file) => !galleryFiles.includes(file))

    expect(missingGalleryFiles).toEqual([])
  })

  test("narrow overflow exceptions stay explicit and attached to focused smoke targets", () => {
    const coveredFiles = focusedMockupSmokeTargets.map((mockup) => mockup.file)
    const staleExceptions = [...narrowOverflowExpectedMockups.keys()].filter((file) => !coveredFiles.includes(file))
    const uncheckedFiles = coveredFiles.filter((file) => !narrowOverflowExpectedMockups.has(file))

    expect(staleExceptions).toEqual([])
    expect(uncheckedFiles).toEqual([
      "minimal-usage-first-render.html",
      "narrow-sidebar-tree.html",
      "current-branch-sidebar.html",
      "lazy-loading-handoff.html"
    ])
  })

  for (const mockup of focusedMockupSmokeTargets) {
    test(`${mockup.file} exposes its main heading, return link, and representative sample region`, async ({ page }) => {
      await openMockup(page, mockup.file)

      await expect(page.locator("h1").first()).toBeVisible()
      await expect(page.locator(`a[href='${galleryReturnHref(mockup.file)}']`).first()).toBeVisible()
      expect(await page.locator(mockup.sample).count()).toBeGreaterThanOrEqual(mockup.minimumCount)
    })
  }

  test("table-caption-context.html preserves host and TreeView responsibility boundary signals", async ({ page }) => {
    await openMockup(page, "table-caption-context.html")

    await expect(page.getByRole("heading", { name: "Workspace hierarchy" })).toBeVisible()
    await expect(page.locator("[aria-label='Host app actions']")).toBeVisible()
    await expect(page.locator(".tree-view-table caption")).toContainText("Host-owned table caption")
    await expect(page.getByRole("heading", { name: "Responsibility boundary" })).toBeVisible()
    await expect(page.getByText("Host app owns page heading", { exact: false })).toBeVisible()
    await expect(page.getByText("TreeView owns row hierarchy cues", { exact: false })).toBeVisible()
    expect(await page.locator(".tree-toggle__branches").count()).toBeGreaterThanOrEqual(4)
    expect(await page.locator(".tree-depth-label").count()).toBeGreaterThanOrEqual(4)
    expect(await page.locator("[data-tree-selection-payload]").count()).toBeGreaterThanOrEqual(4)
  })

  test("direction-aware-cues/index.html preserves LTR, RTL, and vertical representative regions", async ({ page }) => {
    await openMockup(page, "direction-aware-cues/index.html")

    await expect(page.getByRole("heading", { name: "LTR baseline" })).toBeVisible()
    await expect(page.locator("[aria-label='LTR baseline tree sample'] .tree-row.is-selected")).toBeVisible()
    await expect(page.getByRole("heading", { name: "RTL host-app override" })).toBeVisible()
    await expect(page.locator("[aria-label='RTL override tree sample'][dir='rtl'] .tree-row.is-selected")).toBeVisible()
    await expect(page.getByRole("heading", { name: "Vertical writing stress case" })).toBeVisible()
    await expect(page.locator("[aria-label='Vertical writing tree sample'].direction-frame--vertical .tree-row.is-selected")).toBeVisible()
    await expect(page.locator("[aria-label='Vertical writing tree sample'].direction-frame--vertical")).toHaveCSS("writing-mode", "vertical-rl")
  })

  test("toolbar-actions.html preserves action and responsibility boundary signals", async ({ page }) => {
    await openMockup(page, "toolbar-actions.html")

    await expect(page.locator("[data-mock-state='expand-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-state='collapse-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-state='current-path-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-boundary='current-path-active']")).toBeVisible()
    await expect(page.locator("[data-mock-boundary='localized-current-path-active']")).toBeVisible()
    expect(await page.locator("[data-mock-boundary='metadata-disabled-fallback']").count()).toBeGreaterThanOrEqual(2)
    await expect(page.getByText("Host app owns", { exact: true })).toBeVisible()
    await expect(page.getByText("Route generation, authorization policy, final permission copy, localization, and business-specific action names.", { exact: true })).toBeVisible()
    await expect(page.getByText("すべての部署とチームを展開", { exact: true })).toBeVisible()
    await expect(page.getByText("現在の申請ルートだけを表示", { exact: true })).toBeVisible()
  })

  test("path-tree-builder-rows.html preserves generated-folder and record-row boundary signals", async ({ page }) => {
    await openMockup(page, "path-tree-builder-rows.html")

    await expect(page.getByText("Generated folder row", { exact: true })).toBeVisible()
    await expect(page.getByText("Record row", { exact: true })).toBeVisible()
    await expect(page.getByText("Outside this mock", { exact: true })).toBeVisible()
    await expect(page.getByText("Routes, downloads, authorization copy, and final file-manager behavior stay outside the gem mockup.", { exact: true })).toBeVisible()
    expect(await page.locator(".path-builder-row-kind--folder").count()).toBeGreaterThanOrEqual(2)
    expect(await page.locator(".path-builder-row-kind--record").count()).toBeGreaterThanOrEqual(2)
    expect(await page.locator("[title='Generated folder node']").count()).toBeGreaterThanOrEqual(2)
    expect(await page.locator("[title='Record node']").count()).toBeGreaterThanOrEqual(2)
    await expect(page.locator(".path-builder-code")).toContainText("FolderNode")
    await expect(page.locator(".path-builder-code")).toContainText("RecordNode")
    await expect(page.getByRole("button", { name: "Open" }).first()).toBeVisible()
    await expect(page.getByRole("button", { name: "Download" })).toHaveAttribute("aria-disabled", "true")
  })

  test("non-exempt focused mockups avoid document-level horizontal overflow at narrow width", async ({ page }) => {
    const overflowingMockups = []
    const checkedMockups = focusedMockupSmokeTargets.filter((mockup) => !narrowOverflowExpectedMockups.has(mockup.file))

    await page.setViewportSize({ width: 390, height: 900 })

    for (const mockup of checkedMockups) {
      await openMockup(page, mockup.file)
      const overflow = await documentHorizontalOverflow(page)

      if (overflow > 1) {
        overflowingMockups.push(`${mockup.file} (${overflow}px)`)
      }
    }

    expect(overflowingMockups).toEqual([])
  })

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
