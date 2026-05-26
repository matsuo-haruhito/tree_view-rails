# Persisted State

This page explains APIs for saving and restoring TreeView expansion state in the host app.

## Overview

Persisted state lets a host app save expansion state per user, screen, or owner and restore it on the next render.

TreeView is responsible for:

- `TreeView::PersistedState` as the persisted-state value object
- `TreeView::StateStore` for loading and saving through a host app model
- `TreeView::PersistedStateController` for a small controller concern that bridges request params to `StateStore#save!`
- an install generator for the migration, model, and concern
- passing persisted expanded keys into `RenderState`

The host app remains responsible for storage ownership, authorization, save timing, controller actions, and UI wiring.

## Generator

Use the generator to create model and migration templates.

```bash
bin/rails generate tree_view:state:install
```

Generated files:

- `db/migrate/*_create_tree_view_states.rb`
- `app/models/tree_view_state.rb`
- `app/models/concerns/tree_view_state_owner.rb`

Review the migration, then run:

```bash
bin/rails db:migrate
```

### Include the owner concern automatically

Pass an owner model name when you want the generator to include `TreeViewStateOwner` in an existing owner model.

```bash
bin/rails generate tree_view:state:install User
```

This still creates the same migration, model, and concern files. If `app/models/user.rb` exists and does not already include `TreeViewStateOwner`, the generator adds the include line.

If the owner model file does not exist, the generator skips model injection and you can include the concern manually.

## Owner model

Include the concern in the host app owner model.

```ruby
class User < ApplicationRecord
  include TreeViewStateOwner
end
```

The owner can be a user, workspace, project, or any model that should own the screen state.

## StateStore

`TreeView::StateStore` loads and saves persisted state using an owner and tree instance key.

```ruby
store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "documents:index"
)

persisted_state = store.load
```

Save expansion state:

```ruby
persisted_state = store.save(expanded_keys: expanded_keys)
```

## Minimal controller concern

If your host app wants to keep the save endpoint small, include `TreeView::PersistedStateController` in the controller and let it bridge the raw request values to `StateStore#save!`.

```ruby
class TreeStatesController < ApplicationController
  include TreeView::PersistedStateController

  def update
    authorize current_user, :update?

    persisted_state = save_tree_view_persisted_state!(
      model: TreeViewState,
      owner: current_user,
      tree_instance_key: params.require(:tree_instance_key),
      expanded_keys: params[:expanded_keys]
    )

    render json: {
      tree_instance_key: persisted_state.tree_instance_key,
      expanded_keys: persisted_state.expanded_keys
    }
  end
end
```

The concern keeps responsibility boundaries narrow:

- it normalizes `expanded_keys` from either an array-like param or a comma-separated string
- it still requires the host app to choose the owner, authorization, route, save timing, and response shape
- it does not provide a finished controller or lock the host app into Turbo Stream vs JSON responses

## Browser event wiring

If your host app wants to persist expansion changes as users interact, listen for the public `tree-view-state:state-changed` event on the TreeView state controller element and forward `event.detail.expandedKeys` to your save endpoint.

```js
const element = document.querySelector("[data-controller~='tree-view-state']")

if (element) {
  element.addEventListener("tree-view-state:state-changed", async (event) => {
    const { viewKey, expandedKeys } = event.detail
    if (!viewKey) return

    await fetch("/tree_states", {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
      },
      body: JSON.stringify({
        tree_instance_key: viewKey,
        expanded_keys: expandedKeys
      })
    })
  })
}
```

A few practical notes:

- `viewKey` comes from `data-tree-view-state-view-key-value`. A common pattern is to keep it aligned with the server-side `tree_instance_key` so the browser listener can save the correct screen state without extra lookup.
- `expandedKeys` is the current expanded node-key snapshot published by the state controller after connect, `refresh`, and expand/collapse updates.
- Because the controller dispatches once on initial connect, host apps that only want user-initiated saves can debounce the listener, ignore the first event, or gate saves behind their own dirty-state policy.
- TreeView only dispatches the event. The host app still owns the route, authorization, retry behavior, and the decision to save on every change or only at explicit checkpoints.

## RenderState integration

Pass the loaded state to `RenderState`.

```ruby
persisted_state = store.load

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  persisted_state: persisted_state
)
```

Explicit `expanded_keys` take precedence over persisted state.

```ruby
render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "documents/tree_columns",
  ui_config: tree_ui,
  persisted_state: persisted_state,
  expanded_keys: forced_expanded_keys
)
```

## Tree instance key

`tree_instance_key` separates saved state.

Examples:

- `documents:index`
- `projects:sidebar`
- `workspace:#{workspace.id}:documents`

Use different keys for different screens or trees, even when the owner is the same.

## Multiple tree instances in one host app

A host app can render more than one persisted tree for the same owner. A common pattern is a sidebar tree plus a detail tree on the main content area.

```ruby
sidebar_store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "projects:sidebar"
)

detail_store = TreeView::StateStore.new(
  owner: current_user,
  tree_instance_key: "projects:#{project.id}:detail"
)

sidebar_state = sidebar_store.load

detail_state = detail_store.load
```

Pass each loaded state to the matching render state.

```ruby
@sidebar_render_state = TreeView::RenderState.new(
  tree: sidebar_tree,
  root_items: sidebar_tree.root_items,
  row_partial: "projects/sidebar_tree_columns",
  ui_config: sidebar_tree_ui,
  persisted_state: sidebar_state
)

@detail_render_state = TreeView::RenderState.new(
  tree: detail_tree,
  root_items: detail_tree.root_items,
  row_partial: "projects/detail_tree_columns",
  ui_config: detail_tree_ui,
  persisted_state: detail_state
)
```

Use these rules when choosing keys:

- split keys by placement or responsibility, such as `sidebar`, `index`, or `detail`
- include a record or workspace identifier when the detail tree changes by page
- reuse the same key only when two renders are intentionally sharing the same expansion state

TreeView stores expanded keys only. The host app still decides where save requests enter, when to persist updates, and how to combine persisted state with the current render scope.

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| persisted state value object | yes | no |
| generated model/migration template | yes | reviews and migrates |
| loading/saving through StateStore | yes | provides owner and key |
| save helper / controller concern | optional | includes and uses it |
| choosing owner model | optional generator argument | yes |
| deciding save timing | no | yes |
| controller/API endpoint | no | yes |
| authorization | no | yes |
| response format | no | yes |
| UI event wiring | hooks only | yes |
