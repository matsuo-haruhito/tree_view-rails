require "spec_helper"
require "action_view"

BreadcrumbNode = Struct.new(:id, :parent_item_id, :name, keyword_init: true)

RSpec.describe TreeViewBreadcrumbHelper do
  def build_helper
    view = ActionView::Base.empty
    view.extend(TreeViewBreadcrumbHelper)
    view
  end

  def build_tree(records)
    TreeView::Tree.new(records: records, parent_id_method: :parent_item_id)
  end

  it "renders a breadcrumb from root to current node" do
    root = BreadcrumbNode.new(id: 1, parent_item_id: nil, name: "Root")
    child = BreadcrumbNode.new(id: 2, parent_item_id: 1, name: "Child")
    grandchild = BreadcrumbNode.new(id: 3, parent_item_id: 2, name: "Grandchild")
    tree = build_tree([root, child, grandchild])
    helper = build_helper

    rendered = helper.tree_view_breadcrumb(
      tree,
      grandchild,
      label_builder: ->(item) { item.name },
      path_builder: ->(item) { "/nodes/#{item.id}" }
    )

    expect(rendered).to include('class="tree-view-breadcrumb"')
    expect(rendered).to include('href="/nodes/1"')
    expect(rendered).to include('href="/nodes/2"')
    expect(rendered).to include('class="tree-view-breadcrumb__current"')
    expect(rendered).to include('aria-current="page"')
    expect(rendered).to include("Grandchild")
  end

  it "renders plain labels when path_builder is omitted" do
    root = BreadcrumbNode.new(id: 1, parent_item_id: nil, name: "Root")
    child = BreadcrumbNode.new(id: 2, parent_item_id: 1, name: "Child")
    tree = build_tree([root, child])
    helper = build_helper

    rendered = helper.tree_view_breadcrumb(
      tree,
      child,
      label_builder: ->(item) { item.name }
    )

    expect(rendered).to include("Root")
    expect(rendered).to include("Child")
    expect(rendered).not_to include("href=")
  end

  it "allows custom classes and separator" do
    root = BreadcrumbNode.new(id: 1, parent_item_id: nil, name: "Root")
    child = BreadcrumbNode.new(id: 2, parent_item_id: 1, name: "Child")
    tree = build_tree([root, child])
    helper = build_helper

    rendered = helper.tree_view_breadcrumb(
      tree,
      child,
      label_builder: ->(item) { item.name },
      path_builder: ->(item) { "/nodes/#{item.id}" },
      separator: "/",
      nav_class: "breadcrumb",
      list_class: "breadcrumb-list",
      item_class: "breadcrumb-item",
      link_class: "breadcrumb-link",
      current_class: "breadcrumb-current",
      separator_class: "breadcrumb-separator",
      aria_label: "Node path"
    )

    expect(rendered).to include('class="breadcrumb"')
    expect(rendered).to include('class="breadcrumb-list"')
    expect(rendered).to include('class="breadcrumb-item"')
    expect(rendered).to include('class="breadcrumb-link"')
    expect(rendered).to include('class="breadcrumb-current"')
    expect(rendered).to include('class="breadcrumb-separator"')
    expect(rendered).to include('aria-label="Node path"')
  end

  it "rejects invalid builders" do
    node = BreadcrumbNode.new(id: 1, parent_item_id: nil, name: "Root")
    tree = build_tree([node])
    helper = build_helper

    expect do
      helper.tree_view_breadcrumb(tree, node, label_builder: "name")
    end.to raise_error(ArgumentError, /label_builder must respond to call/)

    expect do
      helper.tree_view_breadcrumb(tree, node, label_builder: ->(item) { item.name }, path_builder: "path")
    end.to raise_error(ArgumentError, /path_builder must respond to call/)
  end

  it "uses Tree path errors for unsupported modes" do
    root = BreadcrumbNode.new(id: 1, parent_item_id: nil, name: "Root")
    tree = TreeView::Tree.new(roots: [root], children_resolver: ->(_item) { [] })
    helper = build_helper

    expect do
      helper.tree_view_breadcrumb(tree, root, label_builder: ->(item) { item.name })
    end.to raise_error(ArgumentError, /only supported in records mode/)
  end
end
