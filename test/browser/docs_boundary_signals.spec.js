import { expect, test } from "@playwright/test"
import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath, pathToFileURL } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../..")

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function mockupUrl(file) {
  return pathToFileURL(path.join(repoRoot, "docs/mockups", file)).toString()
}

test.describe("docs responsibility boundary smoke", () => {
  test("README keeps host-app responsibility and out-of-scope signals", () => {
    const readme = read("README.md")

    expect(readme).toContain("TreeView does not provide:")
    expect(readme).toContain("## Out of scope")

    for (const signal of [
      "a complete file-manager application",
      "CRUD screens",
      "authorization policies",
      "product-specific context menus or bulk actions",
      "server-side pagination algorithms",
      "a full virtual scrolling engine",
      "demo data and seeds"
    ]) {
      expect(readme, `README.md is missing out-of-scope signal ${JSON.stringify(signal)}`).toContain(signal)
    }

    for (const signal of [
      "host app owns the records, queries, routes, authorization, and business behavior",
      "application-specific CRUD, authorization, and business actions to the host Rails app",
      "TreeView exposes reusable wrapper hooks for styling; final empty copy, CTAs, and filter-reset behavior stay in the host app"
    ]) {
      expect(readme, `README.md is missing host-app responsibility signal ${JSON.stringify(signal)}`).toContain(signal)
    }
  })

  test("minimal-usage-first-render.html keeps first-render included and excluded boundaries visible", async ({ page }) => {
    await page.goto(mockupUrl("minimal-usage-first-render.html"))

    await expect(page.getByRole("heading", { name: "Minimal usage first render mock", level: 1 })).toBeVisible()
    await expect(page.getByRole("heading", { name: "First rendered tree from the minimal setup", level: 2 })).toBeVisible()
    await expect(page.getByRole("heading", { name: "Minimal usage boundary", level: 2 })).toBeVisible()

    await expect(page.locator("[data-tree-view-sample='minimal-usage-first-render'] .tree-view-table tbody tr")).toHaveCount(3)
    await expect(page.getByText("Initial table wrapper, hierarchy cells, expanded/collapsed/leaf cues, and the plain row partial output.", { exact: true })).toBeVisible()
    await expect(page.getByText("Checkbox selection, badges, row actions, CRUD links, routes, authorization copy, and seeded demo records.", { exact: true })).toBeVisible()

    await expect(page.locator("input[type='checkbox']")).toHaveCount(0)
    await expect(page.getByRole("button")).toHaveCount(0)
    await expect(page.getByRole("link", { name: /new|edit|delete|download|open/i })).toHaveCount(0)
    await expect(page.getByText(/seeded demo records/i)).toBeVisible()
  })
})
