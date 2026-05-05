# Cookbook

Common TreeView implementation patterns for host Rails applications.

The examples stay generic. Business-specific models, authorization, routes, and side effects remain in the host app.

## Patterns

- Minimal static tree: build `TreeView::Tree`, build a static `UiConfig`, create `TreeView::RenderState`, and render `tree_view_rows(render_state)` inside a table body.
- Turbo Stream paths: use `UiConfigBuilder#build_turbo` with host-app path builders. TreeView provides stable DOM targets and paths; the host app owns controller actions and stream responses.
- Initial expansion: use `max_initial_depth` for simple expansion, or explicit `expanded_keys` when the host app needs node-specific control.
- Search results with parent paths: use `path_tree_for(matched_items)` when search hits should be shown with their ancestors. The search query itself remains a host app concern.
- Reverse tree display: use `reverse_tree_for(items)` when the useful viewpoint starts from selected child nodes and walks toward their parents.
- Checkbox selection: enable selection options and parse submitted values with `TreeView.parse_selection_params`.
- Disabled selection rows: use disabled builders when rows should be visible but not selectable. Permission checks still belong in the host app.
- Row class and data hooks: use `row_class_builder` and `row_data_builder` for styling and lightweight integration hooks.
- Row visual hooks: use `badge_builder` for badges and `icon_builder` for a small node-type visual when no badge is configured.
- Large tree guardrails: use `max_initial_depth`, `max_render_depth`, `max_leaf_distance`, or focused trees to avoid rendering everything by default.
- Multi-key sorting: use an array return from `sort_by` when screens need `display_order -> name -> id` style stable ordering.
- Orphan diagnostics: choose an orphan strategy deliberately when parent IDs may point to missing records.

## Multi-key sorter

`TreeView::Tree` applies `sorter:` to both root nodes and children. A sorter only needs to respond to `call(nodes, tree)`, so a lambda is enough for most host apps.

Use an array return from `sort_by` when a screen needs stable ordering with fallback keys.

```ruby
tree = TreeView::Tree.new(
  records: items,
  parent_id_method: :parent_item_id,
  sorter: ->(nodes, _tree) {
    nodes.sort_by do |node|
      [
        node.display_order || Float::INFINITY,
        node.name.to_s,
        node.id
      ]
    end
  }
)
```

This example sorts by:

1. `display_order`, putting `nil` values at the end with `Float::INFINITY`
2. `name`, normalizing `nil` to an empty string with `to_s`
3. `id`, which acts as the final stabilizing key

When the host app has mixed node types, keep the array comparable across all node classes. For example, normalize missing attributes before sorting.

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.respond_to?(:display_order) ? (node.display_order || Float::INFINITY) : Float::INFINITY,
      node.respond_to?(:name) ? node.name.to_s : "",
      node.class.name,
      node.respond_to?(:id) ? node.id.to_i : 0
    ]
  end
}
```

Prefer keeping business-specific ranking rules in the host app. TreeView only calls the sorter and renders the resulting order.

## Icon builder

`icon_builder` is a lightweight visual hook for node type or state markers.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "items/tree_columns",
  ui_config: tree_ui,
  icon_builder: ->(item) {
    item.folder? ? { text: "folder", title: "Folder" } : { text: "file", title: "File" }
  }
)
```

When both `badge_builder` and `icon_builder` are configured, `badge_builder` takes precedence in the current visual slot.

## Notes

Keep this document focused on combinations of existing public APIs. Add detailed examples only when the API has settled enough to avoid frequent churn.
