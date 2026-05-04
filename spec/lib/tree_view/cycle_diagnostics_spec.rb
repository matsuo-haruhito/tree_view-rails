require "spec_helper"

RSpec.describe "TreeView cycle diagnostics" do
  CycleDiagnosticsNode = Struct.new(:id, :parent_id, :name, keyword_init: true)

  it "returns an empty cycle report when no cycles exist" do
    root = CycleDiagnosticsNode.new(id: 1, parent_id: nil, name: "root")
    child = CycleDiagnosticsNode.new(id: 2, parent_id: 1, name: "child")
    tree = TreeView::Tree.new(records: [root, child], parent_id_method: :parent_id)

    expect(tree.cycle_report).to eq([])
    expect(tree.validate_no_cycles!).to eq(true)
  end

  it "reports cycle keys when a parent path cycles" do
    first = CycleDiagnosticsNode.new(id: 1, parent_id: 2, name: "first")
    second = CycleDiagnosticsNode.new(id: 2, parent_id: 1, name: "second")
    tree = TreeView::Tree.new(records: [first, second], parent_id_method: :parent_id)

    report = tree.cycle_report.first

    expect(report[:cycle_keys]).to eq([1, 2])
    expect(report[:cycle_items]).to eq([first, second])
  end

  it "raises a summary error when cycles exist" do
    first = CycleDiagnosticsNode.new(id: 1, parent_id: 2, name: "first")
    second = CycleDiagnosticsNode.new(id: 2, parent_id: 1, name: "second")
    tree = TreeView::Tree.new(records: [first, second], parent_id_method: :parent_id)

    expect { tree.validate_no_cycles! }.to raise_error(ArgumentError, /cycle detected in tree/)
  end

  it "is records-mode only" do
    root = CycleDiagnosticsNode.new(id: 1, parent_id: nil, name: "root")
    tree = TreeView::Tree.new(roots: [root], children_resolver: ->(_item) { [] })

    expect { tree.cycle_report }.to raise_error(ArgumentError, /records mode/)
  end
end
