# frozen_string_literal: true

require "spec_helper"

RSpec.describe "TreeView.parse_selection_params public contract" do
  it "skips optional blank entries and accepts JSON object strings" do
    result = TreeView.parse_selection_params([
      nil,
      "",
      '{"id":"document:1","label":"Proposal"}'
    ])

    expect(result).to eq([
      {"id" => "document:1", "label" => "Proposal"}
    ])
  end

  it "accepts non-String hash-like entries without coercing their keys" do
    hash_like_entry = Class.new do
      def to_h
        {"id" => "document:2", "label" => "Hash-like entry"}
      end
    end.new

    expect(TreeView.parse_selection_params([hash_like_entry])).to eq([
      {"id" => "document:2", "label" => "Hash-like entry"}
    ])
  end

  it "raises ArgumentError for malformed JSON entries" do
    expect { TreeView.parse_selection_params(["{"]) }
      .to raise_error(ArgumentError, /invalid selection params JSON/)
  end

  it "raises ArgumentError when JSON entries are not objects" do
    ["[]", '"document:1"', "1"].each do |entry|
      expect { TreeView.parse_selection_params([entry]) }
        .to raise_error(ArgumentError, /must parse to JSON objects/)
    end
  end
end
