import { execFileSync } from "node:child_process"

function loadManifest() {
  try {
    return JSON.parse(
      execFileSync(
        "ruby",
        [
          "-e",
          [
            'require "json"',
            'require "yaml"',
            'data = YAML.load_file("config/public_api_manifest.yml")',
            "print JSON.generate(data)"
          ].join("; ")
        ],
        { encoding: "utf8" }
      )
    )
  } catch (error) {
    const detail = [error.stdout, error.stderr]
      .filter((output) => output && output.length > 0)
      .join("\n")
      .trim() || error.message

    throw new Error(
      [
        "Could not load config/public_api_manifest.yml for the manifest structure smoke.",
        "Run this command from the repository root with Ruby available, or inspect the manifest YAML syntax.",
        `Loader output: ${detail}`
      ].join("\n"),
      { cause: error }
    )
  }
}

function assert(condition, message) {
  if (!condition) throw new Error(message)
}

function valueType(value) {
  if (Array.isArray(value)) return "array"
  if (value === null) return "null"

  return typeof value
}

function assertObject(value, path) {
  assert(
    value && typeof value === "object" && !Array.isArray(value),
    `${path} must be an object, got ${valueType(value)}`
  )
}

function assertString(value, path) {
  assert(typeof value === "string" && value.length > 0, `${path} must be a non-empty string`)
}

function assertUniqueStringList(value, path) {
  assert(Array.isArray(value), `${path} must be an array, got ${valueType(value)}`)
  assert(value.length > 0, `${path} must not be empty`)

  const seenValues = new Set()

  value.forEach((item, index) => {
    assertString(item, `${path}[${index}]`)
    assert(!seenValues.has(item), `${path} contains duplicate value: ${item}`)
    seenValues.add(item)
  })
}

function assertStringMap(value, path) {
  assertObject(value, path)
  Object.entries(value).forEach(([key, item]) => {
    assertString(item, `${path}.${key}`)
  })
}

function assertObjectWithLists(value, path, keys) {
  assertObject(value, path)
  keys.forEach((key) => assertUniqueStringList(value[key], `${path}.${key}`))
}

function assertEntries(value, path, requiredKeys) {
  assert(Array.isArray(value), `${path} must be an array, got ${valueType(value)}`)
  assert(value.length > 0, `${path} must not be empty`)

  value.forEach((entry, index) => {
    assertObject(entry, `${path}[${index}]`)
    requiredKeys.forEach((key) => assertString(entry[key], `${path}[${index}].${key}`))
  })
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
}

const manifest = loadManifest()

assertTopLevelKeys(manifest)
assertUniqueStringList(manifest.module_methods, "module_methods")
assertObjectWithLists(manifest.configuration_options, "configuration_options", ["tree_view_configure"])
assertUniqueStringList(manifest.public_constants, "public_constants")
assertUniqueStringList(manifest.filtered_tree_modes, "filtered_tree_modes")
assertObjectWithLists(manifest.visible_rows_row_metadata, "visible_rows_row_metadata", ["fields", "predicates"])
assertUniqueStringList(manifest.node_presenter_builder_names, "node_presenter_builder_names")
assertObjectWithLists(manifest.graph_adapter_initializer, "graph_adapter_initializer", ["required_keywords", "optional_keywords"])
assertObjectWithLists(manifest.helper_option_keys, "helper_option_keys", Object.keys(manifest.helper_option_keys))
assertUniqueStringList(manifest.render_window_metadata, "render_window_metadata")
assertStringMap(manifest.toolbar_actions, "toolbar_actions")
assertObjectWithLists(manifest.toolbar_action_metadata, "toolbar_action_metadata", ["keys", "data_keys"])
assertObjectWithLists(manifest.grouped_option_keys, "grouped_option_keys", Object.keys(manifest.grouped_option_keys))
assertObjectWithLists(manifest.resource_table_render_state_call, "resource_table_render_state_call", ["required_keywords", "optional_keywords"])
assertString(manifest.resource_table_render_state_call.render_options_contract, "resource_table_render_state_call.render_options_contract")
assertUniqueStringList(manifest.render_state_callback_builder_keys, "render_state_callback_builder_keys")

assertObject(manifest.localized_name_i18n_keys, "localized_name_i18n_keys")
for (const [name, config] of Object.entries(manifest.localized_name_i18n_keys)) {
  assertObject(config, `localized_name_i18n_keys.${name}`)
  assertString(config.helper, `localized_name_i18n_keys.${name}.helper`)
  assertString(config.fallback, `localized_name_i18n_keys.${name}.fallback`)
}
assertUniqueStringList(
  manifest.localized_name_i18n_keys.model_names.delegated_lookup_prefixes,
  "localized_name_i18n_keys.model_names.delegated_lookup_prefixes"
)
assertUniqueStringList(
  manifest.localized_name_i18n_keys.attribute_names.delegated_lookup_prefixes,
  "localized_name_i18n_keys.attribute_names.delegated_lookup_prefixes"
)
assertString(
  manifest.localized_name_i18n_keys.node_type_names.lookup_prefix,
  "localized_name_i18n_keys.node_type_names.lookup_prefix"
)

assertObject(manifest.setup_generators.persisted_state_install, "setup_generators.persisted_state_install")
assertString(manifest.setup_generators.persisted_state_install.name, "setup_generators.persisted_state_install.name")
assertString(manifest.setup_generators.persisted_state_install.class_name, "setup_generators.persisted_state_install.class_name")
assertUniqueStringList(
  manifest.setup_generators.persisted_state_install.generated_paths,
  "setup_generators.persisted_state_install.generated_paths"
)

assertObject(manifest.diagnostics, "diagnostics")
assertUniqueStringList(manifest.diagnostics.accepted_checks, "diagnostics.accepted_checks")
assertUniqueStringList(manifest.diagnostics.run_options, "diagnostics.run_options")
assertObjectWithLists(manifest.diagnostics.result_surface, "diagnostics.result_surface", ["attributes", "methods"])

const javascriptPackageRoot = manifest.javascript_package_root
assertObject(javascriptPackageRoot, "javascript_package_root")
assertUniqueStringList(javascriptPackageRoot.named_exports, "javascript_package_root.named_exports")
assertEntries(javascriptPackageRoot.controller_registrations, "javascript_package_root.controller_registrations", ["key", "identifier", "export"])
assertStringMap(javascriptPackageRoot.transfer_drop_positions, "javascript_package_root.transfer_drop_positions")
assertStringMap(javascriptPackageRoot.transfer_data_mime_types, "javascript_package_root.transfer_data_mime_types")
assertStringMap(javascriptPackageRoot.remote_state_values, "javascript_package_root.remote_state_values")
assertStringMap(javascriptPackageRoot.remote_state_data_hooks, "javascript_package_root.remote_state_data_hooks")
assertStringMap(javascriptPackageRoot.toolbar_data_hooks, "javascript_package_root.toolbar_data_hooks")
assertStringMap(javascriptPackageRoot.integration_hooks.state, "javascript_package_root.integration_hooks.state")
assertStringMap(javascriptPackageRoot.integration_hooks.remote_state, "javascript_package_root.integration_hooks.remote_state")
assertStringMap(javascriptPackageRoot.integration_hooks.transfer, "javascript_package_root.integration_hooks.transfer")
assertStringMap(javascriptPackageRoot.selection_data_hooks, "javascript_package_root.selection_data_hooks")
assertStringMap(javascriptPackageRoot.selection_checkbox_hooks, "javascript_package_root.selection_checkbox_hooks")
assertStringMap(javascriptPackageRoot.empty_state_hooks, "javascript_package_root.empty_state_hooks")

assertObject(javascriptPackageRoot.event_names, "javascript_package_root.event_names")
assertObject(javascriptPackageRoot.event_detail_keys, "javascript_package_root.event_detail_keys")
assertObject(javascriptPackageRoot.event_names_without_detail, "javascript_package_root.event_names_without_detail")

Object.entries(javascriptPackageRoot.event_names).forEach(([group, events]) => {
  assertStringMap(events, `javascript_package_root.event_names.${group}`)
})

Object.entries(javascriptPackageRoot.event_detail_keys).forEach(([group, events]) => {
  assertObject(events, `javascript_package_root.event_detail_keys.${group}`)
  Object.entries(events).forEach(([eventName, keys]) => {
    assertUniqueStringList(keys, `javascript_package_root.event_detail_keys.${group}.${eventName}`)
  })
})

Object.entries(javascriptPackageRoot.event_names_without_detail).forEach(([group, eventNames]) => {
  assertUniqueStringList(eventNames, `javascript_package_root.event_names_without_detail.${group}`)
})

console.log("Public API manifest structure smoke passed.")
