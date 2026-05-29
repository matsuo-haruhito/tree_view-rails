# Render log silencing

This page is kept as a compatibility alias for older links.

The current render-log documentation lives at [Render log level](render-log-level.md).

Use that page for the maintained description of `TreeView.configuration.render_log_level`, accepted values, the default `:warn` behavior, and the `nil` escape hatch for keeping Rails' normal partial render logging unchanged.

TreeView's responsibility is limited to lowering the log level around helper-rendered TreeView partials. Host applications still own global logger configuration, SQL and controller log verbosity, business-event logging, request tracing, and custom instrumentation.
