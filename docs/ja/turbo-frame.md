# Turbo frame option

`UiConfigBuilder#build_turbo` は `turbo_frame:` を受け取れます。host app が TreeView のtoggle linkを特定のTurbo Frameへ向けたい場合に、追加JavaScriptなしで使えます。

## 基本例

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document"
).build_turbo(
  hide_descendants_path_builder: ->(item, depth, scope) { hide_document_path(item, depth: depth, scope: scope) },
  show_descendants_path_builder: ->(item, depth, scope) { show_document_path(item, depth: depth, scope: scope) },
  toggle_all_path_builder: ->(state) { documents_path(state: state) },
  turbo_frame: "documents_tree"
)
```

TreeView は Turbo toggle link に frame target を追加します。

```html
<a data-turbo-stream="true" data-turbo-frame="documents_tree" ...>
```

## Scope

このoptionは、TreeView の Turbo toggle link に `data-turbo-frame` を追加するだけです。frame、controller action、authorization、Turbo Stream response は生成しません。

host app は以下を担当します。

- target `<turbo-frame>` の描画
- expand / collapse endpoint の実装
- Turbo Stream または frame-compatible response の返却
- authorization と business rule
- expanded keys の保存

## なぜ TreeView に含めるか

Turbo Frame のtarget指定は tree UI でよく使う Hotwire integration point です。薄い設定値として表現でき、custom JavaScript を増やさず Rails / Turbo 標準に乗せられるため、TreeView 側で支援します。
