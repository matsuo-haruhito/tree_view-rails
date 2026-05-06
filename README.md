# tree_view

`tree_view` is a Rails gem for rendering parent-child records as tree-style UIs.

It provides reusable tree objects, render state, helpers, partials, and browser integration hooks while leaving application-specific CRUD, authorization, and business actions to the host Rails app.

日本語の説明、導入手順、API仕様は [日本語ドキュメント](docs/ja/README.md) を参照してください。

## Features

- Build trees from parent-child records.
- Count descendants.
- Sort root and child items.
- Render static tree rows.
- Integrate Turbo Stream expand/collapse actions through path builders.
- Use `GraphAdapter` for heterogeneous or graph-like nodes.
- Use `PathTree` for matched nodes with ancestor paths.
- Use `ReverseTree` for child-to-parent paths.
- Render rows from `TreeView::RenderState` with `tree_view_rows`.
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
- Register JavaScript controllers for state tracking, selection, transfer payloads, and remote loading state.

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

## Installation

```ruby
gem "tree_view", git: "https://github.com/matsuo-haruhito/tree_view-rails.git"
```

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
| Cookbook | [Cookbook](docs/en/cookbook.md) | [Cookbook](docs/ja/cookbook.md) |
| API overview | [API overview](docs/en/api-overview.md) | [API概要](docs/ja/api-overview.md) |
| API reference | [API reference](docs/en/api.md) | [API仕様](docs/ja/api.md) |
| Public API | [Public API](docs/en/public-api.md) | [Public API](docs/ja/public-api.md) |
| Release checklist | [Release checklist](docs/en/release.md) | [Release checklist](docs/ja/release.md) |

Additional docs:

- [Documentation index](docs/README.md)
- [Documentation i18n audit](docs/i18n-audit.md)
- [CHANGELOG.md](CHANGELOG.md)

## Development

```bash
bundle install
bundle exec standardrb
bundle exec rspec
bundle exec rake build
npm install
npm test
```

Rails compatibility Gemfiles are under `gemfiles/`. Set `BUNDLE_GEMFILE` when checking a specific Rails version.

```bash
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle install
BUNDLE_GEMFILE=gemfiles/rails_7_0.gemfile bundle exec rake
```

GitHub Actions runs lightweight Ruby lint on pull requests. The full Ruby spec matrix, Rails version matrix, JavaScript tests, and gem package verification run on pushes to `main`.

## Release

The initial release target is `0.1.0`.

Before release, check:

- `bundle exec standardrb`
- `bundle exec rspec`
- `bundle exec rake build`
- Rails version matrix CI
- `npm test`
- README, docs, and CHANGELOG consistency
- gemspec metadata

See also:

- [Release checklist](docs/en/release.md)
- [日本語: Release checklist](docs/ja/release.md)

## License

MIT
