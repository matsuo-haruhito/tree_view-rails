# frozen_string_literal: true

require "spec_helper"
require "action_view"

BreadcrumbHelperSpecNode = Struct.new(:id, :parent_id, :name, keyword_init: true)

RSpec.describe TreeViewBreadcrumbHelper do
  let(:helper_host_class) do
    Class.new do
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::OutputSafetyHelper
      include TreeViewHelper
    end
  end

  let(:helper) { helper_host_class.new }
  let(:root) { BreadcrumbHelperSpecNode.new(id: 1, parent_id: nil, name: "Root") }
  let(:child) { BreadcrumbHelperSpecNode.new(id: 2, parent_id: 1, name: "Child") }
  let(:tree) { TreeView::Tree.new(records: [root, child], parent_id_method: :parent_id) }
  let(:label_builder) { ->(node) { node.name } }
  let(:path_builder) { ->(node) { "/nodes/#{node.id}" } }

  it "merges callable HTML option hooks with built-in breadcrumb attributes" do
    rendered = helper.tree_view_breadcrumb(
      tree,
      child,
      label_builder: label_builder,
      path_builder: path_builder,
      html: ->(node) { {class: "custom-nav", data: {current_node: node.id}} },
      list_html: {class: "custom-list", data: {role: "trail"}},
      item_html: ->(node) { {class: "custom-item", data: {node: node.id}} },
      link_html: ->(node) { {class: "custom-link", data: {node: node.id}, aria: {label: "Open #{node.name}"}} },
      current_html: {class: "custom-current", data: {state: "current"}},
      separator_html: ->(_node) { {class: "custom-separator", data: {kind: "divider"}} }
    )

    expect(rendered).to include('class="tree-view-breadcrumb custom-nav"')
    expect(rendered).to include('aria-label="Breadcrumb"')
    expect(rendered).to include('data-current-node="2"')
    expect(rendered).to include('class="tree-view-breadcrumb__list custom-list"')
    expect(rendered).to include('data-role="trail"')
    expect(rendered).to include('class="tree-view-breadcrumb__item custom-item"')
    expect(rendered).to include('href="/nodes/1"')
    expect(rendered).to include('class="tree-view-breadcrumb__link custom-link"')
    expect(rendered).to include('aria-label="Open Root"')
    expect(rendered).to include('class="tree-view-breadcrumb__separator custom-separator"')
    expect(rendered).to include('aria-hidden="true"')
    expect(rendered).to include('class="tree-view-breadcrumb__current custom-current"')
    expect(rendered).to include('aria-current="page"')
  end

  it "raises a clear error when an HTML option hook returns a non Hash-like value" do
    expect do
      helper.tree_view_breadcrumb(
        tree,
        child,
        label_builder: label_builder,
        html: ->(_node) { "not-options" }
      )
    end.to raise_error(ArgumentError, /html must be a Hash-like object or callable returning one/)
  end
end
