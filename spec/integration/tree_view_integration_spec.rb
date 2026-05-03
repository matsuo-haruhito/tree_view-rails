require "spec_helper"

RSpec.describe "TreeView integration" do
  TestNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)

  let(:root) { TestNode.new(id: 1, parent_item_id: nil, name: "root") }
  let(:child) { TestNode.new(id: 2, parent_item_id: 1, name: "child") }
  let(:nodes) { [root, child] }

  describe "static host app usage" do
    it "builds static UiConfig and render state without toggle paths" do
      builder = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project")
      ui = builder.build_static
      tree = TreeView::Tree.new(records: nodes, parent_id_method: :parent_item_id)

      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: ui
      )

      expect(render_state.effective_initial_state).to eq(:expanded)
      expect(ui.node_dom_id(root)).to eq("project_1")
      expect(ui.hide_descendants_path(root, 0)).to be_nil
      expect(ui.show_descendants_path(root, 0)).to be_nil
      expect(ui.toggle_all_path(state: :collapsed)).to be_nil
    end
  end

  describe "turbo host app usage" do
    it "builds full UiConfig and exposes toggle paths" do
      builder = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project")
      ui = builder.build(
        hide_descendants_path_builder: ->(item, depth, scope) { "/projects/#{item.id}/hide?depth=#{depth}&scope=#{scope}" },
        show_descendants_path_builder: ->(item, depth, scope) { "/projects/#{item.id}/show?depth=#{depth}&scope=#{scope}" },
        toggle_all_path_builder: ->(state) { "/projects/toggle_all?state=#{state}" }
      )

      expect(ui.hide_descendants_path(root, 2, scope: "all")).to eq("/projects/1/hide?depth=2&scope=all")
      expect(ui.show_descendants_path(root, 2, scope: "children")).to eq("/projects/1/show?depth=2&scope=children")
      expect(ui.toggle_all_path(state: :expanded)).to eq("/projects/toggle_all?state=expanded")
    end
  end
end
