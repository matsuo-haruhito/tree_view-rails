import { expect, test } from "@playwright/test"
import { pathToFileURL } from "node:url"
import path from "node:path"

const repoRoot = path.resolve(import.meta.dirname, "../..")

function mockupUrl(name) {
  return pathToFileURL(path.join(repoRoot, "docs/mockups", name)).href
}

test.describe("toolbar actions mockup focused signals", () => {
  test("keeps collapse-to-current, fallback, localization, and host boundary signals visible", async ({ page }) => {
    await page.goto(mockupUrl("toolbar-actions.html"))

    await expect(page.locator("[data-mock-state='expand-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-state='collapse-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-state='current-path-enabled']")).toBeVisible()
    await expect(page.locator("[data-mock-state='current-path-current'][data-mock-boundary='current-path-active']")).toBeVisible()
    await expect(page.locator("[data-mock-state='localized-current-path-current'][data-mock-boundary='localized-current-path-active']")).toBeVisible()

    await expect(page.locator("[data-mock-boundary='metadata-missing-path-fallback']")).toBeVisible()
    await expect(page.locator("[data-mock-boundary='metadata-disabled-fallback']")).toHaveCount(2)

    await expect(page.getByText("すべての部署とチームを展開", { exact: true })).toBeVisible()
    await expect(page.getByText("現在の申請ルートだけを表示", { exact: true })).toBeVisible()
    await expect(page.getByText("全階層を折りたたむ", { exact: true })).toBeVisible()

    await expect(page.getByText("Host app owns", { exact: true })).toBeVisible()
    await expect(page.getByText("Route generation, authorization policy, final permission copy, localization, and business-specific action names.", { exact: true })).toBeVisible()
    await expect(page.getByText("Action availability and fallback state stay visible without making this mockup a contract", { exact: false })).toBeVisible()
  })
})
