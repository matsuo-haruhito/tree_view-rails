# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::Diagnostics do
  DiagnosticNode = Struct.new(:id, :parent_id, :name, keyword_init: true)

  def diagnostic_ui_config
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" }
    )
  end

  it "returns a successful result when selected diagnostics pass" do
    root = DiagnosticNode.new(id: 1, parent_id: nil, name: "Root")
    child = DiagnosticNode.new(id: 2, parent_id: 1, name: "Child")
    tree = TreeView::Tree.new(records: [root, child], parent_id_method: :parent_id)
    render_state = TreeView::RenderState.new(
      tree: tree,
      root_items: tree.root_items,
      row_partial: "items/tree_columns",
      ui_config: diagnostic_ui_config
    )

    result = described_class.run(render_state: render_state, checks: %i[node_keys dom_ids cycles])

    expect(result).to be_success
    expect(result.errors).to eq([])
    expect(result.warnings).to eq([])
  end

  it "collects failures without raising by default" do
    first = DiagnosticNode.new(id: 1, parent_id: nil, name: "First")
    duplicate = DiagnosticNode.new(id: 1, parent_id: nil, name: "Duplicate")
    tree = TreeView::Tree.new(records: [first, duplicate], parent_id_method: :parent_id)

    result = described_class.run(tree: tree, checks: [:node_keys])

    expect(result).not_to be_success
    expect(result.errors.first).to include(check: :node_keys)
    expect(result.errors.first[:message]).to match(/duplicate node_key/)
  end

  it "can raise the first diagnostics failure" do
    first = DiagnosticNode.new(id: 1, parent_id: nil, name: "First")
    duplicate = DiagnosticNode.new(id: 1, parent_id: nil, name: "Duplicate")
    tree = TreeView::Tree.new(records: [first, duplicate], parent_id_method: :parent_id)

    expect do
      described_class.run(tree: tree, checks: [:node_keys], raise_errors: true)
    end.to raise_error(TreeView::DuplicateNodeKeyError, /duplicate node_key/)
  end

  it "reports orphan nodes as warnings" do
    root = DiagnosticNode.new(id: 1, parent_id: nil, name: "Root")
    orphan = DiagnosticNode.new(id: 2, parent_id: 99, name: "Orphan")
    tree = TreeView::Tree.new(records: [root, orphan], parent_id_method: :parent_id)

    result = described_class.run(tree: tree, checks: [:orphans])

    expect(result).to be_success
    expect(result.warnings.first).to include(check: :orphans)
    expect(result.warnings.first[:message]).to match(/orphan nodes detected/)
  end

  it "reports missing inputs as diagnostics errors" do
    result = described_class.run(checks: [:dom_ids])

    expect(result).not_to be_success
    expect(result.errors.first[:message]).to match(/dom_ids diagnostics require render_state/)
  end
end
