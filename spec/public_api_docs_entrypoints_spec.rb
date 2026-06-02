# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public API documentation entrypoints" do
  repository_root = File.expand_path("..", __dir__)
  manifest_path = File.join(repository_root, "config/public_api_manifest.yml")
  docs_root = File.join(repository_root, "docs")

  def manifest
    @manifest ||= YAML.safe_load_file(self.class.metadata.fetch(:manifest_path))
  end

  def read_doc(relative_path)
    File.read(File.join(self.class.metadata.fetch(:docs_root), relative_path))
  end

  before do |example|
    example.metadata[:manifest_path] = manifest_path
    example.metadata[:docs_root] = docs_root
  end

  it "keeps public API and JavaScript event docs reachable from the language docs indexes" do
    root_index = read_doc("README.md")
    english_index = read_doc("en/README.md")
    japanese_index = read_doc("ja/README.md")

    expect(root_index).to include("en/public-api.md")
    expect(root_index).to include("ja/public-api.md")

    expect(english_index).to include("public-api.md")
    expect(english_index).to include("js-events.md")

    expect(japanese_index).to include("public-api.md")
    expect(japanese_index).to include("js-events.md")
  end

  it "keeps manifest-backed Ruby surfaces documented in both public API entrypoints" do
    public_api_docs = {
      english: read_doc("en/public-api.md"),
      japanese: read_doc("ja/public-api.md")
    }

    public_api_docs.each do |language, doc|
      manifest.fetch("module_methods").each do |method_name|
        expect(doc).to include("TreeView.#{method_name}"),
          "expected #{language} public API docs to mention TreeView.#{method_name}"
      end

      manifest.fetch("public_constants").each do |constant_name|
        expect(doc).to include("TreeView::#{constant_name}"),
          "expected #{language} public API docs to mention TreeView::#{constant_name}"
      end

      manifest.fetch("helper_methods").each do |helper_name|
        expect(doc).to include(helper_name),
          "expected #{language} public API docs to mention #{helper_name}"
      end
    end
  end

  it "keeps manifest-backed JavaScript event names documented in both event entrypoints" do
    event_docs = {
      english: read_doc("en/js-events.md"),
      japanese: read_doc("ja/js-events.md")
    }
    event_names = manifest.fetch("javascript_package_root").fetch("event_names").values.flat_map(&:values)

    event_docs.each do |language, doc|
      event_names.each do |event_name|
        expect(doc).to include(event_name),
          "expected #{language} JavaScript event docs to mention #{event_name}"
      end
    end
  end
end
