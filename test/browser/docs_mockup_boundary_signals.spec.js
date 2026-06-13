import { expect, test } from "@playwright/test"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")

function mockupUrl(file) {
  return pathToFileURL(path.join(mockupsRoot, file)).toString()
}

async function openMockup(page, file) {
  await page.goto(mockupUrl(file))
  await expect(page.locator("main.mock-page")).toBeVisible()
}

test.describe("docs mockup boundary signals", () => {
  test("breadcrumb-paths.html preserves current-row, long-path, and host-owned boundary signals", async ({ page }) => {
    await openMockup(page, "breadcrumb-paths.html")

    await expect(page.getByRole("heading", { name: "Shallow path with current item at the end" })).toBeVisible()
    await expect(page.locator(".mock-breadcrumb-pill--current[aria-current='page']", { hasText: "Admin UI" })).toBeVisible()
    await expect(page.locator("#breadcrumb_current[aria-current='page'] .tree-node-badge--current", { hasText: "current row" })).toBeVisible()

    await expect(page.getByRole("heading", { name: "Long labels in a narrow breadcrumb frame" })).toBeVisible()
    await expect(page.locator(".mock-breadcrumb-frame--narrow")).toBeVisible()
    await expect(page.locator(".mock-breadcrumb-path--stress .mock-breadcrumb-pill--stress", { hasText: "Current review item with a deliberately long label" })).toBeVisible()

    await expect(page.getByText("Exact URLs, truncation rules, and permission-aware labels still belong to the host app.", { exact: false })).toBeVisible()
    await expect(page.getByText("Real route helpers, final labels, authorization-aware visibility, and Turbo navigation.", { exact: false })).toBeVisible()
  })

  test("localized-row-labels.html preserves CJK review samples and identity boundary signals", async ({ page }) => {
    await openMockup(page, "localized-row-labels.html")

    await expect(page.getByText("Deliberate CJK width stress sample", { exact: true })).toBeVisible()
    await expect(page.getByRole("heading", { name: "Japanese-width label stress sample" })).toBeVisible()
    await expect(page.locator("table[lang='ja']")).toBeVisible()
    await expect(page.locator("table[lang='ja'] .mock-localized-type--accent", { hasText: "確認資料タイプ" })).toBeVisible()
    await expect(page.getByText("It is not final product copy.", { exact: false })).toBeVisible()

    await expect(page.getByRole("heading", { name: "Node key and DOM ID boundary note" })).toBeVisible()
    await expect(page.locator("[data-tree-node-key='localized-cjk:invoice']")).toHaveCount(3)
    await expect(page.locator("code", { hasText: "workspace_tree_localized_cjk_invoice" })).toBeVisible()
    await expect(page.locator("code", { hasText: "picker_tree_localized_cjk_invoice" })).toBeVisible()
    await expect(page.getByText("Use the node key for data identity; use the DOM ID only for this rendered browser target.", { exact: true })).toBeVisible()
  })
}
