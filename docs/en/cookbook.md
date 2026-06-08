# Cookbook

This page collects common ways to combine existing TreeView APIs in host apps.

## Overview

The cookbook is not a detailed API reference. It shows practical patterns that host apps commonly need.

For editing-oriented tree/table screens, see [Forms and editing rows](form-editing.md). That page covers bulk edit forms, inline editing layouts, Form Objects, per-row edit actions, validation errors, and the responsibility boundary between TreeView and the host app.

For API details, see:

- [API overview](api-overview.md)
- [Usage](usage.md)
- [Selection](selection.md)
- [Lazy Loading](lazy-loading.md)
- [Windowed Rendering](windowed-rendering.md)
- [Breadcrumb](breadcrumb.md)
- [Localized names](localized-names.md)
- [Toggle icon customization](toggle-icons.md)

## Add a breadcrumb for the current item

Use [Breadcrumb](breadcrumb.md) when the page already has a records-mode tree and a current item, and the UI needs a compact path from the root to that item. TreeView looks up the ancestor path with `tree.path_for(item)` and renders the standard breadcrumb markup through `tree_view_breadcrumb`.

```erb
<%= tree_view_breadcrumb(
  @tree,
  @document,
  label_builder: ->(item) { item.name },
  path_builder: ->(item) { document_path(item) }
) %>
```

The current item is rendered as a current label, not a link. Keep route helpers, authorization, the current item choice, and layout placement in the host app. Use `path_builder:` for normal linked ancestors and omit it when the breadcrumb should render plain labels.

When the host app needs custom wrappers, conditional copy, per-level authorization messaging, or markup that the helper options do not cover, build from the path directly instead of stretching the helper.

```erb
<% @tree.path_for(@document).each do |item| %>
  <% if can?(:read, item) %>
    <%= link_to item.name, document_path(item) %>
  <% else %>
    <span><%= item.name %></span>
  <% end %>
<% end %>
```

TreeView owns path lookup in records mode and the bundled helper option surface. The host app owns routes, authorization, where the breadcrumb appears, and any Turbo or analytics behavior attached to custom attributes.

## Row customization quick guide

Use the smallest TreeView extension point that matches the UI you are adding.

| Need | Recommended hook | Host app owns |
|---|---|---|
| Business data columns | `row_partial` | Field choice, formatting, links, permissions |
| Edit, Show, Delete, Archive, or custom action buttons | `row_actions_partial` | Routes, controller actions, authorization, confirmation text |
| Inputs, selects, or inline editable labels | `row_partial` or `row_actions_partial` | Form object, validation, dirty state, persistence |
| Level labels | `depth_label_builder` | Label wording and localization |
| Badges, status pills, or marker-like labels | `badge_builder` | Status names, classes, and product semantics |
| Locale-aware row labels, type badges, or tooltips | `TreeView::NodePresenter` plus LocalizedNames helpers | Locale files, final copy, and business wording |
| Legacy/direct toggle-cell marker text | `marker_builder` when rendering toggle cells directly | Marker naming and classes |
| Expand/collapse control icons | `toggle_icons` or `toggle_icon_builder` | Icon set, tooltip/title copy, and accessibility copy |
| Folder/file icons or type labels | `badge_builder`, `icon_builder`, or a cell in `row_partial` | Icon set, labels, and accessibility copy |
| Current row highlighting or archived/disabled styling | `row_class_builder`, `row_data_builder`, and row-status docs | State rules and behavior |

TreeView owns reusable tree structure, row rendering slots, toggle/selection hooks, and browser integration markers. CRUD, persistence, validation, authorization, product-specific actions, and host-app business workflows stay in the host app.

## Add data display columns with row_partial

Put the main row content in the configured `row_partial`. This is the right place for business columns such as name, owner, updated time, size, or type.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td><%= item.name %></td>
<td><%= item.owner_name %></td>
<td><%= l(item.updated_at, format: :short) %></td>
```

Keep route decisions, authorization checks, and product-specific formatting in the host app partial.

## Add row action links with row_actions_partial

Use `row_actions_partial` for per-row action links and buttons such as Edit, Show, Delete, Archive, Duplicate, or application-specific actions.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  row_actions_partial: "documents/tree_actions",
  ui_config: tree_ui
)
```

```erb
<!-- app/views/documents/_tree_actions.html.erb -->
<td class="document-actions">
  <%= link_to "Show", document_path(item) %>
  <%= link_to "Edit", edit_document_path(item) %>
  <%= button_to "Delete", document_path(item), method: :delete, data: { turbo_confirm: "Delete this document?" } %>
</td>
```

The partial receives `item`, `tree`, and `render_state`. TreeView only supplies the slot; the host app owns routes, authorization, confirmation text, controller behavior, and persistence.

## Put text input and select controls inside a row

Native controls can live in row content or row actions. TreeView treats inputs, selects, textareas, buttons, links, and `contenteditable` labels as host-app controls and avoids starting tree keyboard navigation or transfer drag behavior from them.

```erb
<!-- app/views/documents/_tree_columns.html.erb -->
<td>
  <%= text_field_tag "documents[#{item.id}][name]", item.name %>
</td>
<td>
  <%= select_tag "documents[#{item.id}][status]",
        options_for_select(Document.statuses.keys, item.status) %>
</td>
```

For custom widgets that are not native controls, add `data-tree-view-interactive="true"` to the widget or an ancestor.

Validation, dirty-state handling, form submission, conflict handling, and persistence remain host-app responsibilities.

## Customize depth labels, badges, markers, and icons

Use `depth_label_builder` when the toggle cell should show a level label.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  depth_label_builder: ->(_document, depth) { "Level #{depth + 1}" }
)
```

Use `badge_builder` for compact labels in the toggle cell, such as file type, workflow state, or attention markers.

```ruby
badge_builder = ->(document) {
  if document.archived?
    { text: "Archived", class: "is-muted", title: "This document is archived" }
  elsif document.requires_review?
    { text: "Review", class: "is-warning" }
  end
}
```

`badge_builder` may return text or a hash-like object with `text` or `label`, optional `class`, `title`, and `data`. For legacy direct rendering of toggle cells, `marker_builder` follows the same marker-style idea; prefer `badge_builder` with `RenderState` in new code.

Use `toggle_icons:` or `toggle_icon_builder:` when you want to replace the expand/collapse control's own visual content while TreeView keeps ownership of the toggle link, ARIA state, lazy-loading semantics, and branch layout. See [Toggle icon customization](toggle-icons.md) for state, depth, and node-type examples. Keep the icon set, title/tooltip copy, and accessibility wording in the host app.

Use a badge or icon builder for compact folder/file type labels, or put richer icon markup in `row_partial` so the host app controls the HTML and accessibility copy.

```ruby
icon_builder = ->(document) {
  document.folder? ? { text: "Folder", class: "is-folder" } : { text: "File", class: "is-file" }
}
```

## Localize row labels, badges, and tooltips

Use [Localized names](localized-names.md) when row copy should follow the host app locale files instead of hard-coded strings. `TreeView::NodePresenter` can compose those helpers with row-specific values while leaving the final copy, translations, and business wording in the host app.

```ruby
presenter = TreeView::NodePresenter.define do
  label { |item| item.respond_to?(:title) ? item.title : TreeView.model_name_for(item) }
  tooltip { |item| TreeView.type_name_for(item) }
  badge { |item| TreeView.attribute_name_for(item, :status) if item.respond_to?(:status) }
end

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  presenter: presenter
)
```

Use `TreeView.model_name_for` for model labels, `TreeView.attribute_name_for` for attribute labels, and `TreeView.type_name_for` for heterogeneous node type labels. TreeView only resolves display names; the host app decides which locale keys exist and where the labels appear in row partials, badges, titles, or tooltips.

## Highlight current, archived, disabled, or status rows

Use `row_class_builder` when visual state belongs on the whole `<tr>` and `badge_builder` when compact status text should appear near the toggle.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    [
      "document-row",
      ("is-current" if document.id == params[:id].to_i),
      ("is-archived" if document.archived?),
      ("is-disabled" unless document.editable?)
    ]
  },
  badge_builder: ->(document) {
    next { text: "Archived", class: "is-muted" } if document.archived?
    next { text: "Locked", class: "is-locked" } unless document.editable?
  }
)
```

Use `row_data_builder` when host-app JavaScript needs stable metadata. If a row should be readonly or disabled for TreeView-level interaction, also see [Row status](row-status.md). Authorization decisions and business rules still belong in the host app.

## Stable name sorting

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by { |node| [node.name.to_s, node.id] }
}

tree = TreeView::Tree.new(
  records: documents,
  parent_id_method: :parent_document_id,
  sorter: sorter
)
```

Add a stable key such as `id` at the end so nodes with the same name keep a predictable order.

## Prioritize display_order

```ruby
sorter = ->(nodes, _tree) {
  nodes.sort_by do |node|
    [
      node.display_order || Float::INFINITY,
      node.name.to_s,
      node.id
    ]
  end
}
```

Use `Float::INFINITY` to place missing `display_order` values last.

## Expand to search results initially

```ruby
matched_documents = Document.search(params[:q]).to_a
expanded_keys = tree.expanded_keys_for(matched_documents)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    expanded_keys: expanded_keys
  }
)
```

Use `path_tree_for` when search results should be shown with their ancestors.

```ruby
path_tree = tree.path_tree_for(matched_documents)
```

## Select only leaves

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  selection: {
    enabled: true,
    visibility: :leaves,
    checkbox_name: "selected_documents[]"
  }
)
```

## Disable archived nodes

```ruby
selection: {
  enabled: true,
  disabled_builder: ->(document) { document.archived? },
  disabled_reason_builder: ->(document) {
    document.archived? ? "Archived documents cannot be selected" : nil
  }
}
```

## Reduce initial HTML for large trees

Start by limiting initial rendering with `max_initial_depth` or `max_render_depth`.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  max_initial_depth: 1
)
```

Use windowed rendering when many visible rows remain.

```erb
<%= tree_view_rows(@render_state, window: { offset: 0, limit: 50 }) %>
```

Use lazy loading when children should be loaded only as needed.

## Combine lazy loading with children pagination

Use this pattern when a branch has many direct children and rendering all of them after the first expand would still be too large. Keep lazy loading responsible for the initial child endpoint and remote-state placeholders, then let the host app return one page of children plus a host-app-owned "Load more" row.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document",
  key_resolver: ->(item) { TreeView.node_key("document", item.id) }
).build(
  load_children_path_builder: ->(item, depth, scope) {
    children_document_path(item, depth:, scope:, limit: 50, format: :turbo_stream)
  }
)
```

```erb
<%= turbo_stream.replace tree_children_container_dom_id(@parent) do %>
  <tbody id="<%= tree_children_container_dom_id(@parent) %>">
    <%= tree_view_rows(@render_state) %>
    <% if @next_cursor %>
      <tr id="<%= dom_id(@parent, :children_more) %>">
        <td colspan="6">
          <%= link_to "Load more",
            children_document_path(@parent, cursor: @next_cursor, limit: @limit, format: :turbo_stream),
            data: { turbo_stream: true } %>
        </td>
      </tr>
    <% end %>
  </tbody>
<% end %>

<%= turbo_stream.replace tree_remote_state_placeholder_dom_id(@parent) do %>
  <span <%= tag.attributes(tree_remote_state_placeholder_attributes(@parent, state: "loaded")) %>>loaded</span>
<% end %>
```

TreeView provides `load_children_path_builder`, children container IDs, remote-state placeholder attributes, row rendering, and lazy-loading hooks. The host app owns the cursor or offset strategy, limit clamping, query ordering, authorization, `children_more` placement, retry copy, and Turbo Stream partial shape.

For the full boundary and cursor details, read [Lazy Loading](lazy-loading.md), [Children Pagination](children-pagination.md), and [Render Scale](render-scale.md). Do not use this recipe as an infinite-scroll or virtual-scroll contract; those policies stay in the host app unless a separate feature changes them.

## Avoid an unopenable static collapsed tree

`build_static` does not configure expand/collapse URLs. If static rendering is combined with `initial_expansion: { default: :collapsed }`, collapsed descendants are not rendered into the initial HTML and the user cannot open them from the browser.

```ruby
# Static mode has no show/hide URLs. When default expansion is collapsed,
# descendant rows are not initially rendered and cannot be opened by user action.
# Use Turbo mode with show/hide path builders when users should expand branches.
tree_ui = TreeView::UiConfigBuilder.new(
  context: view_context,
  node_prefix: "document_tree",
  key_resolver: ->(item) { node_key(item) }
).build_static

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: { default: :collapsed }
)
```

Use this only for a final, non-interactive snapshot. If users should open branches, use Turbo mode.

## Minimal Turbo expand/collapse tree

Turbo mode connects TreeView toggle links to host-app routes. Path builders only generate URLs; the host app still owns routing, authorization, queries, and Turbo Stream responses.

```ruby
tree_ui = TreeView::UiConfigBuilder.new(
  context: self,
  node_prefix: "document_tree",
  key_resolver: ->(item) { node_key(item) }
).build(
  show_descendants_path_builder: ->(item, depth, scope) {
    show_document_tree_path(item, depth:, scope:, format: :turbo_stream)
  },
  hide_descendants_path_builder: ->(item, depth, scope) {
    hide_document_tree_path(item, depth:, scope:, format: :turbo_stream)
  },
  toggle_all_path_builder: ->(state) {
    documents_path(tree_state: state, format: :turbo_stream)
  }
)
```

```ruby
def show_tree_branch
  authorize! :read, @document
  rebuild_tree_state(expanded_keys: expanded_keys_from_params + [node_key(@document)])

  respond_to do |format|
    format.turbo_stream do
      render turbo_stream: turbo_stream.replace(
        "tree_panel",
        partial: "documents/tree",
        locals: { render_state: @render_state }
      )
    end
  end
end
```

```erb
<div id="tree_panel">
  <%= tree_view_rows(render_state) %>
</div>
```

For a first implementation, replacing the whole tree panel is usually easiest and keeps state reconstruction explicit. For very large trees, replace only the affected descendant rows after the route and state shape are stable.

## Expand only the current branch initially

Navigation sidebars often start with every branch collapsed except the branch containing the current project or document. Use `current_item:` or `current_key:` with `auto_expand_ancestors: true` when TreeView should open only the current path and keep sibling branches collapsed.

```ruby
current_key = @document ? node_key(@document) : node_key(@project)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  initial_expansion: {
    default: :collapsed,
    current_key: current_key,
    auto_expand_ancestors: true
  },
  row_class_builder: ->(document) {
    ["document-row", ("is-current" if node_key(document) == current_key)]
  }
)
```

If the host app already has the current record object, pass `current_item:` instead of `current_key:`.

```ruby
initial_expansion: {
  default: :collapsed,
  current_item: @document,
  auto_expand_ancestors: true
}
```

`auto_expand_ancestors:` resolves the current node under `root_items` and merges only ancestor keys into `expanded_keys`. Use `expanded_keys:` alongside it when another sibling branch or additional path should also start open.

On index pages with no current node, omit `current_item:` / `current_key:` and keep `default: :collapsed` if only top-level rows should appear. If users need to open other branches, combine this pattern with Turbo mode rather than `build_static`.

## GraphAdapter and ActiveRecord performance

When `GraphAdapter` is backed by ActiveRecord data, avoid returning lazy relations from `children_resolver`. Rendering may ask for children more than once, and row partials often access related data. Precompute child arrays and keep expensive derived values out of the row partial.

```ruby
projects = Project.visible_to(current_user).to_a

children_by_project_id = projects.index_with do |project|
  project.documents
    .accessible_to(current_user)
    .includes(:latest_version)
    .to_a
    .sort_by(&:title)
end.transform_keys(&:id)

adapter = TreeView::GraphAdapter.new(
  roots: projects,
  children_resolver: ->(node) {
    node.is_a?(Project) ? children_by_project_id.fetch(node.id, []) : []
  }
)
```

Practical checklist:

- Materialize parent records with `to_a` before building the tree.
- Return arrays, not ActiveRecord relations, from `children_resolver`.
- Cache child collections by parent id in the host app.
- Do not run DB queries or expensive permission/version checks inside row partials.
- Cache derived values such as displayable versions in a helper or presenter.

## Development logging tips for recursive trees

Large recursive trees can produce many normal Rails view-render log lines such as `_tree_row.html.erb`, `_tree_toggle_cell.html.erb`, and `_tree_toggle_content.html.erb`. The render log itself is not a bug. During performance work, focus on whether row rendering is triggering repeated database work.

Look for these signals in the Rails log:

- High `ActiveRecord:` time compared with `Views:` time.
- Repeated `Document Load` or `DocumentVersion Load` lines while rows render.
- Many same-shaped queries that are not marked `CACHE`.
- Derived helper calls from the row partial that repeatedly touch associations.

Host-app mitigations include precomputing children as arrays, caching derived values used by the row partial, and temporarily reducing noisy development view logs while investigating database queries. Recursive partial logs are expected; repeated uncached queries are the problem.

## Add row state classes

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  row_class_builder: ->(document) {
    ["document-row", ("is-archived" if document.archived?)]
  }
)
```

See [Row status](row-status.md) when the whole row should express disabled or readonly state.

## Avoid node_key collisions

For heterogeneous nodes in one tree, include the class name or another namespace.

```ruby
node_key_resolver = ->(node) {
  TreeView.node_key(node.class.name, node.id)
}
```

See [Node keys](node-keys.md) for details.
