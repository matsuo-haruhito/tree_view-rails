import axe from "axe-core"
import { expect, test } from "@playwright/test"

async function openFixture(page, markup) {
  await page.goto("/browser_smoke.html")
  await page.evaluate((html) => window.treeViewSmoke.mount(html), markup)
}

function formatViolations(violations) {
  return violations.map((violation) => {
    const targets = violation.nodes.map((node) => node.target.join(" ")).join(", ")
    return `${violation.id}: ${violation.help} (${targets})`
  }).join("\n")
}

async function expectNoAxeViolations(page, label, options = {}) {
  if (!await page.evaluate(() => Boolean(window.axe))) {
    await page.addScriptTag({ content: axe.source })
  }

  const results = await page.evaluate(async ({ context, axeOptions }) => {
    return window.axe.run(context, axeOptions)
  }, { context: "#fixture", axeOptions: options })

  expect(results.violations, `${label}\n${formatViolations(results.violations)}`).toEqual([])
}

// TreeView intentionally keeps native table semantics and places row-level ARIA
// state on table rows. The documented policy lives in
// docs/en/accessibility-semantics.md and docs/ja/accessibility-semantics.md, so
// this first smoke keeps that allowance explicit instead of silently suppressing
// table-first findings.
const tableFirstAxeOptions = {
  runOnly: {
    type: "tag",
    values: ["wcag2a", "wcag2aa"]
  },
  rules: {
    "aria-allowed-attr": { enabled: false }
  }
}

test.afterEach(async ({ page }) => {
  await page.evaluate(() => window.treeViewSmoke.reset())
})

test("static, collapsed, and checkbox selection fixtures pass the baseline a11y smoke", async ({ page }) => {
  await openFixture(page, `
    <table aria-label="Project tree static accessibility baseline">
      <thead>
        <tr>
          <th scope="col">Project</th>
          <th scope="col">Selection</th>
        </tr>
      </thead>
      <tbody>
        <tr id="project-alpha" tabindex="0" data-tree-depth="0" aria-level="1" aria-expanded="true" aria-current="page">
          <th scope="row">
            <button type="button" aria-label="Collapse Project Alpha">Collapse</button>
            Project Alpha
          </th>
          <td>
            <input id="select-alpha" class="tree-selection-checkbox" type="checkbox" aria-label="Select Project Alpha" checked>
          </td>
        </tr>
        <tr id="project-alpha-child" tabindex="0" data-tree-depth="1" aria-level="2">
          <th scope="row">Project Alpha child</th>
          <td>
            <input id="select-alpha-child" class="tree-selection-checkbox" type="checkbox" aria-label="Select Project Alpha child">
          </td>
        </tr>
        <tr id="project-beta" tabindex="0" data-tree-depth="0" aria-level="1" aria-expanded="false">
          <th scope="row">
            <button type="button" aria-label="Expand Project Beta">Expand</button>
            Project Beta
          </th>
          <td>
            <input id="select-beta" class="tree-selection-checkbox" type="checkbox" aria-label="Select Project Beta">
          </td>
        </tr>
        <tr id="project-beta-child" data-tree-depth="1" aria-level="2" hidden>
          <th scope="row">Project Beta hidden child</th>
          <td>
            <input id="select-beta-child" class="tree-selection-checkbox" type="checkbox" aria-label="Select Project Beta child">
          </td>
        </tr>
      </tbody>
    </table>
  `)

  await expect(page.locator("#project-alpha")).toHaveAttribute("aria-current", "page")
  await expect(page.locator("#project-beta")).toHaveAttribute("aria-expanded", "false")
  await expect(page.locator("#select-alpha")).toBeChecked()

  await expectNoAxeViolations(page, "static/collapsed/selection fixture", tableFirstAxeOptions)
})

test("windowed rendering and dynamic state fixtures pass a11y smoke after state changes", async ({ page }) => {
  await openFixture(page, `
    <table
      aria-label="Project tree dynamic accessibility baseline"
      data-controller="tree-view-state tree-view-remote-state"
      data-tree-view-state-keyboard-value="true"
      data-action="keydown->tree-view-state#keydown"
    >
      <caption>Windowed project tree rows 11 through 14 of 42</caption>
      <thead>
        <tr>
          <th scope="col">Project</th>
          <th scope="col">State action</th>
        </tr>
      </thead>
      <tbody>
        <tr id="window-start" tabindex="0" data-tree-depth="1" aria-rowindex="11" aria-level="2">
          <th scope="row">Visible window start</th>
          <td>Before rows are summarized by the host pagination controls.</td>
        </tr>
        <tr id="toggle-row" tabindex="0" data-tree-depth="1" aria-rowindex="12" aria-level="2" aria-expanded="false" data-tree-view-state-target="node" data-tree-view-state-node-key="project:toggle" data-tree-view-state-expanded="false">
          <th scope="row">
            <button id="expand-toggle" type="button" aria-label="Expand Project Toggle" aria-controls="toggle-child" data-action="click->tree-view-state#markExpanded">Expand</button>
            Project Toggle
          </th>
          <td>Client-side toggle state</td>
        </tr>
        <tr id="toggle-child" data-tree-depth="2" aria-rowindex="13" aria-level="3" hidden>
          <th scope="row">Project Toggle child</th>
          <td>Hidden until expanded</td>
        </tr>
        <tr id="remote-row" tabindex="0" data-tree-depth="1" aria-rowindex="14" aria-level="2" aria-busy="false" data-tree-view-state-target="node" data-tree-view-state-node-key="project:remote" data-tree-children-url="/projects/remote/children">
          <th scope="row">Project Remote</th>
          <td>
            <button id="mark-loading" type="button" data-action="click->tree-view-remote-state#loading">Mark loading</button>
            <button id="mark-loaded" type="button" data-action="click->tree-view-remote-state#loaded">Mark loaded</button>
          </td>
        </tr>
      </tbody>
    </table>
  `)

  await expectNoAxeViolations(page, "windowed dynamic fixture before state changes", tableFirstAxeOptions)

  await page.locator("#expand-toggle").click()
  await expect(page.locator("#toggle-row")).toHaveAttribute("data-tree-view-state-expanded", "true")
  await page.locator("#toggle-row").evaluate((row) => row.setAttribute("aria-expanded", "true"))
  await page.locator("#toggle-child").evaluate((row) => row.hidden = false)

  await page.locator("#mark-loading").click()
  await expect(page.locator("#remote-row")).toHaveAttribute("data-remote-state", "loading")
  await page.locator("#remote-row").evaluate((row) => row.setAttribute("aria-busy", "true"))

  await expectNoAxeViolations(page, "windowed dynamic fixture after expand and loading changes", tableFirstAxeOptions)

  await page.locator("#mark-loaded").click()
  await expect(page.locator("#remote-row")).toHaveAttribute("data-remote-state", "loaded")
  await page.locator("#remote-row").evaluate((row) => row.setAttribute("aria-busy", "false"))

  await expectNoAxeViolations(page, "windowed dynamic fixture after loaded state", tableFirstAxeOptions)
})
