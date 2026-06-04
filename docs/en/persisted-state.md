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

For a static visual reference of the save/restore handoff, see [Persisted State boundary mockup](../mockups/persisted-state-boundary.html). The mockup shows representative before, changed, restored, save-failed, and retry cues without turning storage, save endpoints, authorization, or retry policy into gem-owned behavior.

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

For a namespaced owner, pass the constant name. The generator resolves the conventional file path and can update both `class Admin::User < ApplicationRecord` and module-wrapped `module Admin; class User < ApplicationRecord` style definitions.

```bash
bin/rails generate tree_view:state:install Admin::User
```

If `app/models/admin/user.rb` exists and contains one of those representative class definitions, the generator adds the include line inside the owner class.

If the owner model file does not exist, or the class definition is too custom for the generator to find safely, the generator skips model injection and you can include the concern manually.

### If owner injection is skipped

When the generator reports that the owner model file does not exist or the class definition was not found, first confirm which model should own the saved tree state. Then add `include TreeViewStateOwner` to that existing model after the generated concern exists at `app/models/concerns/tree_view_state_owner.rb`.

For a plain owner model, the manual include is the same line the generator would add:

```ruby
# app/models/user.rb
class User < ApplicationRecord
  include TreeViewStateOwner
end
```

For a namespaced or module-wrapped owner, add the include inside the actual class that will be passed as the `owner:` to `TreeView::StateStore`:

```ruby
# app/models/admin/user.rb
module Admin
  class User < ApplicationRecord
    include TreeViewStateOwner
  end
end
```

Manual include is the expected follow-up when the owner model is generated later or uses a project-specific file layout or class definition that the generator did not update. Do not change the generated migration or `TreeViewState` model for this case; the host app only needs the owner class to include the concern before it calls `tree_view_state_for`, `save_tree_view_state!`, or passes the owner into `TreeView::StateStore`.

## Owner model

Include the concern in the host app owner model.

```ruby
class User < ApplicationRecord
  include TreeViewStateOwner
end
```

The owner can be a user, workspace, project, or any model that should own the screen state.

## StateStore

`TreeView::StateStore` reads and writes persisted state through the generated host app model. The store is initialized with the model, and each read or write receives the owner and tree instance key.

```ruby
store = TreeView::StateStore.new(model: TreeViewState)

persisted_state = store.find(
  owner: current_user,
  tree_instance_key: "documents:index"
)
```

Save expansion state:

```ruby
persisted_state = store.save!(
  owner: current_user,
  tree_instance_key: "documents:index",
  expanded_keys: expanded_keys
)
```

Clear saved expansion state for the same owner and tree instance key:

```ruby
persisted_state = store.clear!(
  owner: current_user,
  tree_instance_key: "documents:index"
)
```

`clear!` deletes the matching persisted-state record when one exists. When no record exists, it still returns a `TreeView::PersistedState` for the requested key with empty `expanded_keys`, matching the empty-state behavior of `find`.

TreeView only provides the store API. The host app still owns the reset route, authorization, confirmation UI, retry behavior, and response shape.

### Storage lifecycle and cleanup policy

`StateStore#clear!` is a reset for one owner and one `tree_instance_key`. It is not a retention policy, bulk cleanup helper, or deleted-owner pruning task.

Long-running host apps should treat persisted-state lifecycle as part of their own storage policy. For example, the host app decides whether old rows should expire, whether rows for deleted owners should be removed by an existing dependent-destroy or cleanup job, and whether audit or privacy rules require a shorter retention period.

TreeView does not currently provide a cleanup rake task or default TTL. If the host app needs one, build it against the generated model and keep the scope tied to the app's owner, `tree_instance_key`, timestamp, and authorization rules. Future lifecycle helper proposals, if any, should keep those host-app policy decisions separate from the current `find` / `save!` / `clear!` contract.

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
store = TreeView::StateStore.new(model: TreeViewState)

persisted_state = store.find(
  owner: current_user,
  tree_instance_key: "documents:index"
)

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
store = TreeView::StateStore.new(model: TreeViewState)

sidebar_state = store.find(
  owner: current_user,
  tree_instance_key: "projects:sidebar"
)

detail_state = store.find(
  owner: current_user,
  tree_instance_key: "projects:#{project.id}:detail"
)
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
| storage lifecycle / cleanup policy | no | yes |
| controller/API endpoint | no | yes |
| authorization | no | yes |
| response format | no | yes |
| UI event wiring | hooks only | yes |