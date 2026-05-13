# frozen_string_literal: true

require "spec_helper"

PathTreeBuilderDocument = Struct.new(:id, :source_relative_path, :title, keyword_init: true)

RSpec.describe TreeView::PathTreeBuilder do
  it "builds folder nodes and record nodes from slash-separated paths" do
    documents = [
      PathTreeBuilderDocument.new(id: 1, source_relative_path: "guides/setup/install.md", title: "Install"),
      PathTreeBuilderDocument.new(id: 2, source_relative_path: "guides/setup/configure.md", title: "Configure")
    ]

    builder = described_class.new(
      records: documents,
      path_resolver: ->(document) { document.source_relative_path },
      label_resolver: ->(document) { document.title },
      id_resolver: ->(document) { "document:#{document.id}" },
      sort: {folders_first: true}
    )

    guides = builder.nodes.find { |node| node.key == "folder:guides" }
    setup = builder.nodes.find { |node| node.key == "folder:guides/setup" }
    install = builder.nodes.find { |node| node.key == "document:1" }

    expect(guides.label).to eq("guides")
    expect(guides.parent_key).to be_nil
    expect(setup.label).to eq("setup")
    expect(setup.parent_key).to eq("folder:guides")
    expect(install.label).to eq("Install")
    expect(install.parent_key).to eq("folder:guides/setup")
    expect(install.record).to eq(documents.first)
  end

  it "deduplicates shared folder nodes" do
    documents = [
      PathTreeBuilderDocument.new(id: 1, source_relative_path: "guides/setup/install.md", title: "Install"),
      PathTreeBuilderDocument.new(id: 2, source_relative_path: "guides/setup/configure.md", title: "Configure")
    ]

    builder = described_class.new(
      records: documents,
      path_resolver: ->(document) { document.source_relative_path }
    )

    expect(builder.nodes.count { |node| node.key == "folder:guides" }).to eq(1)
    expect(builder.nodes.count { |node| node.key == "folder:guides/setup" }).to eq(1)
  end

  it "exposes a renderable tree with folders before records when requested" do
    documents = [
      PathTreeBuilderDocument.new(id: 1, source_relative_path: "zeta.md", title: "Zeta"),
      PathTreeBuilderDocument.new(id: 2, source_relative_path: "guides/setup.md", title: "Setup")
    ]

    builder = described_class.new(
      records: documents,
      path_resolver: ->(document) { document.source_relative_path },
      label_resolver: ->(document) { document.title },
      sort: {folders_first: true}
    )

    expect(builder.root_items.map(&:label)).to eq(["guides", "Zeta"])
    expect(builder.children_for(builder.root_items.first).map(&:label)).to eq(["Setup"])
  end

  it "accepts array paths and places single-segment records at the root" do
    documents = [
      PathTreeBuilderDocument.new(id: 1, source_relative_path: nil, title: "Root document"),
      PathTreeBuilderDocument.new(id: 2, source_relative_path: nil, title: "Nested document")
    ]

    builder = described_class.new(
      records: documents,
      path_resolver: ->(document) { document.id == 1 ? ["root.md"] : ["docs", "nested.md"] },
      label_resolver: ->(document) { document.title },
      sort: {folders_first: true}
    )

    expect(builder.root_items.map(&:label)).to eq(["docs", "Root document"])
    expect(builder.children_for(builder.root_items.first).map(&:label)).to eq(["Nested document"])
  end

  it "raises a configuration error for invalid resolvers" do
    expect do
      described_class.new(records: [], path_resolver: :source_relative_path)
    end.to raise_error(TreeView::ConfigurationError, /path_resolver must respond to call/)
  end
end
