require "spec_helper"

RSpec.describe TreeView::UiConfig do
  def build_config(**overrides)
    described_class.new(
      **{
        node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
        button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
        show_button_dom_id_builder: ->(item_or_id) { "show_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" }
      }.merge(overrides)
    )
  end

  it "calls DOM id and path builders" do
    config = build_config(
      hide_descendants_path_builder: ->(item, depth, scope) { "/hide/#{item.id}?depth=#{depth}&scope=#{scope}" },
      show_descendants_path_builder: ->(item, depth, scope) { "/show/#{item.id}?depth=#{depth}&scope=#{scope}" },
      toggle_all_path_builder: ->(state) { "/toggle?state=#{state}" }
    )

    item = Struct.new(:id).new(7)

    expect(config.node_dom_id(item)).to eq("node_7")
    expect(config.button_dom_id(7)).to eq("button_7")
    expect(config.show_button_dom_id(item)).to eq("show_7")
    expect(config.hide_descendants_path(item, 2)).to eq("/hide/7?depth=2&scope=all")
    expect(config.hide_descendants_path(item, 2, scope: "grandchildren")).to eq("/hide/7?depth=2&scope=grandchildren")
    expect(config.show_descendants_path(item, 3)).to eq("/show/7?depth=3&scope=all")
    expect(config.show_descendants_path(item, 3, scope: "children")).to eq("/show/7?depth=3&scope=children")
    expect(config.toggle_all_path(state: :collapsed)).to eq("/toggle?state=collapsed")
  end

  it "permits static configs without path builders" do
    config = build_config

    item = Struct.new(:id).new(7)

    expect(config.node_dom_id(item)).to eq("node_7")
    expect(config.hide_descendants_path(item, 2)).to be_nil
    expect(config.show_descendants_path(item, 3)).to be_nil
    expect(config.toggle_all_path(state: :collapsed)).to be_nil
    expect(config.static?).to eq(true)
  end

  it "raises a clear error when a required builder is not callable" do
    expect do
      build_config(node_dom_id_builder: "node")
    end.to raise_error(ArgumentError, /node_dom_id_builder must respond to call/)
  end

  it "raises a clear error when an optional builder is not callable" do
    expect do
      build_config(hide_descendants_path_builder: "hide")
    end.to raise_error(ArgumentError, /hide_descendants_path_builder must respond to call/)
  end
end
