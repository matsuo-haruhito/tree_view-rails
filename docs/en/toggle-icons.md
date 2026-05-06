# Toggle icon customization

Use `toggle_icon_builder:` when you want to replace the visual content of TreeView's expand/collapse control without taking over the control itself.

TreeView still owns link generation, Turbo Stream data attributes, ARIA state, depth/branch layout, and lazy-loading semantics. The builder only supplies the content rendered inside the toggle control.

## Builder arguments

```ruby
toggle_icon_builder: ->(item, state, context) { ... }
```

| Argument | Description |
|---|---|
| `item` | The row item. |
| `state` | One of `:expanded`, `:collapsed`, `:leaf`, or `:loading`. |
| `context` | Hash containing `:state`, `:depth`, `:tree`, `:children`, `:hidden_count`, `:mode`, and `:leaf_distance`. |

The builder may return plain text or a Hash-like value. Hash values support:

| Key | Description |
|---|---|
| `:text`, `:label`, `:icon`, `:html` | Content to render. |
| `:class` | Extra CSS class or classes for the wrapper. |
| `:title` | Optional title attribute. |
| `:data` | Optional data attributes. |
| `:aria_hidden` | Whether to mark the icon wrapper as `aria-hidden`; defaults to `true`. |

## Simple text symbols

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

## CSS icon classes

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

## Inline SVG or helper-rendered content

Because the builder output is rendered inside TreeView's existing toggle action, keep custom content decorative and avoid placing buttons or links inside it.

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
