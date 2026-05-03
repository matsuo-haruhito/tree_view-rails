# Selection

TreeView can render checkbox cells for selecting nodes.

## Visibility

Use `selection[:visibility]` to control which rows render checkboxes.

```ruby
selection: {
  enabled: true,
  visibility: :leaves
}
```

Supported values:

| value | meaning |
|---|---|
| `:all` | Render checkboxes for all rendered nodes. |
| `:roots` | Render checkboxes only for root rows in the current rendered tree. |
| `:leaves` | Render checkboxes only for rows whose children are empty in the current rendered tree. |
| `:none` | Render no checkboxes while keeping empty selection cells. |

The default is `:all`.

When `selection[:enabled]` is `false`, TreeView does not render selection cells at all.
When selection is enabled but a row is outside the configured visibility, TreeView renders an empty selection cell to keep table columns aligned.

## Parsing submitted values

The checkbox value is a JSON string. Host apps can parse submitted values with:

```ruby
selected_nodes = TreeView.parse_selection_params(params[:selected_nodes])
```
