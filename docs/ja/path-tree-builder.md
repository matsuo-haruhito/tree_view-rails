# PathTreeBuilder

`TreeView::PathTreeBuilder` は、path らしい値を持つ records から、生成フォルダnodeとrecord nodeで構成された描画可能なtreeを作るためのAPIです。

`guides/setup/install.md` のような path を持つ documents / attachments / generated artifacts などを扱いたいが、database上にfolder recordを持っていない場合に使います。

## 基本例

```ruby
builder = TreeView::PathTreeBuilder.new(
  records: documents,
  path_resolver: ->(document) { document.source_relative_path },
  label_resolver: ->(document) { document.title },
  id_resolver: ->(document) { "document:#{document.id}" },
  sort: { folders_first: true }
)

render_state = TreeView::RenderState.new(
  tree: builder.tree,
  root_items: builder.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

builder は以下の2種類の公開node形状を作ります。

| Node | fields | 説明 |
|---|---|---|
| `TreeView::PathTreeBuilder::FolderNode` | `key`, `parent_key`, `label`, `path`, `node_type` | 生成された中間フォルダ。 |
| `TreeView::PathTreeBuilder::RecordNode` | `key`, `parent_key`, `label`, `path`, `record`, `node_type` | host app recordを包むleaf node。 |

`RecordNode#record` には元のobjectが残るため、row partial 側で application-specific な列、link、status、action を描画できます。

## path入力

`path_resolver` は callable である必要があります。戻り値は slash 区切り文字列、または segment 配列を使えます。

```ruby
path_resolver: ->(document) { document.source_relative_path }
path_resolver: ->(document) { [document.category_name, document.title] }
```

文字列pathは `separator` で分割されます。既定値は `/` です。

```ruby
TreeView::PathTreeBuilder.new(
  records: attachments,
  path_resolver: ->(attachment) { attachment.tree_path },
  separator: "::"
)
```

空segmentは無視します。

## keyとlabel

folder key は既定で folder path から `folder:` prefix 付きで作られます。record key は record が `id` に応答する場合 `record:<id>`、それ以外は `record:<object_id>` になります。

record keyを安定させたい場合や、node種別を含めたい場合は `id_resolver` を使います。

```ruby
id_resolver: ->(document) { TreeView.node_key(:document, document.id) }
```

record label は以下の順で解決されます。

1. `label_resolver.call(record)` が指定されている場合
2. record が `name` に応答する場合は `record.name`
3. 最後のpath segment
4. `record.to_s`

## sort

`sort: { folders_first: true }` を渡すと、各階層で生成folderをrecordより前に並べます。

独自順序にしたい場合は `sorter:` を渡します。`TreeView::Tree` の sorter と同じく `->(items, tree) { ... }` 形式です。

## 責務境界

`PathTreeBuilder` は path らしい値から汎用的な folder node / record node を作るだけです。query、権限、label、link、file download、status badge、row-specific action は引き続き host app 側の責務です。
