import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")
const rootReadme = readFileSync(path.join(repoRoot, "README.md"), "utf8")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

assert(
  /## Quick Start[\s\S]*Controller:[\s\S]*TreeView::Tree[\s\S]*TreeView::UiConfigBuilder[\s\S]*build_static[\s\S]*TreeView::RenderState[\s\S]*row_partial:\s*"projects\/tree_columns"[\s\S]*View:[\s\S]*tree_view_rows\(@render_state\)[\s\S]*Row partial:[\s\S]*app\/views\/projects\/_tree_columns\.html\.erb/.test(rootReadme),
  "README.md Quick Start no longer exposes the representative controller/view/row-partial path"
)
