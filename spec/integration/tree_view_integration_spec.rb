require "spec_helper"
require "action_view"
require "bigdecimal"
require "fileutils"
require "tmpdir"

RSpec.describe "TreeView integration" do
  IntegrationNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)

  let(:root) { IntegrationNode.new(id: 1, parent_item_id: nil, name: "root") }
  let(:child) { IntegrationNode.new(id: 2, parent_item_id: 1, name: "child") }
  let(:grandchild) { IntegrationNode.new(id: 3, parent_item_id: 2, name: "grandchild") }
  let(:nodes) { [root, child, grandchild] }
  let(:tree) { TreeView::Tree.new(records: nodes, parent_id_method: :parent_item_id) }
  let(:gem_view_path) { File.expand_path("../../app/views", __dir__) }
  let(:host_view_dir) { Dir.mktmpdir("tree_view_host_views") }

  before do
    FileUtils.mkdir_p(File.join(host_view_dir, "projects"))
    File.write(
      File.join(host_view_dir, "projects", "_tree_columns.html.erb"),
      '<td class="project-cell"><%= tree_node_dom_id(item) %>:<%= item.name %></td>'
    )
  end

  after do
    FileUtils.remove_entry(host_view_dir) if Dir.exist?(host_view_dir)
  end

  def build_view(tree_ui:)
    view = ActionView::Base.with_empty_template_cache.with_view_paths([host_view_dir, gem_view_path], {}, nil)
    view.extend(TreeViewHelper)
    view.instance_variable_set(:@tree_ui, tree_ui)
    view
  end

  describe "static host app usage" do
    it "renders tree_view/tree_row from a host partial and exposes helper methods" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      view = build_view(tree_ui: tree_ui)

      rendered = view.render(
        partial: "tree_view/tree_row",
        locals: { item: root, tree: tree, row_partial: "projects/tree_columns", mode: :static }
      )

      expect(view.tree_node_dom_id(root)).to eq("project_1")
      expect(rendered).to include('id="project_1"')
      expect(rendered).to include("project_1:root")
      expect(rendered).to include("tree-toggle__level")
    end

    it "renders root rows through tree_view_rows helper" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('id="project_1"')
      expect(rendered).to include('id="project_2"')
      expect(rendered).to include("project_1:root")
      expect(rendered).to include("project_2:child")
    end

    it "renders row class and data attributes from RenderState builders" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui,
        row_class_builder: ->(item) { ["tree-row", "is-#{item.name}"] },
        row_data_builder: ->(item) { { node_name: item.name, node_id: item.id } }
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('class="tree-row is-root"')
      expect(rendered).to include('class="tree-row is-child"')
      expect(rendered).to include('data-node-name="root"')
      expect(rendered).to include('data-node-name="child"')
      expect(rendered).to include('data-node-id="1"')
      expect(rendered).to include('data-tree-depth="0"')
      expect(rendered).to include('data-tree-depth="1"')
    end

    it "limits initial child rendering with max_initial_depth" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui,
        max_initial_depth: 1
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('id="project_1"')
      expect(rendered).to include('id="project_2"')
      expect(rendered).not_to include('id="project_3"')
      expect(rendered).to include('tree-toggle__hidden-count')
    end

    it "expands nodes listed in expanded_keys" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui,
        initial_state: :collapsed,
        expanded_keys: [tree.node_key_for(root), tree.node_key_for(child)]
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('id="project_1"')
      expect(rendered).to include('id="project_2"')
      expect(rendered).to include('id="project_3"')
    end

    it "does not render descendants when only a hidden descendant is listed in expanded_keys" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui,
        initial_state: :collapsed,
        expanded_keys: [tree.node_key_for(child)]
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('id="project_1"')
      expect(rendered).not_to include('id="project_2"')
      expect(rendered).not_to include('id="project_3"')
    end

    it "respects RenderState initial_state when rendering through tree_view_rows" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      render_state = TreeView::RenderState.new(
        tree: tree,
        root_items: tree.root_items,
        row_partial: "projects/tree_columns",
        ui_config: tree_ui,
        initial_state: :collapsed
      )
      view = build_view(tree_ui: nil)

      rendered = view.tree_view_rows(render_state)

      expect(rendered).to include('id="project_1"')
      expect(rendered).not_to include('id="project_2"')
      expect(rendered).to include('tree-toggle__hidden-count')
    end
  end

  describe "turbo host app usage" do
    it "renders turbo toggle links with the configured path builders" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build(
        hide_descendants_path_builder: ->(item, depth, scope) { "/projects/#{item.id}/hide?depth=#{depth}&scope=#{scope}" },
        show_descendants_path_builder: ->(item, depth, scope) { "/projects/#{item.id}/show?depth=#{depth}&scope=#{scope}" },
        toggle_all_path_builder: ->(state) { "/projects/toggle_all?state=#{state}" }
      )
      view = build_view(tree_ui: tree_ui)

      rendered = view.render(
        partial: "tree_view/tree_row",
        locals: { item: root, tree: tree, row_partial: "projects/tree_columns", mode: :turbo }
      )

      expect(rendered).to include('/projects/1/hide?depth=0&amp;scope=all')
    end

    it "raises a clear error for invalid toggle modes" do
      tree_ui = TreeView::UiConfigBuilder.new(context: Object.new, node_prefix: "project").build_static
      view = build_view(tree_ui: tree_ui)

      expect do
        view.render(
          partial: "tree_view/tree_row",
          locals: { item: root, tree: tree, row_partial: "projects/tree_columns", mode: :statc }
        )
      end.to raise_error(ActionView::Template::Error) { |error|
        expect(error.cause).to be_a(ArgumentError)
        expect(error.cause.message).to match(/must be :static or :turbo/)
      }
    end
  end
end
