# Render Log Silencing

TreeView lowers the log level for its own helper-rendered partials by default so host app logs do not fill up with repeated `Rendered tree_view/...` entries.

This setting only affects partial rendering that goes through TreeView helpers such as `tree_view_rows`. It does not replace the host app's logger policy, business logs, controller logs, SQL logs, or custom instrumentation.

## Default behavior

- Default: `:warn`
- Effect: TreeView wraps helper-rendered partial output in `Rails.logger.silence(...)` when the logger supports it
- Scope: only TreeView helper-rendered partials

TreeView reads this value from `TreeView.configuration.render_log_level`.

## Configuration

Use `TreeView.configure` to change the level globally.

```ruby
TreeView.configure do |config|
  config.render_log_level = :info
end
```

Valid symbolic values are:

- `:debug`
- `:info`
- `:warn`
- `:error`
- `:fatal`
- `:unknown`

You can also pass the matching `Logger` constant. TreeView normalizes it back to the symbolic setting.

```ruby
TreeView.configure do |config|
  config.render_log_level = Logger::INFO
end
```

## When to use `nil`

Set `render_log_level` to `nil` when you want Rails render logs to stay unchanged.

```ruby
TreeView.configure do |config|
  config.render_log_level = nil
end
```

This disables TreeView's `logger.silence(...)` wrapper and lets partial render entries appear with the host app's normal logging behavior.

## Picking a level

- Use `:warn` when TreeView render noise is not useful during normal development or operations.
- Use `:info` or `:debug` when you want more visibility while checking row partial wiring or render flow.
- Use `nil` when the host app already has its own log filtering rules and you want TreeView to stay out of that decision.

## Responsibility boundary

TreeView only decides whether to silence logs around its own helper-rendered partials.

The host app still owns:

- Rails logger configuration
- log formatters and tagged logging
- SQL and controller log verbosity
- business-event logging
- request tracing and instrumentation

If the symptom is "I cannot see TreeView partial render lines" or "TreeView render lines are too noisy", start with this setting before changing the host app's broader logging policy.
