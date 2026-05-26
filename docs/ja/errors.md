# Error hierarchy

TreeView は、host app が TreeView 由来の失敗を他の application error と分けて rescue できるように、小さな公開 error hierarchy を提供します。

## 公開 class

| Error class | 親 | 発生する場面 |
|---|---|---|
| `TreeView::Error` | `ArgumentError` | TreeView の公開 validation / configuration failure の基底 class。 |
| `TreeView::ConfigurationError` | `TreeView::Error` | 不正な TreeView option、不正な mode 組み合わせ、不正な builder、未対応の configuration value。 |
| `TreeView::InvalidTreeError` | `TreeView::Error` | tree data を有効な tree として扱えない場合。 |
| `TreeView::DuplicateNodeKeyError` | `TreeView::InvalidTreeError` | `validate_unique_node_keys!` または `validate_node_keys: true` が node key 重複を検出した場合。 |
| `TreeView::CycleDetectedError` | `TreeView::InvalidTreeError` | tree traversal または `validate_no_cycles!` が parent / child cycle を検出した場合。 |
| `TreeView::InvalidRenderWindowError` | `TreeView::Error` | `RenderWindow` に不正な `offset` または `limit` が渡された場合。 |

`TreeView::Error` は、既存 host app が TreeView の従来の validation failure を `ArgumentError` として rescue している場合の互換性を保つため、意図的に `ArgumentError` を継承します。

## 代表的な message

次の例は、よくある validation failure で host app が受け取れる message の粒度を示します。

- `render_scope contains unknown keys: max_depths; supported keys are: max_depth, max_leaf_distance`
- `initial_state must be one of: expanded, collapsed; use :expanded or :collapsed`
- `expanded_keys and collapsed_keys cannot include the same keys: "node:1"; remove each key from one side`
- `duplicate node_key detected: "document:42"; configure node_key_resolver or ensure records expose unique IDs before rendering`
- `offset must be a non-negative Integer; pass 0 or a positive row offset`

文言自体は今後改善されてよいですが、少なくとも「何が失敗したか」「どの値や key が関係しているか」「どう直す方向か」は同じ粒度で読める状態を保つのが方針です。

## rescue 例

TreeView の validation / configuration failure をまとめて扱う例:

```ruby
begin
  tree.root_items
rescue TreeView::Error => error
  Rails.logger.warn("TreeView failed: #{error.message}")
end
```

特定の data validation failure を分けて扱う例:

```ruby
begin
  tree.validate_unique_node_keys!
  tree.validate_no_cycles!
rescue TreeView::DuplicateNodeKeyError => error
  # node_key_resolver を見直すか、ID が一意になるようにする。
rescue TreeView::CycleDetectedError => error
  # すべての path が root に到達するよう parent_id を修正する。
end
```

## 互換性方針

新しい code では、TreeView 固有の失敗を扱うとき `TreeView::Error` またはその subclass を rescue してください。既存 code の `ArgumentError` rescue も、TreeView 固有 error が `ArgumentError` subclass であるため引き続き動作します。

具体的な subclass は、このページで document された公開 validation / configuration case に使ってください。このページにない error class は、後から document されるまでは内部扱いと考えてください。
