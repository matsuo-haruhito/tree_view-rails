# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public diagnostics Result surface" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:manifest) { YAML.safe_load_file(File.join(repo_root, "config/public_api_manifest.yml")) }
  let(:result_surface) { manifest.fetch("diagnostics").fetch("result_surface") }
  let(:result_surface_names) { result_surface.fetch("attributes") + result_surface.fetch("methods") }
  let(:result) { TreeView::Diagnostics::Result.new(checks: [], errors: [], warnings: []) }
  let(:diagnostics_docs) do
    [
      ["docs/en/tree-diagnostics.md", File.read(File.join(repo_root, "docs/en/tree-diagnostics.md"))],
      ["docs/ja/tree-diagnostics.md", File.read(File.join(repo_root, "docs/ja/tree-diagnostics.md"))]
    ]
  end

  it "keeps manifest-backed Result readers and helpers available" do
    result_surface_names.each do |surface_name|
      expect(result).to respond_to(surface_name), "expected Result##{surface_name} to remain public"
    end
  end

  it "keeps diagnostics docs aligned with the manifest-backed Result surface" do
    result_surface_names.each do |surface_name|
      diagnostics_docs.each do |relative_path, document|
        expect(document).to include("`#{surface_name}`"),
          "expected #{relative_path} to document Result##{surface_name}"
      end
    end
  end
end
