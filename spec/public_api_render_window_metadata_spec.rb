# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "RenderWindow public metadata manifest" do
  MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  WINDOWED_RENDERING_DOCS = %w[
    docs/en/windowed-rendering.md
    docs/ja/windowed-rendering.md
  ].freeze
  EXPECTED_METADATA_METHODS = %w[
    rows
    offset
    limit
    total_count
    before_count
    after_count
    start_index
    end_index
    previous?
    next?
    previous_offset
    next_offset
    empty?
  ].freeze

  def manifest
    @manifest ||= YAML.safe_load(File.read(MANIFEST_PATH))
  end

  def metadata_methods
    manifest.fetch("render_window_metadata")
  end

  it "tracks the documented RenderWindow metadata method set" do
    expect(metadata_methods).to eq(EXPECTED_METADATA_METHODS)
  end

  it "keeps every manifest metadata method available on RenderWindow" do
    expect(TreeView::RenderWindow.public_instance_methods).to include(*metadata_methods.map(&:to_sym))
  end

  it "keeps English and Japanese metadata tables synchronized with the manifest" do
    WINDOWED_RENDERING_DOCS.each do |path|
      doc = File.read(File.expand_path("../#{path}", __dir__))

      metadata_methods.each do |method_name|
        expect(doc).to include("| `#{method_name}` |"), "expected #{path} to document #{method_name}"
      end
    end
  end
end
