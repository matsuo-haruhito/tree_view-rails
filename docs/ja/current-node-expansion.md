# Current node expansion

`TreeView::RenderState` は、初期描画時に現在nodeのancestorを自動展開できます。

詳細画面や選択中recordを開くときに、そのrecordまでの親階層だけを表示し、その他のtreeは折りたたみ状態から始めたい場合に使います。

## 基本例

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    current_key: tree.node_key_for(current_document),
    auto_expand_ancestors: true
  }
)
```

現在recordを直接渡すこともできます。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  current_item: current_document,
  auto_expand_ancestors: true,
  initial_expansion: { default: :collapsed }
)
```

## 挙動

`auto_expand_ancestors: true` を指定すると、TreeView は現在nodeのancestorを `expanded_keys` に追加します。

現在node自体は自動では追加しません。ancestorを開けば現在行まで到達でき、leafの展開意味も保てるためです。

既存の `expanded_keys` は保持され、生成されたancestor keyと重複排除されます。

`current_key` を使う場合、その値は `root_items` 配下にあるnodeの `tree.node_key_for(item)` と一致する必要があります。一致するnodeが見つからず、明示的な `expanded_keys` もない場合は `TreeView::ConfigurationError` をraiseします。

## grouped options

`current_item`, `current_key`, `auto_expand_ancestors` は、top-level の `RenderState` optionとしても、`initial_expansion` group内でも指定できます。

```ruby
initial_expansion: {
  default: :collapsed,
  current_key: current_key,
  auto_expand_ancestors: true
}
```

top-level option は他の `RenderState` option と同じく、grouped value より優先されます。

## 責務境界

TreeView はancestor expansion keyの計算だけを担います。どのnodeを現在nodeとするか、現在行をどうstyle / markするかはhost appの責務です。現在行の表示には `row_class_builder`, `row_data_builder` など既存のrow hookや、host app側で制御するARIA属性を使ってください。
