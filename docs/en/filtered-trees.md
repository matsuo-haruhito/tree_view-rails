# Filtered Trees

This page explains filtered trees for rendering search or filter results as TreeView structures.

## Overview

A filtered tree selects matching nodes from a base tree and includes the surrounding nodes needed for display.

Common use cases:

- render only matched nodes
- render matched nodes and ancestors
- render matched nodes and descendants
- render matched nodes, ancestors, and descendants together

## Basic example

```ruby
matched_documents = documents.select { |document| document.name.include?(params[:q].to_s) }
filtered_tree = tree.filtered_tree_for(matched_documents, mode: :with_ancestors)

render_state = TreeView::RenderState.new(
  tree: filtered_tree,
  root_items: filtered_tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

## Modes

| mode | meaning |
|---|---|
| `:matched_only` | Include only matched nodes. |
| `:with_ancestors` | Include matched nodes and ancestors. |
| `:with_descendants` | Include matched nodes and descendants. |
| `:with_ancestors_and_descendants` | Include matched nodes, ancestors, and descendants. |

## Difference from PathTree

`path_tree_for` fills paths from roots to specified items.

Filtered trees build a node set around matches according to a filter mode.

| Goal | API |
|---|---|
| Show paths to search results | `path_tree_for(items)` |
| Switch between matches, ancestors, and descendants by mode | `filtered_tree_for(items, mode:)` |

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| filtered tree construction | yes | provides matched items |
| filter modes | yes | chooses mode |
| search query | no | yes |
| authorization | no | yes |
| result ranking | no | yes |
| text highlighting | no | yes |
