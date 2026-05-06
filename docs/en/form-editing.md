# Forms and editing rows

TreeView rows can contain Rails form controls and action links, but TreeView does not own the editing workflow.

Use this page when you want editing-oriented tree/table screens such as bulk edit pages, inline-edit style rows, or per-row edit actions.

## Responsibility boundary

TreeView supports inline-editing layouts. It does not provide an inline-editing workflow.

That means TreeView can render the row structure, indentation, expand/collapse controls, selection controls, and host-app partials. The host app decides when rows enter edit mode, how records are validated, how changes are saved, how authorization works, and how unsaved changes are protected.

| Concern | Owner | Notes |
|---|---|---|
| Row rendering and tree indentation | TreeView | Use `tree_view_rows` and `row_partial`. |
| Form controls inside row cells | Host app | Place controls in the host-owned `row_partial`. |
| Keyboard, selection, and drag conflict avoidance | Shared | TreeView provides structure and hooks; interactive controls should stop row-level behavior when needed. |
| Edit mode state | Host app | Use params, Turbo, Stimulus, or server state owned by the app. |
| Form Objects | Host app | TreeView treats them as ordinary row objects when they expose stable IDs/parent IDs. |
| Validation errors | Host app | Render errors inside the row partial or around the table. |
| Persistence | Host app | Controllers/services decide update semantics. |
| Authorization | Host app | Decide which fields/actions each user can see or submit. |
| Dirty-state handling | Host app | Confirm or prevent collapse, lazy loading, or Turbo replacement when inputs changed. |
| Turbo Stream responses | Host app | TreeView can be re-rendered, but the app owns response timing and targets. |

## Bulk edit table pattern

Render every visible row as editable fields and submit them together. This is a good fit for names, statuses, flags, ordering fields, or other business attributes that users edit in batches.

Controller:

```ruby
class DocumentsController < ApplicationController
  def edit_tree
    @form = DocumentTreeForm.new(documents: Document.arrange_for_tree)
    build_tree_view(@form.rows)
  end

  def update_tree
    @form = DocumentTreeForm.new(document_tree_params)

    if @form.save
      redirect_to documents_path, notice: "Documents updated"
    else
      build_tree_view(@form.rows)
      render :edit_tree, status: :unprocessable_entity
    end
  end

  private

  def build_tree_view(rows)
    tree = TreeView::Tree.new(
      records: rows,
      id_method: :id,
      parent_id_method: :parent_id
    )

    @render_state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "documents/edit_tree_columns",
      ui_config: @tree_ui
    )
  end
end
```

View:

```erb
<%= form_with model: @form, url: update_tree_documents_path, method: :patch do |form| %>
  <table class="tree-view-table">
    <tbody>
      <%= tree_view_rows(@render_state, locals: { form: form }) %>
    </tbody>
  </table>

  <%= form.submit "Save changes" %>
<% end %>
```

Row partial:

```erb
<% row_index = form.object.index_for(item) %>

<%= form.fields_for :rows, item, index: row_index do |row_form| %>
  <td>
    <%= row_form.hidden_field :id %>
    <%= row_form.text_field :name, data: { tree_view_interactive: true } %>
    <% item.errors.full_messages_for(:name).each do |message| %>
      <div class="tree-view-row-error"><%= message %></div>
    <% end %>
  </td>
  <td>
    <%= row_form.select :status, Document.statuses.keys, {}, data: { tree_view_interactive: true } %>
  </td>
  <td>
    <%= row_form.check_box :featured, data: { tree_view_interactive: true } %>
  </td>
  <td>
    <%= row_form.text_area :notes, rows: 2, data: { tree_view_interactive: true } %>
  </td>
<% end %>
```

Keep hidden row IDs in each row so the host app can map submitted attributes back to existing records. Treat ordering, authorization, and permitted attributes as controller/Form Object concerns.

## Form Object pattern

A Form Object can be the row object rendered by TreeView. It only needs the methods TreeView uses for structure and display, such as `id`, `parent_id`, and any values referenced by the row partial.

```ruby
class DocumentTreeRowForm
  include ActiveModel::Model

  attr_accessor :id, :parent_id, :name, :status, :featured, :notes
end
```

Use the collection of row form objects to build the tree, then let the Form Object save the underlying records. This keeps TreeView independent from persistence and validation rules.

## Per-row edit pattern

Render normal display rows by default, then let a host-app action replace one row with an editing partial. This is useful when only one row should be edited at a time.

Action links can live in `row_actions_partial`:

```erb
<%= link_to "Edit",
  edit_document_tree_row_path(item),
  data: { turbo_frame: dom_id(item, :tree_row), tree_view_interactive: true } %>

<%= link_to "Show", document_path(item), data: { tree_view_interactive: true } %>
<%= button_to "Delete", document_path(item), method: :delete, data: { tree_view_interactive: true } %>
```

The host app owns the edit route and Turbo response. TreeView should only receive the resulting render state or partials to display.

## Inline editing layout notes

Inline editing means form controls appear inside the tree/table rows. TreeView supports that layout through `row_partial`, `row_actions_partial`, and row attributes. It does not decide:

- which row is currently in edit mode
- whether edits are saved immediately or in bulk
- how failed validations are shown
- whether optimistic updates, autosave, rollback, or retry are used
- how copy/paste, undo/redo, or spreadsheet-like cell navigation works

For a bulk edit table, render all rows as inputs and submit once. For per-row edit, render display rows until the host app swaps one row into editing UI.

## Selection checkboxes vs business checkboxes

TreeView selection checkboxes are for selecting rows for row-level or bulk actions. They are configured through TreeView selection options and submit selection payloads.

Business checkboxes are normal Rails form controls inside the host-owned row partial. Use them for fields such as `featured`, `active`, or `billable`.

Keep names and params separate. For example, `selected_documents[]` can be used for TreeView row selection, while `document_tree_form[rows][0][featured]` belongs to the edit form.

## Interactive controls and event conflicts

Inputs, selects, textareas, links, and buttons inside rows should not accidentally trigger row selection, drag, expand/collapse, or keyboard behavior.

Recommended patterns:

- mark controls with an interactive marker such as `data-tree-view-interactive="true"`
- stop propagation in host-app Stimulus controllers when controls have custom behavior
- keep TreeView selection checkboxes visually and semantically distinct from business form fields
- avoid making the entire row clickable when many form controls are present

This complements the planned interactive-control ignore marker: TreeView should recognize intentional controls inside rows, while host apps still own the editing behavior.

## Unsaved changes and row replacement risks

Editing controls inside rows can be removed or replaced by normal tree interactions. Host apps should decide whether to confirm, block, or preserve edits when:

- a dirty row is collapsed
- lazy loading replaces children while nested rows contain dirty inputs
- a Turbo Stream replaces a row currently in edit mode
- filtering or windowed rendering removes a dirty row from the DOM
- another action changes the row while the user is editing it

TreeView intentionally does not track dirty state. Add host-app Stimulus behavior or server-side guards when losing unsaved input would be harmful.

## Related docs

- [Cookbook](cookbook.md)
- [Usage](usage.md)
- [Selection](selection.md)
- [Rendering Boundaries](rendering-boundaries.md)
- [Host App Extension Points](host-app-extension-points.md)
