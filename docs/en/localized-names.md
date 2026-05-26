# Localized names

TreeView provides small helpers for resolving model, attribute, and node type names through Rails / ActiveModel / I18n when available.

Use these helpers when a row partial or `NodePresenter` needs a human-readable label that should follow the host app locale.

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

If ActiveModel naming is unavailable, TreeView falls back to a humanized class name.

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

If ActiveModel attribute naming is unavailable, TreeView falls back to a humanized attribute name.

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

If the translation is missing, TreeView falls back to a humanized `node_type` value.

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
