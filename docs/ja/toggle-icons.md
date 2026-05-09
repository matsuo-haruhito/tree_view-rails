# toggle icon のカスタマイズ

`toggle_icons:` または `toggle_icon_builder:` を使うと、TreeView の開閉コントロール自体は TreeView に任せたまま、見た目の中身だけを差し替えられます。

TreeView は引き続き link 生成、Turbo Stream の data 属性、ARIA 状態、depth / branch layout、lazy-loading semantics を管理します。custom content は toggle control の内側に描画する内容だけを返します。

## toggle_icons で状態・depth・node type ごとに指定する

複数の icon を declarative に指定したい場合は `toggle_icons:` を使います。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  toggle_icons: {
    by_state: {
      expanded: "▾",
      collapsed: "▸",
      leaf: "•"
    },
    by_depth: {
      0 => { expanded: "▼", collapsed: "▶", leaf: "●" },
      1 => { expanded: "▾", collapsed: "▸", leaf: "•" }
    },
    by_type: {
      folder: { expanded: "📂", collapsed: "📁" },
      file: { leaf: "📄" }
    }
  }
)
```

選択順は `by_type` → `by_depth` → `by_state` です。より具体的な指定が見つからない場合に、次の fallback を使います。

`by_type` は item の `node_type`, `type`, `kind` の順に参照します。Hash-like な item の場合は `:node_type` / `"node_type"` も参照します。

`by_depth` は root を `0` とする既存の `depth` を使います。既存 API や context と用語を揃えるため、`level` ではなく `depth` を使います。

`toggle_icon_builder:` と `toggle_icons:` を両方指定した場合は、明示的な `toggle_icon_builder:` が優先されます。

## builder の引数

より細かく制御したい場合は `toggle_icon_builder:` を使います。

```ruby
toggle_icon_builder: ->(item, state, context) { ... }
```

| 引数 | 説明 |
|---|---|
| `item` | row item。 |
| `state` | `:expanded`, `:collapsed`, `:leaf`, `:loading` のいずれか。 |
| `context` | `:state`, `:depth`, `:tree`, `:children`, `:hidden_count`, `:mode`, `:leaf_distance` を含む Hash。 |

`toggle_icons:` の各 icon value と builder は、plain text または Hash-like な値を返せます。Hash では以下を指定できます。

| key | 説明 |
|---|---|
| `:text`, `:label`, `:icon`, `:html` | 描画する内容。 |
| `:class` | wrapper に追加する CSS class。 |
| `:title` | 任意の title 属性。 |
| `:data` | 任意の data 属性。 |
| `:aria_hidden` | icon wrapper に `aria-hidden` を付けるか。既定値は `true`。 |

## simple な文字記号

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  toggle_icon_builder: ->(_item, state, _context) {
    case state
    when :expanded then "▾"
    when :collapsed then "▸"
    else "•"
    end
  }
)
```

## CSS icon class

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  toggle_icon_builder: ->(_item, state, _context) {
    icon_class = case state
    when :expanded then "fa fa-chevron-down"
    when :collapsed then "fa fa-chevron-right"
    when :loading then "fa fa-spinner fa-spin"
    else "fa fa-file"
    end

    { text: "", class: ["document-toggle-icon", icon_class], title: state.to_s }
  }
)
```

## inline SVG や helper-rendered content

builder の出力は TreeView 既存の toggle action の内側に描画されます。custom content は装飾用途にとどめ、button や link を入れ子にしないでください。

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  toggle_icon_builder: ->(_item, state, _context) {
    icon_name = (state == :expanded) ? "chevron-down" : "chevron-right"
    { html: helpers.inline_svg_tag("icons/#{icon_name}.svg"), class: "document-toggle-svg" }
  }
)
```
