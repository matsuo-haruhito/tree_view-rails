import { readFileSync } from "node:fs"
import path from "node:path"
import { fileURLToPath } from "node:url"
import YAML from "yaml"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)
const repoRoot = path.resolve(__dirname, "..")

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function loadManifest() {
  const manifestPath = path.join(repoRoot, "config", "public_api_manifest.yml")
  return YAML.parse(readFileSync(manifestPath, "utf8"))
}

function flattenYamlValues(value) {
  if (Array.isArray(value)) return value.flatMap(flattenYamlValues)
  if (value && typeof value === "object") return Object.values(value).flatMap(flattenYamlValues)
  return [value]
}

function readRepoFile(relativePath) {
  return readFileSync(path.join(repoRoot, relativePath), "utf8")
}

function assertTopLevelKeys(manifest) {
  const expectedKeys = [
    "module_methods",
    "configuration_options",
    "public_constants",
    "localized_name_i18n_keys",
    "filtered_tree_modes",
    "visible_rows_row_metadata",
    "node_presenter_builder_names",
    "graph_adapter_initializer",
    "ui_config_builder_option_keys",
    "path_tree_builder_node_shapes",
    "helper_methods",
    "helper_option_keys",
    "render_window_metadata",
    "toolbar_actions",
    "toolbar_action_metadata",
    "setup_generators",
    "grouped_option_keys",
    "diagnostics",
    "resource_table_render_state_call",
    "render_state_callback_builder_keys",
    "javascript_package_root"
  ]

  expectedKeys.forEach((key) => {
    assert(key in manifest, `config/public_api_manifest.yml missing top-level key: ${key}`)
  })

  const unexpectedKeys = Object.keys(manifest).filter((key) => !expectedKeys.includes(key)).sort()
  assert(
    unexpectedKeys.length === 0,
    `config/public_api_manifest.yml contains unexpected top-level key(s): ${unexpectedKeys.join(", ")}. Update script/test_public_api_manifest_structure.mjs before adding manifest sections.`
  )
}

function assertArraySection(manifest, key) {
  assert(Array.isArray(manifest[key]), `config/public_api_manifest.yml ${key} must be an array`)
}

function assertStringValues(section, key) {
  flattenYamlValues(section).forEach((value) => {
    assert(typeof value === "string", `config/public_api_manifest.yml ${key} values must be strings`)
    assert(value.trim().length > 0, `config/public_api_manifest.yml ${key} values must be non-empty`)
  })
}

function assertFileIncludes(relativePath, expectedText, label) {
  const source = readRepoFile(relativePath)
  assert(
    source.includes(expectedText),
    `${label}: ${relativePath} is missing ${expectedText}`
  )
}

const manifest = loadManifest()
assertTopLevelKeys(manifest)

for (const key of [
  "module_methods",
  "configuration_options",
  "public_constants",
  "localized_name_i18n_keys",
  "filtered_tree_modes",
  "visible_rows_row_metadata",
  "node_presenter_builder_names",
  "graph_adapter_initializer",
  "ui_config_builder_option_keys",
  "path_tree_builder_node_shapes",
  "helper_methods",
  "helper_option_keys",
  "render_window_metadata",
  "toolbar_actions",
  "toolbar_action_metadata",
  "setup_generators",
  "grouped_option_keys",
  "diagnostics",
  "render_state_callback_builder_keys"
]) {
  assertArraySection(manifest, key)
  assertStringValues(manifest[key], key)
}

assert(typeof manifest.resource_table_render_state_call === "string", "resource_table_render_state_call must be a string")
assert(typeof manifest.javascript_package_root === "string", "javascript_package_root must be a string")

manifest.helper_methods.forEach((methodName) => {
  assertFileIncludes("app/helpers/tree_view_helper.rb", `def ${methodName}`, `helper method ${methodName}`)
})

manifest.configuration_options.forEach((optionName) => {
  assertFileIncludes("lib/tree_view/configuration.rb", optionName, `configuration option ${optionName}`)
})

manifest.localized_name_i18n_keys.forEach((key) => {
  assertFileIncludes("config/locales/en.yml", key, `localized name i18n key ${key}`)
})

manifest.toolbar_actions.forEach((actionName) => {
  assertFileIncludes("app/helpers/tree_view_helper.rb", actionName, `toolbar action ${actionName}`)
})

console.log("Checked public API manifest structure.")
