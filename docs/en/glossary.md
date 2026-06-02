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
| node_key | A tree-side key used by TreeView to identify a node for expansion, selection, persisted state, row payloads, and diagnostics. |
| UI identifier / DOM ID | A browser-facing identifier generated through `UiConfig` / `UiConfigBuilder` for HTML IDs, Turbo targets, row attributes, and related hooks. |
| tree_instance_key | A key used to distinguish a tree or screen when persisted state is saved. |

Design `node_key` values so they do not collide when multiple trees or heterogeneous nodes appear on the same screen. Expansion-related values such as `expanded_keys` and `collapsed_keys` must match tree-side node keys, not UI-only DOM IDs unless the host app intentionally uses the same stable value in both layers.

## Rendering

| Term | Meaning |
|---|---|
| RenderState | Screen-level rendering state. Holds the tree, root items, row partial, UI config, selection, and related options. |
| UiConfig | UI configuration for DOM IDs and path builders. |
| row_partial | A host-app partial that renders application-specific columns. |
| visible row | A row that is eligible for rendering after expansion state and render scope are applied. |
| render scope | Options that limit rendered rows by depth or leaf distance. |
| toggle scope | Options that pass toggle boundaries to path builders. |

## Integration surface

| Term | Meaning |
|---|---|
| remote state / remote loading state | Loading, loaded, error, and retry signals rendered for lazy-loading rows and handled by the `tree-view-remote-state` controller. TreeView provides the row hooks and controller boundary; the host app owns fetch behavior, Turbo requests, authorization, queries, retry UI, and children pagination. See [Lazy Loading](lazy-loading.md). |
| transfer payload | Hash-like row data copied to browser drag/drop transfer events through `row_event_payload_builder`. TreeView exposes the transfer boundary; the host app owns drop targets, authorization, persistence, and final outcome UI. See [Drag and Drop](drag-and-drop.md). |
| drop position | A coarse transfer cue reported as `before`, `inside`, or `after` for the target row. Treat it as input to host-app business rules, not as final authorization or persistence policy. See [Drag and Drop](drag-and-drop.md). |
| resource-table bridge / ResourceTableRenderState | A bridge for integrations where a table layer already owns column state while TreeView owns hierarchy and row rendering. Host apps and table layers remain responsible for columns, preferences, queries, authorization, and business actions. See [Resource table bridge](resource-table-bridge.md). |
| windowed rendering | An opt-in rendering mode that slices currently visible rows by `offset` and `limit`. TreeView owns visible-row flattening and window metadata; the host app owns scroll observers, URL state, pagination controls, and data fetching. See [Windowed Rendering](windowed-rendering.md). |
| children pagination | A host-app pattern for loading large child sets in pages while using TreeView lazy-loading hooks. TreeView provides child URL hooks and remote-state boundaries; the host app owns cursors, limits, next-page detection, queries, authorization, and Turbo Stream responses. See [Children Pagination](children-pagination.md). |

## Expansion

| Term | Meaning |
|---|---|
| initial_state | Default initial expansion state, either `:expanded` or `:collapsed`. |
| expanded_keys | Tree-side node keys that should be expanded on initial render. |
| collapsed_keys | Tree-side node keys that should be collapsed on initial render. |
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
