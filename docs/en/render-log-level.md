# Render log level

TreeView renders its built-in partials through Rails helpers such as `tree_view_rows`.
Rails may emit informational `Rendered tree_view/...` entries for those partial renders in the host application log.

TreeView suppresses those helper-rendered partial logs at `:warn` by default so the host application log is not filled with TreeView internals.

```ruby
TreeView.configure do |config|
  config.render_log_level = :warn
end
```

`render_log_level` is one of the manifest-backed `TreeView.configure` option keys in `config/public_api_manifest.yml`. This page documents its accepted values and logging boundary; it does not add a new configuration option.

`initial_state` is also a manifest-backed `TreeView.configure` option key. Its accepted public values are `:expanded` and `:collapsed`; string values such as `"collapsed"` are normalized to symbols, and invalid values raise `TreeView::ConfigurationError`. The accepted value set is guarded by compatibility specs and docs rather than a separate manifest value schema.

## Changing the level

Set `render_log_level` to any standard Ruby logger level name when the host app needs a different threshold.

```ruby
TreeView.configure do |config|
  config.render_log_level = :error
end
```

The accepted values are:

- `:debug`
- `:info`
- `:warn`
- `:error`
- `:fatal`
- `:unknown`

Ruby `Logger` level constants such as `Logger::ERROR` are also accepted and normalized to their symbol names.

## Disabling TreeView render log silencing

Set `render_log_level` to `nil` to keep Rails' normal partial render logging behavior.

```ruby
TreeView.configure do |config|
  config.render_log_level = nil
end
```

This setting only wraps TreeView helper-rendered partials. It does not change `Rails.logger.level` for the host application globally.
