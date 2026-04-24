require "spec_helper"

RSpec.describe TreeView::UiConfigBuilder do
  it "builds DOM id and path generators" do
    context = double(:context)
    item = Struct.new(:id).new(8)

    config = described_class.new(context: context, node_prefix: "entry").build(
      hide_descendants_path_builder: ->(candidate, depth, scope) { "/entries/#{candidate.id}/hide?depth=#{depth}&scope=#{scope}" },
      show_descendants_path_builder: ->(candidate, depth, scope) { "/entries/#{candidate.id}/show?depth=#{depth}&scope=#{scope}" },
      toggle_all_path_builder: ->(state) { "/entries?state=#{state}" }
    )

    expect(config.node_dom_id(item)).to eq("entry_8")
    expect(config.button_dom_id(item)).to eq("entry_button_box_8")
    expect(config.show_button_dom_id(item)).to eq("entry_show_button_8")
    expect(config.hide_descendants_path(item, 2)).to eq("/entries/8/hide?depth=2&scope=all")
    expect(config.hide_descendants_path(item, 2, scope: "grandchildren")).to eq("/entries/8/hide?depth=2&scope=grandchildren")
    expect(config.show_descendants_path(item, 2)).to eq("/entries/8/show?depth=2&scope=all")
    expect(config.show_descendants_path(item, 2, scope: "children")).to eq("/entries/8/show?depth=2&scope=children")
    expect(config.toggle_all_path(state: :collapsed)).to eq("/entries?state=collapsed")
  end

  it "builds static config without toggle paths" do
    context = double(:context)
    item = Struct.new(:id).new(8)

    config = described_class.new(context: context, node_prefix: "entry").build_static

    expect(config.node_dom_id(item)).to eq("entry_8")
    expect(config.button_dom_id(item)).to eq("entry_button_box_8")
    expect(config.show_button_dom_id(item)).to eq("entry_show_button_8")
    expect(config.static?).to eq(true)
    expect(config.toggle_all_path(state: :collapsed)).to be_nil
  end
end
