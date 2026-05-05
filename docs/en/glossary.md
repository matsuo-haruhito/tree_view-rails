# Glossary

This page defines common terms used in TreeView docs and code.

## Tree / node / item

| Term | Meaning |
|---|---|
| item | A host-app record or object, such as `Document` or `Project`. |
| node | An item when it is treated as part of a TreeView tree. |
| root | A top-level node without a parent. |
| child | A direct child node of another node. |
| descendant | Any node below another node, including children and grandchildren. |
| ancestor | Any node above another node, including parents and grandparents. |
| leaf | A node without children. |

TreeView often uses `item` for the host-app object and `node` when describing the object in the tree structure.

## key / id

| Term | Meaning |
|---|---|
| id | A host-app record ID, usually a database ID. |
| node_key | A key used by TreeView to identify a node. Used for DOM IDs, selection, expanded keys, and more. |
| tree_instance_key | A key used to distinguish a tree or screen when persisted state is saved. |

Design `node_key` values so they do not collide when multiple trees or heterogeneous nodes appear on the same screen.

## Rendering

| Term | Meaning |
|---|---|
| RenderState | Screen-level rendering state. Holds the tree, root items, row partial, UI config, selection, and related options. |
| UiConfig | UI configuration for DOM IDs and path builders. |
| row_partial | A host-app partial that renders application-specific columns. |
| visible row | A row that is eligible for rendering after expansion state and render scope are applied. |
| render scope | Options that limit rendered rows by depth or leaf distance. |
| toggle scope | Options that pass toggle boundaries to path builders. |

## Expansion

| Term | Meaning |
|---|---|
| initial_state | Default initial expansion state, either `:expanded` or `:collapsed`. |
| expanded_keys | Node keys that should be expanded on initial render. |
| collapsed_keys | Node keys that should be collapsed on initial render. |
| persisted state | Saved and restored expansion state. |

## Tree variants

| Term | Meaning |
|---|---|
| records mode | Builds a tree from `records` and `parent_id_method`. |
| resolver mode | Builds a tree from `roots` and `children_resolver`. |
| adapter mode | Builds a tree from an adapter such as `GraphAdapter`. |
| PathTree | A tree that fills ancestors from root to matched items. |
| ReverseTree | A tree that walks from matched items toward roots. |

## Responsibility boundary

| Term | Meaning |
|---|---|
| TreeView responsibility | UI primitives, helpers, builders, and controller hooks provided by the gem. |
| host app responsibility | CRUD, authorization, persistence, queries, Turbo responses, and business-specific UI. |

TreeView provides tree UI primitives. Application-specific behavior belongs in the host app.
