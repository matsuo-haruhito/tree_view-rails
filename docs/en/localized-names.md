# Localized names

TreeView provides small helpers for resolving model, attribute, and node type names through Rails / ActiveModel / I18n when available.

Use these helpers when a row partial or `NodePresenter` needs a human-readable label that should follow the host app locale.

## Public surface

Host apps should call the top-level `TreeView.model_name_for`, `TreeView.attribute_name_for`, and `TreeView.type_name_for` helpers as the stable localized display-name surface.

`TreeView::LocalizedNames` remains a documented public constant so maintainers and advanced integrations can identify the implementation family, but direct module-method calls are not the recommended host-app dependency boundary. Lower-level helpers such as `humanize_identifier` and `class_for` are implementation helpers, not manifest-backed host-app contracts.

## Use with row partials

- For complete `NodePresenter` and `row_partial` composition examples, see [NodePresenter row partial patterns](node-presenter-row-partials.md).
- For the broader boundary between TreeView hooks and host-app rendering code, see [Host app extension points](host-app-extension-points.md#row_partial).
- For a static visual reference of long localized-style labels, type badges, attribute labels, secondary metadata, and tooltip cues, see [localized-row-labels.html](../mockups/localized-row-labels.html). Final translations and product copy remain host-app responsibilities.

## Model names

```ruby
TreeView.model_name_for(Document)
TreeView.model_name_for(document)
TreeView.model_name_for(Document, count: 2)
```

When the object or class supports ActiveModel naming, TreeView delegates to:

```ruby
Document.model_name.human(count: count)
```

This means normal Rails locale files work:

```yaml
en:
  activerecord:
    models:
      document:
        one: "Document"
        other: "Documents"
```

If ActiveModel naming is unavailable, TreeView falls back to a humanized class name. Pass `default:` when a host app wants a specific label for missing translations or plain Ruby objects:

```ruby
TreeView.model_name_for(Document, default: "File")
TreeView.model_name_for(ExternalItem, default: "External item")
```

## Attribute names

```ruby
TreeView.attribute_name_for(Document, :published_at)
TreeView.attribute_name_for(document, :published_at)
```

When available, TreeView delegates to:

```ruby
Document.human_attribute_name("published_at")
```

Rails locale example:

```yaml
en:
  activerecord:
    attributes:
      document:
        published_at: "Published at"
```

If ActiveModel attribute naming is unavailable, TreeView falls back to a humanized attribute name. Pass `default:` to provide a stable label when the translation may be missing:

```ruby
TreeView.attribute_name_for(Document, :status, default: "Lifecycle status")
```

## Node type names

For heterogeneous tree nodes that expose `node_type`, use:

```ruby
TreeView.type_name_for(node)
```

TreeView looks up:

```yaml
en:
  tree_view:
    node_types:
      folder: "Folder"
      document: "Document"
```

If the translation is missing, TreeView falls back to a humanized `node_type` value. Pass `default:` when the caller already has the best fallback label, including nodes whose `node_type` is blank:

```ruby
TreeView.type_name_for(node, default: "Workspace item")
```

## Toolbar action labels

The bundled toolbar helpers also use I18n-backed default labels.

```yaml
en:
  tree_view:
    toolbar:
      labels:
        expand_all: "Expand all"
        collapse_all: "Collapse all"
        collapse_all_except_current_path: "Collapse all except current path"
```

`tree_view_toolbar`, `tree_view_toolbar_actions`, and `tree_view_toolbar_action_metadata` read these keys for the current locale unless the host app passes an explicit `labels:` override. Missing translations fall back to the built-in English copy.

## NodePresenter example

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.respond_to?(:title) ? item.title : TreeView.model_name_for(item) }
  tooltip { |item| TreeView.type_name_for(item) }
  badge { |item| TreeView.attribute_name_for(item, :status) if item.respond_to?(:status) }
end
```

## Scope

These helpers do not render UI automatically. They only resolve display names. Host app row partials, helpers, or presenters decide where and how the names are shown.
