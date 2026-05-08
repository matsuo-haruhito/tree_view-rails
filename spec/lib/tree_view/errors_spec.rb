# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TreeView errors" do
  it "exposes a TreeView-specific base error that preserves ArgumentError compatibility" do
    expect(TreeView::Error).to be < ArgumentError
  end

  it "lets host apps rescue duplicate node key failures via TreeView::Error" do
    root = ItemNode.new(id: 1, parent_item_id: nil, name: "root")
    duplicate_root = ItemNode.new(id: 1, parent_item_id: nil, name: "duplicate-root")

    expect do
      TreeView::Tree.new(records: [root, duplicate_root], parent_id_method: :parent_item_id, validate_node_keys: true)
    end.to raise_error(TreeView::DuplicateNodeKeyError, /duplicate node_key detected/)
      .and raise_error(TreeView::Error)
      .and raise_error(ArgumentError)
  end

  it "lets host apps rescue configuration failures via TreeView::Error" do
    expect do
      TreeView::Tree.new(records: [], parent_id_method: :parent_item_id, sorter: :name)
    end.to raise_error(TreeView::ConfigurationError, /sorter must respond to call/)
      .and raise_error(TreeView::Error)
  end

  it "lets host apps rescue render window failures via TreeView::Error" do
    expect do
      TreeView::RenderWindow.new([], offset: -1, limit: 10)
    end.to raise_error(TreeView::InvalidRenderWindowError, /offset/)
      .and raise_error(TreeView::Error)
  end
end
