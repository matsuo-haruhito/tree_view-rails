require "spec_helper"

RSpec.describe "TreeView generated abnormal structure patterns" do
  def pattern_signature(pattern, seed:)
    generated_tree_pattern(pattern, seed: seed).map do |node|
      [node.id, node.parent_id, node.label]
    end
  end

  it "recreates the same pattern from the same seed" do
    expect(pattern_signature(:orphan_cluster, seed: 414)).to eq(pattern_signature(:orphan_cluster, seed: 414))
  end

  it "reports generated orphan clusters through diagnostics warnings" do
    records = generated_tree_pattern(:orphan_cluster, seed: 414)
    tree = TreeView::Tree.new(records: records, parent_id_method: :parent_id)

    result = TreeView::Diagnostics.run(tree: tree, checks: [:orphans])

    expect(result).to be_success
    expect(result.warnings.first).to include(check: :orphans)
    expect(result.warnings.first[:details].size).to eq(2)
  end

  it "surfaces duplicate node keys from a generated duplicate-id pattern" do
    tree = TreeView::Tree.new(
      records: generated_tree_pattern(:duplicate_id, seed: 414),
      parent_id_method: :parent_id
    )

    expect do
      tree.validate_unique_node_keys!
    end.to raise_error(TreeView::DuplicateNodeKeyError, /duplicate node_key/)
  end

  it "treats a generated parent_id type mismatch as an orphan report" do
    tree = TreeView::Tree.new(
      records: generated_tree_pattern(:parent_id_type_mismatch, seed: 414),
      parent_id_method: :parent_id
    )

    expect(tree.orphan_report).to contain_exactly(
      include(key: 2, missing_parent_id: "1")
    )
  end

  it "surfaces generated cycle pairs through cycle diagnostics" do
    records = generated_tree_pattern(:cycle_pair, seed: 414)
    tree = TreeView::Tree.new(records: records, parent_id_method: :parent_id)

    expect(tree.cycle_report.first[:cycle_keys]).to eq(records.map(&:id))
    expect { tree.validate_no_cycles! }.to raise_error(ArgumentError, /cycle detected/)
  end
end
