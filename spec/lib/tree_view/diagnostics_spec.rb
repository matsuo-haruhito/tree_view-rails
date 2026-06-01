# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::Diagnostics do
  def diagnostic_node_class
    @diagnostic_node_class ||= Struct.new(:id, :parent_id, :name, keyword_init: true)
  end

  def diagnostic_node(id:, parent_id:, name:)
    diagnostic_node_class.new(id: id, parent_id: parent_id, name: name)
  end

  def diagnostic_ui_config
    TreeView::UiConfig.new(
      node_dom_id_builder: ->(item_or_id) { "node_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      button_dom_id_builder: ->(item_or_id) { "button_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" },
      show_button_dom_id_builder: ->(item_or_id) { "show_#{item_or_id.respond_to?(:id) ? item_or_id.id : item_or_id}" }
    )
  end

  it "returns a successful result when selected diagnostics pass" do
    root = diagnostic_node(id: 1, parent_id: nil, name: "Root")
    child = diagnostic_node(id: 2, parent_id: 1, name: "Child")
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
    first = diagnostic_node(id: 1, parent_id: nil, name: "First")
    duplicate = diagnostic_node(id: 1, parent_id: nil, name: "Duplicate")
    tree = TreeView::Tree.new(records: [first, duplicate], parent_id_method: :parent_id)

    result = described_class.run(tree: tree, checks: [:node_keys])

    expect(result).not_to be_success
    expect(result.errors.first).to include(check: :node_keys)
    expect(result.errors.first[:message]).to match(/duplicate node_key/)
  end

  it "collects unknown check failures with the supported check list" do
    result = described_class.run(checks: [:not_a_check])

    expect(result).not_to be_success
    expect(result.errors).to contain_exactly(
      include(
        check: :not_a_check,
        error: be_a(TreeView::ConfigurationError),
        message: include(
          "unknown diagnostics check: :not_a_check",
          "supported checks are: node_keys, dom_ids, orphans, cycles"
        )
      )
    )
    expect(result.warnings).to eq([])
  end

  it "collects required object failures across aggregate checks" do
    result = described_class.run(checks: %i[node_keys dom_ids])

    expect(result).not_to be_success
    expect(result.errors).to contain_exactly(
      include(check: :node_keys, message: "node_keys diagnostics require tree: or render_state:"),
      include(check: :dom_ids, message: "dom_ids diagnostics require render_state:")
    )
  end

  it "can raise the first diagnostics failure" do
    first = diagnostic_node(id: 1, parent_id: nil, name: "First")
    duplicate = diagnostic_node(id: 1, parent_id: nil, name: "Duplicate")
    tree = TreeView::Tree.new(records: [first, duplicate], parent_id_method: :parent_id)

    expect do
      described_class.run(tree: tree, checks: [:node_keys], raise_errors: true)
    end.to raise_error(TreeView::DuplicateNodeKeyError, /duplicate node_key/)
  end

  it "raises unknown check failures when raise_errors is enabled" do
    expect do
      described_class.run(checks: [:not_a_check], raise_errors: true)
    end.to raise_error(
      TreeView::ConfigurationError,
      /unknown diagnostics check: :not_a_check; supported checks are: node_keys, dom_ids, orphans, cycles/
    )
  end

  it "reports orphan nodes as warnings without failing the result" do
    root = diagnostic_node(id: 1, parent_id: nil, name: "Root")
    orphan = diagnostic_node(id: 2, parent_id: 99, name: "Orphan")
    tree = TreeView::Tree.new(records: [root, orphan], parent_id_method: :parent_id)

    result = described_class.run(tree: tree, checks: [:orphans])

    expect(result).to be_success
    expect(result.errors).to eq([])
    expect(result.warnings).to contain_exactly(
      include(
        check: :orphans,
        message: "orphan nodes detected: 2",
        details: contain_exactly(include(key: 2, missing_parent_id: 99))
      )
    )
  end

  it "reports missing inputs as diagnostics errors" do
    result = described_class.run(checks: [:dom_ids])

    expect(result).not_to be_success
    expect(result.errors.first[:message]).to match(/dom_ids diagnostics require render_state/)
  end
end
