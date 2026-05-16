# Current node expansion

`TreeView::RenderState` can expand the ancestors of the current node during initial rendering.

Use this when a screen opens a detail page or selected record and the tree should reveal the parent path to that record while the rest of the tree starts collapsed.

## Basic usage

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

You can also pass the current record directly.

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

## Behavior

When `auto_expand_ancestors: true` is set, TreeView adds the current node's ancestors to `expanded_keys`.

The current node itself is not added automatically. Expanding ancestors is enough to make the current row reachable while preserving leaf expansion semantics.

Existing `expanded_keys` are preserved and de-duplicated with the generated ancestor keys.

If `current_key` is used, it must match `tree.node_key_for(item)` for a node reachable under `root_items`. If no matching node can be found and no explicit `expanded_keys` were provided, TreeView raises `TreeView::ConfigurationError`.

## Grouped options

`current_item`, `current_key`, and `auto_expand_ancestors` can be passed as top-level `RenderState` options or inside `initial_expansion`.

```ruby
initial_expansion: {
  default: :collapsed,
  current_key: current_key,
  auto_expand_ancestors: true
}
```

Top-level options follow the same precedence rule as other `RenderState` options: explicit top-level values take priority over grouped values.

## Responsibility boundary

TreeView only calculates ancestor expansion keys. Host apps remain responsible for deciding which node is current and for styling or marking the current row through existing row hooks such as `row_class_builder`, `row_data_builder`, or ARIA attributes controlled by the host app.
