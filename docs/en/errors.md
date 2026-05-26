# Error hierarchy

TreeView exposes a small public error hierarchy for host apps that need to rescue TreeView failures separately from other application errors.

## Public classes

| Error class | Parent | When it is raised |
|---|---|---|
| `TreeView::Error` | `ArgumentError` | Base class for public TreeView validation and configuration failures. |
| `TreeView::ConfigurationError` | `TreeView::Error` | Invalid TreeView options, invalid mode combinations, invalid builders, or unsupported configuration values. |
| `TreeView::InvalidTreeError` | `TreeView::Error` | Tree data cannot be treated as a valid tree. |
| `TreeView::DuplicateNodeKeyError` | `TreeView::InvalidTreeError` | `validate_unique_node_keys!` or `validate_node_keys: true` finds duplicate node keys. |
| `TreeView::CycleDetectedError` | `TreeView::InvalidTreeError` | Tree traversal or `validate_no_cycles!` finds a parent/child cycle. |
| `TreeView::InvalidRenderWindowError` | `TreeView::Error` | `RenderWindow` receives an invalid `offset` or `limit`. |

`TreeView::Error` intentionally inherits from `ArgumentError` for compatibility with existing host apps that already rescue TreeView's previous validation failures as `ArgumentError`.

## Representative messages

These examples show the level of detail host apps should expect from common validation failures:

- `render_scope contains unknown keys: max_depths; supported keys are: max_depth, max_leaf_distance`
- `initial_state must be one of: expanded, collapsed; use :expanded or :collapsed`
- `expanded_keys and collapsed_keys cannot include the same keys: "node:1"; remove each key from one side`
- `duplicate node_key detected: "document:42"; configure node_key_resolver or ensure records expose unique IDs before rendering`
- `offset must be a non-negative Integer; pass 0 or a positive row offset`

Wording can improve over time, but the same information should remain available: what failed, which value or key is involved, and what direction usually fixes it.

## Rescue examples

Rescue all TreeView validation/configuration failures:

```ruby
begin
  tree.root_items
rescue TreeView::Error => error
  Rails.logger.warn("TreeView failed: #{error.message}")
end
```

Handle specific data validation failures:

```ruby
begin
  tree.validate_unique_node_keys!
  tree.validate_no_cycles!
rescue TreeView::DuplicateNodeKeyError => error
  # Fix the node_key_resolver or ensure IDs are unique.
rescue TreeView::CycleDetectedError => error
  # Fix parent_id values so every path reaches a root.
end
```

## Compatibility guidance

New code should prefer `TreeView::Error` or one of its subclasses when handling TreeView-specific failures. Existing code that rescues `ArgumentError` continues to work because TreeView-specific errors remain `ArgumentError` subclasses.

Use specific subclasses only for documented public validation/configuration cases. Error classes outside this page should be treated as internal unless they are documented later.
