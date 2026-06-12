import { existsSync, readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..")

function read(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function assertRelativeLink(sourcePath, href, feature) {
  const source = read(sourcePath)
  const target = href.split("#", 1)[0]
  const resolvedTarget = path.resolve(path.dirname(path.join(repoRoot, sourcePath)), target)

  assert(
    source.includes(href),
    `${feature}: ${sourcePath} does not link to ${href}`
  )
  assert(
    resolvedTarget.startsWith(repoRoot) && existsSync(resolvedTarget),
    `${feature}: ${sourcePath} links to missing local target ${href}`
  )
}

function assertSignals(sourcePath, feature, signals) {
  const source = read(sourcePath)

  signals.forEach((signal) => {
    assert(
      source.includes(signal),
      `${feature}: ${sourcePath} is missing representative signal ${JSON.stringify(signal)}`
    )
  })
}

const feature = "Public Setup Surface docs"

;[
  ["docs/README.md", "en/public-setup-surface.md"],
  ["docs/README.md", "ja/public-setup-surface.md"]
].forEach(([sourcePath, href]) => assertRelativeLink(sourcePath, href, feature))

assertSignals("docs/en/public-setup-surface.md", feature, [
  "bin/rails generate tree_view:state:install",
  "bin/rails generate tree_view:state:install User",
  "config/public_api_manifest.yml",
  "db/migrate/*_create_tree_view_states.rb",
  "app/models/tree_view_state.rb",
  "app/models/concerns/tree_view_state_owner.rb",
  "review the generated files in the host app",
  "Storage ownership, authorization, save timing, controller actions, and UI wiring remain host-app responsibilities"
])

assertSignals("docs/ja/public-setup-surface.md", feature, [
  "bin/rails generate tree_view:state:install",
  "bin/rails generate tree_view:state:install User",
  "config/public_api_manifest.yml",
  "db/migrate/*_create_tree_view_states.rb",
  "app/models/tree_view_state.rb",
  "app/models/concerns/tree_view_state_owner.rb",
  "生成後のファイルは host app 側で確認してください",
  "storage ownership、認可、保存タイミング、controller action、UI wiring は host app 側の責務です"
])
