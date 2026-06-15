#!/usr/bin/env ruby
# frozen_string_literal: true

require "rubygems/package"

# Keep representative English and Japanese files in these groups so package
# verification covers the bilingual locale, public API, docs entrypoints,
# release docs, and user-facing mockup entrypoints shipped by the gem. The
# groups are intentionally representative rather than a mirror of the gemspec
# glob; add a path here when a new public-facing surface needs release-package
# evidence beyond inclusion in `spec.files`.
REQUIRED_PACKAGED_PATH_GROUPS = {
  "Rails helpers" => %w[
    app/helpers/tree_view_helper.rb
    app/helpers/tree_view_helper/support.rb
    app/helpers/tree_view_helper/rendering.rb
    app/helpers/tree_view_helper/dom.rb
    app/helpers/tree_view_helper/row_attributes.rb
    app/helpers/tree_view_helper/selection.rb
    app/helpers/tree_view_helper/transfer.rb
    app/helpers/tree_view_helper/visuals.rb
    app/helpers/tree_view_helper/render_scope.rb
    app/helpers/tree_view_helper/lazy_loading.rb
    app/helpers/tree_view_helper/toolbar.rb
    app/helpers/tree_view_breadcrumb_helper.rb
  ],
  "Rails views and assets" => %w[
    app/views/tree_view/_tree_row.html.erb
    app/assets/stylesheets/tree_view.scss
  ],
  "JavaScript entrypoints" => %w[
    app/javascript/tree_view/index.js
    app/javascript/tree_view/index.d.ts
    app/javascript/tree_view/client_controller.js
    app/javascript/tree_view/remote_state_controller.js
    app/javascript/tree_view/selection_controller.js
    app/javascript/tree_view/state_controller.js
    app/javascript/tree_view/transfer_controller.js
  ],
  "Configuration and locales" => %w[
    config/importmap.tree_view.rb
    config/public_api_manifest.yml
    config/locales/tree_view.toolbar.en.yml
    config/locales/tree_view.toolbar.ja.yml
  ],
  "Root docs" => %w[
    CHANGELOG.md
    README.md
    docs/README.md
  ],
  "Mockup entrypoints" => %w[
    docs/mockups/README.md
    docs/mockups/review-gallery.html
    docs/mockups/default-tree.html
    docs/mockups/default-tree.css
    docs/mockups/assets/readme-default-tree.svg
  ],
  "Bilingual setup and public API docs" => %w[
    docs/en/installation.md
    docs/ja/installation.md
    docs/en/public-api.md
    docs/ja/public-api.md
  ],
  "Bilingual development docs" => %w[
    docs/en/development.md
    docs/ja/development.md
  ],
  "README-linked public JavaScript docs" => %w[
    docs/en/js-events.md
    docs/ja/js-events.md
  ],
  "Public setup surface docs" => %w[
    docs/en/public-setup-surface.md
    docs/ja/public-setup-surface.md
  ],
  "Bilingual release docs" => %w[
    docs/en/release.md
    docs/ja/release.md
  ],
  "Release note candidate docs" => %w[
    docs/en/release-note-candidates.md
    docs/ja/release-note-candidates.md
  ]
}.freeze

REQUIRED_PACKAGED_PATHS = REQUIRED_PACKAGED_PATH_GROUPS.values.flatten.freeze

INSTALLATION_DOC_PATHS = %w[
  docs/en/installation.md
  docs/ja/installation.md
].freeze

INSTALLATION_REQUIRED_SIGNALS = [
  "app/assets/stylesheets/tree_view.scss",
  "app/helpers/tree_view_helper.rb",
  "app/javascript/tree_view/**/*",
  "app/views/tree_view/**/*",
  "config/importmap.tree_view.rb",
  "config/locales/**/*",
  "config/public_api_manifest.yml",
  "README.md",
  "CHANGELOG.md",
  "docs/**/*",
  "@import \"tree_view\";",
  "pin \"tree_view\", to: \"tree_view/index.js\""
].freeze

PACKAGED_DOCS_FORBIDDEN_RELATIVE_ROOT_LINKS = {
  "docs/README.md" => [
    "../Product%20Profile.md",
    "../AGENTS.md"
  ]
}.freeze

root = File.expand_path("..", __dir__)
gem_path = ARGV.first || Dir[File.join(root, "tree_view-*.gem")].max_by { |path| File.mtime(path) }

abort "No built gem found. Run `gem build tree_view.gemspec` first." unless gem_path

files = Gem::Package.new(gem_path).spec.files
missing_by_group = REQUIRED_PACKAGED_PATH_GROUPS.transform_values do |paths|
  paths.reject { |path| files.include?(path) }
end.reject { |_group, paths| paths.empty? }
missing = missing_by_group.values.flatten
missing_installation_signals = INSTALLATION_DOC_PATHS.to_h do |path|
  content = File.read(File.join(root, path))
  [path, INSTALLATION_REQUIRED_SIGNALS.reject { |signal| content.include?(signal) }]
end.reject { |_path, missing_signals| missing_signals.empty? }
forbidden_packaged_doc_links = PACKAGED_DOCS_FORBIDDEN_RELATIVE_ROOT_LINKS.to_h do |path, forbidden_links|
  content = File.read(File.join(root, path))
  [path, forbidden_links.select { |link| content.include?(link) }]
end.reject { |_path, links| links.empty? }

importmap_path = File.join(root, "config/importmap.tree_view.rb")
importmap_content = File.read(importmap_path)
importmap_pin_missing = !importmap_content.include?("pin \"tree_view\", to: \"tree_view/index.js\"")

if missing.empty? && missing_installation_signals.empty? && forbidden_packaged_doc_links.empty? && !importmap_pin_missing
  puts "Gem package contents verified: #{File.basename(gem_path)}"
else
  warn "Gem package contents verification failed: #{File.basename(gem_path)}"

  missing_by_group.each do |group, paths|
    warn "Missing packaged files for #{group}:"
    paths.each { |path| warn "  - #{path}" }
  end

  missing_installation_signals.each do |path, signals|
    warn "Missing installation docs signals in #{path}:"
    signals.each { |signal| warn "  - #{signal}" }
  end

  forbidden_packaged_doc_links.each do |path, links|
    warn "Forbidden repository-only root doc links in packaged #{path}:"
    links.each { |link| warn "  - #{link}" }
  end

  if importmap_pin_missing
    warn "Missing TreeView importmap pin in config/importmap.tree_view.rb:"
    warn "  - pin \"tree_view\", to: \"tree_view/index.js\""
  end

  abort "Gem package contents verification failed."
end
