# UiConfigBuilder option surface

`TreeView::UiConfigBuilder` は、Turbo / static / client-side rendering mode 用の `TreeView::UiConfig` を組み立てる公開 entry point です。builder method の keyword surface は、option 名の drift を compatibility check で検出できるように、`config/public_api_manifest.yml` の `ui_config_builder_option_keys` で追跡します。

この manifest section は key surface の contract であり、runtime validation schema ではありません。host app は documented builder method を直接使い、TreeView は manifest から route、Turbo、lazy-loading behavior を新しく推論しません。

## Manifest-backed keyword groups

| Method | manifest-backed public keywords | 補足 |
|---|---|---|
| `build` | `show_descendants_path_builder`, `hide_descendants_path_builder`, `toggle_all_path_builder`, `load_children_path_builder`, `turbo_frame`, `indent_unit`, `scope_format` | `build_turbo` と同じ keyword surface を持つ Turbo mode への convenience entry point です。 |
| `build_turbo` | `show_descendants_path_builder`, `hide_descendants_path_builder`, `toggle_all_path_builder`, `load_children_path_builder`, `turbo_frame`, `indent_unit`, `scope_format` | Turbo-oriented configuration です。route helper、authorization、Turbo Frame target、lazy-loading response behavior は引き続き host app が所有します。 |
| `build_static` | `indent_unit` | static rendering は indentation surface のみに閉じ、Turbo path builder は受け取りません。 |
| `build_client_side` | `indent_unit` | client-side rendering は indentation surface のみに閉じ、Turbo path builder は受け取りません。 |

## Boundary

compatibility spec は method signature と manifest の一致を確認します。required / optional keyword policy、route builder behavior、Turbo response behavior、lazy-loading strategy の runtime validation を新設するものではありません。

behavior guidance は以下の既存 docs を参照してください。

- [Usage](usage.md)
- [API reference](api.md)
- [Turbo Frame option](turbo-frame.md)
- [Lazy Loading](lazy-loading.md)
