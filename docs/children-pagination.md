# Children pagination

TreeView does not own database pagination.

For nodes with many children, the host app should decide which children are loaded for each request and pass only the visible records to TreeView.

Recommended shape:

- render the first page of children normally
- render a host-provided load-more row or action partial
- use Turbo Stream to append the next page
- keep selection and row payloads stable across pages
- use `loading_builder` and `error_builder` for remote state display

A future TreeView pagination API should be opt-in and should not change the default tree rendering path.

The API should focus on view hooks such as load-more labels, paths, and row data. It should not own SQL, Active Record scopes, or business-specific paging rules.
