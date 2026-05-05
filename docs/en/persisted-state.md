# Persisted State

This page explains APIs for saving and restoring TreeView expansion state in the host app.

## Overview

Persisted state lets a host app save expansion state per user, screen, or owner and restore it on the next render.

TreeView is responsible for:

- `TreeView::PersistedState` as the persisted-state value object
- `TreeView::StateStore` for loading and saving through a host app model
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

## Responsibility boundary

| Area | TreeView | Host app |
|---|---|---|
| persisted state value object | yes | no |
| generated model/migration template | yes | reviews and migrates |
| loading/saving through StateStore | yes | provides owner and key |
| choosing owner model | no | yes |
| deciding save timing | no | yes |
| controller/API endpoint | no | yes |
| authorization | no | yes |
| UI event wiring | hooks only | yes |
