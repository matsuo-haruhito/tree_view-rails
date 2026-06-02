# GraphAdapter

Use `TreeView::GraphAdapter` when the host app needs TreeView rows for heterogeneous or graph-like nodes that do not fit one parent-id column.

GraphAdapter is intentionally small. It gives `TreeView::Tree` three things:

| Input | Required | Purpose |
|---|---:|---|
| `roots:` | yes | Top-level nodes TreeView starts from. |
| `children_resolver:` | yes | Callable that returns the children for a node. `nil` becomes an empty array, and a single child is wrapped in an array. |
| `node_key_resolver:` | no | Callable that returns the stable node key. Without it, TreeView uses `[node.class.name, node.public_send(id_method)]`. |

## Minimal example

```ruby
adapter = TreeView::GraphAdapter.new(
  roots: [workspace],
  children_resolver: ->(node) {
    case node
    when Workspace
      node.projects.visible_to(current_user).to_a
    when Project
      node.documents.visible_to(current_user).to_a
    else
      []
    end
  },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)

tree = TreeView::Tree.new(adapter: adapter)

render_state = TreeView::RenderState.new(
  tree: tree,
  root_items: tree.root_items,
  row_partial: "workspaces/tree_columns",
  ui_config: tree_ui
)
```

This keeps the tree rendering API the same as records mode while letting the host app decide how each node type finds its children.

## When to use it

Use GraphAdapter when:

- one `parent_id_method` cannot describe the hierarchy;
- a tree mixes model classes, external nodes, generated nodes, or edge-derived children;
- the host app already has a traversal policy and only needs TreeView rendering and interaction hooks.

Prefer records mode when every row is the same model shape and a parent-id column describes the tree. Prefer `PathTreeBuilder` when records expose path-like values and the host app wants generated folder nodes.

## Responsibility boundary

TreeView traverses the roots and child arrays returned by the adapter. The host app owns:

- graph traversal policy and which node types may appear;
- authorization and visibility filtering before children are returned;
- query planning, eager loading, caching, and pagination strategy;
- cycle prevention or cycle handling policy;
- stable node key design across heterogeneous node types;
- row partials, labels, routes, and business actions.

GraphAdapter does not add a cycle-detection engine, authorization layer, query optimizer, persistence model, or business graph DSL. If the same node can appear through multiple paths, decide whether that is valid for your screen before passing nodes to TreeView.

## Node keys

For heterogeneous nodes, pass a `node_key_resolver:` that namespaces by type or source system.

```ruby
node_key_resolver = ->(node) {
  TreeView.node_key(node.class.name, node.id)
}
```

Use the same key strategy when configuring initial expansion, persisted state, row IDs, or host-app routes that need to refer to the same logical node. See [Node keys](node-keys.md) and [API overview: Node keys and UI identifiers](api-overview.md#node-keys-and-ui-identifiers) for details.

## Performance notes

Materialize children before returning them from the resolver when rows may be rendered more than once.

```ruby
children_by_project_id = Project.visible_to(current_user).to_a.index_with do |project|
  project.documents.visible_to(current_user).includes(:latest_version).to_a
end

adapter = TreeView::GraphAdapter.new(
  roots: projects,
  children_resolver: ->(node) {
    node.is_a?(Project) ? children_by_project_id.fetch(node.id, []) : []
  },
  node_key_resolver: ->(node) { TreeView.node_key(node.class.name, node.id) }
)
```

For more practical checklist items, see [Cookbook: GraphAdapter and ActiveRecord performance](cookbook.md#graphadapter-and-activerecord-performance).

## Related documents

- [Decision guide](decision-guide.md)
- [API overview: adapter mode](api-overview.md#adapter-mode)
- [API reference: TreeView::Tree](api.md#treeviewtree)
- [Node keys](node-keys.md)
- [Tree diagnostics](tree-diagnostics.md)
- [Cookbook: GraphAdapter and ActiveRecord performance](cookbook.md#graphadapter-and-activerecord-performance)
