#!/usr/bin/env ruby
# frozen_string_literal: true

require "rubygems/package"

REQUIRED_PACKAGED_PATHS = %w[
  app/helpers/tree_view_helper.rb
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
  docs/en/release.md
].freeze

root = File.expand_path("..", __dir__)
gem_path = ARGV.first || Dir[File.join(root, "tree_view-*.gem")].max_by { |path| File.mtime(path) }

abort "No built gem found. Run `gem build tree_view.gemspec` first." unless gem_path

files = Gem::Package.new(gem_path).spec.files
missing = REQUIRED_PACKAGED_PATHS.reject { |path| files.include?(path) }

if missing.empty?
  puts "Gem package contents verified: #{File.basename(gem_path)}"
else
  warn "Gem package contents verification failed: #{File.basename(gem_path)}"
  warn "Missing packaged files:"
  missing.each { |path| warn "  - #{path}" }
  abort "Gem package contents verification failed."
end
