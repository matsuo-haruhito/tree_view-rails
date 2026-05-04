# Children pagination

TreeView does not own database pagination.

For nodes with many children, the host app should decide which children are loaded for each request and pass only the visible records to TreeView.

Recommended shape:

- render the first page of children normally
- render a host-provided load-more row or action partial
- use Turbo Stream to append the next page
- keep selection and row payloads stable across pages
- use `loading_builder` and `error_builder` for remote state display

TreeView does not provide a pagination API today. Keep pagination in the host app and treat TreeView as the rendering layer for the rows you decided to load.
