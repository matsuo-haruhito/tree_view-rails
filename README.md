# tree_view

`tree_view` is a Rails gem for rendering parent-child records as tree-style UIs.

It provides reusable tree objects, render state, helpers, partials, and browser integration hooks while leaving application-specific CRUD, authorization, and business actions to the host Rails app.

日本語の説明、導入手順、API仕様は [日本語ドキュメント](docs/ja/README.md) を参照してください。

## Is this gem for you?

Use TreeView when you want Rails-friendly primitives for rendering tree or tree-table interfaces, not a complete file-manager application. It is a good fit when the host app owns the records, queries, routes, authorization, and business behavior, while TreeView handles reusable rendering and interaction hooks.

TreeView is useful for:

- Rails-friendly tree and table rendering
- accessibility-oriented row semantics for table-first tree UIs
- Turbo and Stimulus integration points
- expandable rows
- checkbox selection hooks
- lazy-loading hooks
- drag/drop hooks
- host-app-controlled queries and business behavior

TreeView does not provide:

- a complete file-manager application
- CRUD screens
- authorization policies
- product-specific context menus or bulk actions
- server-side pagination algorithms
- a full virtual scrolling engine

For very large trees, combine TreeView's render controls with host-app loading and paging strategies. Start with [Render Scale](docs/en/render-scale.md), then add [Lazy Loading](docs/en/lazy-loading.md), [Children Pagination](docs/en/children-pagination.md), or custom virtual scrolling owned by the host app when your UI needs it.

## FAQ

For short answers about responsibility boundaries and common misunderstandings, see:

- [English FAQ](docs/en/faq.md)
- [日本語FAQ](docs/ja/faq.md)

If you already know the symptom and want a faster reverse-lookup entry point, see:

- [English Troubleshooting](docs/en/troubleshooting.md)
- [日本語Troubleshooting](docs/ja/troubleshooting.md)

If you want static visual references for baseline DOM structure and interaction states before wiring a host app, see [TreeView mockups](docs/mockups/README.md), start with [review-gallery.html](docs/mockups/review-gallery.html), and jump to [resource-table-bridge.html](docs/mockups/resource-table-bridge.html) or [toolbar-actions.html](docs/mockups/toolbar-actions.html) for focused reviews.

## Features

- Build trees from parent-child records.
- Build generated folder trees from path-like record values with `PathTreeBuilder`.
- Count descendants.
- Sort root and child items.
- Render static tree rows.
- Protect table-first accessibility semantics with documented ARIA placement for level, expansion, selection, and current-row state.
- Suppress TreeView partial render noise by default with configurable render log silencing.
- Integrate Turbo Stream expand/collapse actions through path builders.
- Expand/collapse small to medium trees in the browser with client-side toggle mode.
- Use `GraphAdapter` for heterogeneous or graph-like nodes.
- Use `PathTree` for matched nodes with ancestor paths.
- Use `ReverseTree` for child-to-parent paths.
- Render rows from `TreeView::RenderState` with `tree_view_rows`.
- Build a resource-table-oriented render state with `TreeView::ResourceTableRenderState` when another table layer owns columns and table state.
- Flatten currently visible rows with `TreeView::VisibleRows`.
- Render currently visible rows by offset and limit with `TreeView::RenderWindow` and windowed rendering. This limits HTML output only; it does not reduce host-app queries or fetched records.
- Customize host-app row content through `row_partial`.
- Control initial expansion with `initial_state`, `expanded_keys`, `collapsed_keys`, and `max_initial_depth`.
- Limit render scope with `max_render_depth` and `max_leaf_distance`.
- Limit toggle scope with `max_toggle_depth_from_root` and `max_toggle_leaf_distance`.
- Customize row attributes with `row_class_builder` and `row_data_builder`.
- Add lazy loading hooks with `load_children_path_builder` and `RenderState#lazy_loading`.
- Add checkbox selection with JSON payloads, disabled states, selected keys, cascade, indeterminate state, and max-count limits.
- Persist expansion state through `TreeView::PersistedState`, `TreeView::StateStore`, and `rails g tree_view:state:install`.
- Register JavaScript controllers for state tracking, client-side toggling, selection, transfer payloads, and remote loading state.

## Out of scope

This gem focuses on tree rendering primitives. Host applications are responsible for:

- CRUD
- controllers, models, and forms
- authentication and authorization
- application-specific labels, routes, and actions
- Turbo Frame modals
- context menus
- business actions after checkbox selection, such as delete, move, or attach
- server-side children pagination query and cursor strategy
- data-fetching reductions beyond TreeView's lazy-loading hooks
- JavaScript control for infinite scroll or full virtual scroll
- demo data and seeds
- table column inference and saved table preferences unless a separate table layer provides them

## Installation

Minimum supported environment:

- Ruby 3.2 or later
- Rails 7.0 or later

When you are installing a published release, add the gem normally:

```ruby
gem "tree_view"
```

If you need unreleased `main` changes, use the GitHub source explicitly:

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

Then run `bundle install` as usual.

```bash
bundle install
```

Import the CSS:

```scss
@import "tree_view";
```

Add the importmap pin when needed:

```ruby
pin "tree_view", to: "tree_view/index.js"
```

See [Installation](docs/en/installation.md) for details.

日本語の導入手順は [docs/ja/installation.md](docs/ja/installation.md) を参照してください。

## Quick Start

Controller:

```ruby
tree = TreeView::Tree.new(
  records: @projects,
  parent_id_method: :parent_project_id
)

@tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "project"
).build_static

@render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "projects/tree_columns",
  ui_config: @tree_ui
)
```

View:

```erb
<table class="tree-view-table">
  <tbody>
    <%= tree_view_rows(@render_state) %>
  </tbody>
</table>
```

Row partial:

```erb
<!-- app/views/projects/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
```

You can also render the `tree_view/tree_row` partial directly when needed.

TreeView silences its own helper-rendered partial logs at `:warn` by default to avoid noisy `Rendered tree_view/...` entries in the host app log. Change or disable this with `TreeView.configure { |config| config.render_log_level = :info }` or `nil`.

See [Usage](docs/en/usage.md) for details.

日本語の使い方は [docs/ja/usage.md](docs/ja/usage.md) を参照してください。

## Documentation

Documentation is organized by language.

If you know the use case but are not sure which API or option to use, start with the [Decision guide](docs/en/decision-guide.md).

使いたい場面からAPIやoptionを選びたい場合は [API判断ガイド](docs/ja/decision-guide.md) を参照してください。

| Language | Entry point |
|---|---|
| English | [docs/en/README.md](docs/en/README.md) |
| 日本語 | [docs/ja/README.md](docs/ja/README.md) |

Key documents:

| Topic | English | 日本語 |
|---|---|---|
| Installation | [Installation](docs/en/installation.md) | [導入手順](docs/ja/installation.md) |
| Minimal usage | [Minimal usage](docs/en/minimal-usage.md) | [最小利用例](docs/ja/minimal-usage.md) |
| Usage | [Usage](docs/en/usage.md) | [使い方](docs/ja/usage.md) |
| Decision guide | [Decision guide](docs/en/decision-guide.md) | [API判断ガイド](docs/ja/decision-guide.md) |
| FAQ | [FAQ](docs/en/faq.md) | [FAQ](docs/ja/faq.md) |
| Troubleshooting | [Troubleshooting](docs/en/troubleshooting.md) | [Troubleshooting](docs/ja/troubleshooting.md) |
| Visual reference mockups | [review-gallery.html](docs/mockups/review-gallery.html), [resource-table-bridge.html](docs/mockups/resource-table-bridge.html), and [toolbar-actions.html](docs/mockups/toolbar-actions.html) | [review-gallery.html](docs/mockups/review-gallery.html), [resource-table-bridge.html](docs/mockups/resource-table-bridge.html), and [toolbar-actions.html](docs/mockups/toolbar-actions.html) |
| JavaScript event contract | [JavaScript event contract](docs/en/js-events.md) | [JavaScript イベント契約](docs/ja/js-events.md) |
| Accessibility semantics | [Accessibility Semantics](docs/en/accessibility-semantics.md) | [Accessibility Semantics](docs/ja/accessibility-semantics.md) |
| Cookbook | [Cookbook](docs/en/cookbook.md) | [Cookbook](docs/ja/cookbook.md) |
| Forms and editing rows | [Forms and editing rows](docs/en/form-editing.md) | [Form と編集行](docs/ja/form-editing.md) |
| Resource table bridge | [Resource table bridge](docs/en/resource-table-bridge.md) | [Resource table bridge](docs/ja/resource-table-bridge.md) |
| API overview | [API overview](docs/en/api-overview.md) | [API概要](docs/ja/api-overview.md) |
| API reference | [API reference](docs/en/api.md) | [API仕様](docs/ja/api.md) |
| PathTreeBuilder | [PathTreeBuilder](docs/en/path-tree-builder.md) | [PathTreeBuilder](docs/ja/path-tree-builder.md) |
| Public API | [Public API](docs/en/public-api.md) | [Public API](docs/ja/public-api.md) |
| Release checklist | [Release checklist](docs/en/release.md) | [Release checklist](docs/ja/release.md) |

Additional docs:

- [Documentation index](docs/README.md)
- [Visual reference mockups](docs/mockups/README.md)
- [Documentation maintenance checklist](docs/i18n-audit.md)
- [Product Profile](Product%20Profile.md)
- [Maintainer guide](AGENTS.md)
- [CHANGELOG.md](CHANGELOG.md)

## Development

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm run test:js
```

`npm run test:js` runs the documented JavaScript pull-request checks together: entrypoint smoke (`npm run test:entrypoints`), Vitest (`npm test`), and Playwright browser smoke (`npm run test:browser`). See the [English development guide](docs/en/development.md) and [日本語の開発・保守方針](docs/ja/development.md) for details.

A committed `package-lock.json` is present, but it is not yet in sync with `package.json`, so CI and local setup keep using `npm install` until that lockfile is refreshed in a registry-enabled environment.