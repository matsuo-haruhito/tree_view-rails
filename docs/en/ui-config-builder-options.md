# UiConfigBuilder option surface

`TreeView::UiConfigBuilder` is a public entry point for building `TreeView::UiConfig` instances in Turbo, static, and client-side rendering modes. Its builder method keyword surface is tracked in `config/public_api_manifest.yml` under `ui_config_builder_option_keys` so maintainers can catch option-name drift during compatibility checks.

This manifest section is a key-surface contract, not a runtime validation schema. Host apps should keep using the documented builder methods directly, and TreeView should not infer new route, Turbo, or lazy-loading behavior from the manifest.

## Manifest-backed keyword groups

| Method | Manifest-backed public keywords | Notes |
|---|---|---|
| `build` | `show_descendants_path_builder`, `hide_descendants_path_builder`, `toggle_all_path_builder`, `load_children_path_builder`, `turbo_frame`, `indent_unit`, `scope_format` | Convenience entry point that delegates to Turbo mode with the same keyword surface as `build_turbo`. |
| `build_turbo` | `show_descendants_path_builder`, `hide_descendants_path_builder`, `toggle_all_path_builder`, `load_children_path_builder`, `turbo_frame`, `indent_unit`, `scope_format` | Turbo-oriented configuration. Host apps still own route helpers, authorization, Turbo Frame targets, and lazy-loading response behavior. |
| `build_static` | `indent_unit` | Static rendering keeps only the indentation surface and does not accept Turbo path builders. |
| `build_client_side` | `indent_unit` | Client-side rendering keeps only the indentation surface and does not accept Turbo path builders. |

## Boundary

The compatibility spec checks the method signatures against the manifest. It intentionally does not add new validation for required versus optional keyword policy, route builder behavior, Turbo response behavior, or lazy-loading strategy.

Use the broader usage and API docs for behavior guidance:

- [Usage](usage.md)
- [API reference](api.md)
- [Turbo Frame option](turbo-frame.md)
- [Lazy Loading](lazy-loading.md)
