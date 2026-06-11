# Public Setup Surface

The persisted-state install generator is a public setup entrypoint:

- `bin/rails generate tree_view:state:install`
- `bin/rails generate tree_view:state:install User`

The machine-readable setup-generator contract in `config/public_api_manifest.yml` tracks the generator name, the optional owner argument, and the generated destination paths.

The generated destination paths are part of the setup surface:

- `db/migrate/*_create_tree_view_states.rb`
- `app/models/tree_view_state.rb`
- `app/models/concerns/tree_view_state_owner.rb`

This path-level contract does not freeze the migration schema or the generated file contents. Use the generator to create the persisted-state migration, model, and owner concern, then review the generated files in the host app.

Storage ownership, authorization, save timing, controller actions, and UI wiring remain host-app responsibilities. See [Persisted State](persisted-state.md) for setup details.
