import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const rootReadme = readFileSync(path.join(repoRoot, "README.md"), "utf8")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function extractSection(source, heading) {
  const headingLine = `## ${heading}`
  const headingStart = source.indexOf(`${headingLine}\n`)

  assert(headingStart >= 0, `README.md is missing the ${heading} section`)

  const sectionStart = headingStart + headingLine.length + 1
  const nextHeadingStart = source.indexOf("\n## ", sectionStart)

  return source.slice(
    sectionStart,
    nextHeadingStart === -1 ? undefined : nextHeadingStart
  )
}

function assertQuickStartSignal(signal, pattern, message) {
  assert(pattern.test(quickStart), `README.md Quick Start ${signal}: ${message}`)
}

const quickStart = extractSection(rootReadme, "Quick Start")

assertQuickStartSignal(
  "controller label",
  /Controller:/,
  "missing the controller example label"
)

assertQuickStartSignal(
  "TreeView::Tree",
  /TreeView::Tree/,
  "missing the representative tree construction signal"
)

assertQuickStartSignal(
  "UiConfigBuilder static build",
  /TreeView::UiConfigBuilder[\s\S]*build_static/,
  "missing the representative TreeView::UiConfigBuilder#build_static signal"
)

assertQuickStartSignal(
  "RenderState",
  /TreeView::RenderState/,
  "missing the representative render state construction signal"
)

assertQuickStartSignal(
  "row partial option",
  /row_partial:\s*"projects\/tree_columns"/,
  "missing the row_partial option path"
)

assertQuickStartSignal(
  "view label",
  /View:/,
  "missing the view example label"
)

assertQuickStartSignal(
  "tree_view_rows call",
  /tree_view_rows\(@render_state\)/,
  "missing the representative tree_view_rows(@render_state) call"
)

assertQuickStartSignal(
  "row partial label",
  /Row partial:/,
  "missing the row partial example label"
)

assertQuickStartSignal(
  "row partial file path",
  /app\/views\/projects\/_tree_columns\.html\.erb/,
  "missing the row partial file path"
)
