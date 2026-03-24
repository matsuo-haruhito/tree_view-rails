// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails';
import "controllers";
import { application } from "controllers/application";
import { registerTreeViewControllers } from "tree_view";

registerTreeViewControllers(application);

// Ensure open/close links always request Turbo Stream responses.
document.addEventListener("turbo:before-fetch-request", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLAnchorElement)) return;
  if (target.dataset.turboStream !== "true") return;

  const accept = "text/vnd.turbo-stream.html, text/html;q=0.9";
  const headers = event.detail.fetchOptions.headers;
  if (headers instanceof Headers) {
    headers.set("Accept", accept);
  } else {
    headers.Accept = accept;
  }
});
