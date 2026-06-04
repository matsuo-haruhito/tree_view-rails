# frozen_string_literal: true

require "spec_helper"
require "yaml"

PATH_TREE_BUILDER_PUBLIC_API_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

RSpec.describe "PathTreeBuilder public node shape contract" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(PATH_TREE_BUILDER_PUBLIC_API_MANIFEST_PATH)
  end

  def path_tree_builder_node_shapes
    public_api_manifest.fetch("path_tree_builder_node_shapes")
  end

  def tree_view_constant(constant_path)
    constant_path.split("::").inject(TreeView) do |namespace, constant_name|
      namespace.const_get(constant_name)
    end
  end

  it "keeps manifest-backed PathTreeBuilder node shape fields and predicates aligned" do
    path_tree_builder_node_shapes.each do |shape_name, contract|
      node_class = tree_view_constant(contract.fetch("constant"))

      expect(node_class.members.map(&:to_s)).to eq(contract.fetch("fields")),
        "expected #{shape_name} node fields to match the manifest-backed public contract"

      contract.fetch("predicates").each do |predicate_name|
        expect(node_class.new).to respond_to(predicate_name.to_sym),
          "expected #{contract.fetch("constant")} to expose #{predicate_name}"
      end
    end
  end

  it "keeps representative folder and record node predicate behavior available" do
    folder_node = TreeView::PathTreeBuilder::FolderNode.new(
      key: "folder:guides",
      parent_key: nil,
      label: "guides",
      path: "guides",
      node_type: :folder
    )
    record = Struct.new(:id, :name, keyword_init: true).new(id: 1, name: "Install")
    record_node = TreeView::PathTreeBuilder::RecordNode.new(
      key: "record:1",
      parent_key: "folder:guides",
      label: "install.md",
      path: "guides/install.md",
      record: record,
      node_type: :record
    )

    expect(folder_node.folder_node?).to be(true)
    expect(folder_node.record_node?).to be(false)
    expect(record_node.folder_node?).to be(false)
    expect(record_node.record_node?).to be(true)
    expect(record_node.record).to eq(record)
  end
end
