#!/usr/bin/env ruby
# frozen_string_literal: true

require "rubygems/package"

# Keep representative English and Japanese files in this list so package
# verification covers the bilingual locale, public API, docs entrypoints,
# and release docs shipped by the gem.
REQUIRED_PACKAGED_PATHS = %w[
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
  app/views/tree_view/_tree_row.html.erb
  app/assets/stylesheets/tree_view.scss
  app/javascript/tree_view/index.js
  app/javascript/tree_view/client_controller.js
  app/javascript/tree_view/remote_state_controller.js
  app/javascript/tree_view/selection_controller.js
  app/javascript/tree_view/state_controller.js
  app/javascript/tree_view/transfer_controller.js
  config/importmap.tree_view.rb
  config/public_api_manifest.yml
  config/locales/tree_view.toolbar.en.yml
  config/locales/tree_view.toolbar.ja.yml
  CHANGELOG.md
  README.md
  docs/README.md
  docs/en/installation.md
  docs/ja/installation.md
  docs/en/public-api.md
  docs/ja/public-api.md
  docs/en/release.md
  docs/ja/release.md
].freeze

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

root = File.expand_path("..", __dir__)
gem_path = ARGV.first || Dir[File.join(root, "tree_view-*.gem")].max_by { |path| File.mtime(path) }

abort "No built gem found. Run `gem build tree_view.gemspec` first." unless gem_path

files = Gem::Package.new(gem_path).spec.files
missing = REQUIRED_PACKAGED_PATHS.reject { |path| files.include?(path) }
missing_installation_signals = INSTALLATION_DOC_PATHS.to_h do |path|
  content = File.read(File.join(root, path))
  [path, INSTALLATION_REQUIRED_SIGNALS.reject { |signal| content.include?(signal) }]
end.reject { |_path, missing_signals| missing_signals.empty? }

importmap_path = File.join(root, "config/importmap.tree_view.rb")
importmap_content = File.read(importmap_path)
importmap_pin_missing = !importmap_content.include?("pin \"tree_view\", to: \"tree_view/index.js\"")

if missing.empty? && missing_installation_signals.empty? && !importmap_pin_missing
  puts "Gem package contents verified: #{File.basename(gem_path)}"
else
  warn "Gem package contents verification failed: #{File.basename(gem_path)}"

  unless missing.empty?
    warn "Missing packaged files:"
    missing.each { |path| warn "  - #{path}" }
  end

  missing_installation_signals.each do |path, signals|
    warn "Missing installation docs signals in #{path}:"
    signals.each { |signal| warn "  - #{signal}" }
  end

  if importmap_pin_missing
    warn "Missing TreeView importmap pin in config/importmap.tree_view.rb:"
    warn "  - pin \"tree_view\", to: \"tree_view/index.js\""
  end

  abort "Gem package contents verification failed."
end
