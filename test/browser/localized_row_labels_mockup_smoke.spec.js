import { expect, test } from "@playwright/test"
import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")
const mockupsRoot = path.join(repoRoot, "docs/mockups")
const localizedMockupPath = path.join(mockupsRoot, "localized-row-labels.html")
const mockupsReadmePath = path.join(mockupsRoot, "README.md")

function mockupUrl(file) {
  return pathToFileURL(path.join(mockupsRoot, file)).toString()
}

function deliberateExceptionRowFor(readme, file) {
  return readme
    .split("## Selection form guidance", 2)[0]
    .split("\n")
    .find((line) => line.includes(`| \`${file}\``))
}

test.describe("localized row labels mockup smoke", () => {
  test("keeps long localized label and metadata stress signals visible", async ({ page }) => {
    await page.goto(mockupUrl("localized-row-labels.html"))

    await expect(page.getByRole("heading", { name: "Localized row labels mock", level: 1 })).toBeVisible()
    await expect(page.getByRole("heading", { name: "Long localized label stress sample", level: 2 })).toBeVisible()
    await expect(page.getByRole("heading", { name: "Japanese-width label stress sample", level: 2 })).toBeVisible()
    await expect(page.getByText("Quarterly Planning Portfolio With Region-Specific Review Naming")).toBeVisible()
    await expect(page.getByText("International Budget Approval Label That Must Stay Readable")).toBeVisible()
    await expect(page.getByText("Translated document type")).toBeVisible()
    await expect(page.getByText("Attribute label: Last translated approval stage")).toBeVisible()
    await expect(page.getByText("Tooltip cue: full localized label is available on the primary link.")).toBeVisible()
    await expect(page.getByText("四半期契約レビューの地域別確認資料と承認経路一覧")).toBeVisible()
    await expect(page.getByText("属性ラベル: 最終確認ステージと担当部門")).toBeVisible()
    await expect(page.getByText("Final translations, truncation rules, tooltip text, permission copy, and business-specific labels remain outside this mockup.")).toBeVisible()

    await expect(page.locator(".mock-localized-type")).toHaveCount(5)
    await expect(page.locator(".mock-localized-attribute")).toHaveCount(5)
    await expect(page.locator(".mock-localized-tooltip-cue")).toHaveCount(2)
    await expect(page.locator(".tree-row[aria-current='page']")).toHaveCount(2)
  })

  test("keeps the deliberate copy exception documented in the mockup README", () => {
    const readme = readFileSync(mockupsReadmePath, "utf8")
    const mockup = readFileSync(localizedMockupPath, "utf8")
    const row = deliberateExceptionRowFor(readme, "localized-row-labels.html")

    expect(row).toContain("Long localized-style row labels and metadata, plus deliberate CJK / Japanese-width sample text")
    expect(row).toContain("CJK character width / badge proximity using intentional Japanese sample copy.")
    expect(mockup).toContain("Deliberate CJK width stress sample")
    expect(mockup).toContain("Final translation、permission wording、business action labels remain host-app owned.")
  })
})
