# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_API_VISIBLE_ROWS_METADATA_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

RSpec.describe "VisibleRows row metadata public manifest" do
  def manifest
    @manifest ||= YAML.safe_load(File.read(PUBLIC_API_VISIBLE_ROWS_METADATA_MANIFEST_PATH))
  end

  def visible_rows_metadata
    manifest.fetch("visible_rows_row_metadata")
  end

  it "lists the public row reader and predicate method set" do
    expect(visible_rows_metadata.fetch("fields")).to eq(%w[
      item
      depth
      node_key
      parent_key
      has_children
      expanded
    ])
    expect(visible_rows_metadata.fetch("predicates")).to eq(%w[
      has_children?
      expanded?
    ])
  end

  it "keeps the manifest synchronized with TreeView::VisibleRows::Row" do
    row = TreeView::VisibleRows::Row.new(
      item: :document,
      depth: 2,
      node_key: "documents/1",
      parent_key: "documents",
      has_children: true,
      expanded: true
    )

    visible_rows_metadata.fetch("fields").each do |field|
      expect(row).to respond_to(field)
    end

    visible_rows_metadata.fetch("predicates").each do |predicate|
      expect(row).to respond_to(predicate)
    end

    expect(row.item).to eq(:document)
    expect(row.depth).to eq(2)
    expect(row.node_key).to eq("documents/1")
    expect(row.parent_key).to eq("documents")
    expect(row.has_children).to be(true)
    expect(row.expanded).to be(true)
    expect(row).to be_has_children
    expect(row).to be_expanded
  end

  it "keeps predicate helpers boolean-oriented" do
    row = TreeView::VisibleRows::Row.new(
      item: :leaf,
      depth: 0,
      node_key: "leaf",
      parent_key: nil,
      has_children: false,
      expanded: false
    )

    expect(row).not_to be_has_children
    expect(row).not_to be_expanded
  end

  it "keeps render scale docs aligned with the manifest-backed boundary" do
    en_doc = File.read(File.expand_path("../docs/en/render-scale.md", __dir__))
    ja_doc = File.read(File.expand_path("../docs/ja/render-scale.md", __dir__))

    %w[item depth node_key parent_key has_children expanded has_children? expanded?].each do |signal|
      expect(en_doc).to include(signal)
      expect(ja_doc).to include(signal)
    end

    expect(en_doc).to include("VisibleRows::Row")
    expect(en_doc).to include("RenderWindow")
    expect(ja_doc).to include("VisibleRows::Row")
    expect(ja_doc).to include("RenderWindow")
  end
end
