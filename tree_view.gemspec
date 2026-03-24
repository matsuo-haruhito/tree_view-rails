# frozen_string_literal: true

require_relative "lib/tree_view/version"

Gem::Specification.new do |spec|
  spec.name = "tree_view"
  spec.version = TreeView::VERSION
  spec.authors = ["TurboStream-TreeViewTest contributors"]
  spec.email = ["noreply@example.com"]

  spec.summary = "Tree rendering primitives for Rails applications"
  spec.description = "TreeView extracts tree traversal, render state, and Rails integration points from the sample app toward a reusable gem."
  spec.homepage = "https://example.com/tree_view"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    Dir[
      "app/assets/**/*",
      "app/javascript/tree_view/**/*",
      "lib/**/*",
      "tree_view.gemspec",
      "README.md",
      "LICENSE*"
    ]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
end
