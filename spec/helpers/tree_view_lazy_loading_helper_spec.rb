# frozen_string_literal: true

require "spec_helper"

RSpec.describe "tree_view lazy loading helper" do
  let(:helper_class) do
    Class.new do
      include TreeViewHelper
    end
  end

  let(:helper) { helper_class.new }
  let(:item) { Struct.new(:id).new(42) }
  let(:ui_config) do
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" }
    )
  end

  it "builds a stable children container dom id from the tree node dom id" do
    expect(helper.tree_children_container_dom_id(item, ui: ui_config)).to eq("node_42_children")
  end

  it "builds a stable remote state placeholder dom id from the tree node dom id" do
    expect(helper.tree_remote_state_placeholder_dom_id(item, ui: ui_config)).to eq("node_42_remote_state")
  end

  it "returns placeholder attributes with optional remote state data" do
    expect(helper.tree_remote_state_placeholder_attributes(item, ui: ui_config)).to eq(
      { id: "node_42_remote_state" }
    )

    expect(helper.tree_remote_state_placeholder_attributes(item, state: :loaded, ui: ui_config)).to eq(
      { id: "node_42_remote_state", data: { tree_remote_state: "loaded" } }
    )
  end
end
