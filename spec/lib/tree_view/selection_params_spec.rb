# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::SelectionParams do
  describe ".parse" do
    it "returns an empty array for nil and empty input" do
      expect(described_class.parse(nil)).to eq([])
      expect(described_class.parse([])).to eq([])
      expect(described_class.parse([nil, ""])).to eq([])
    end

    it "parses JSON selection values" do
      params = [
        '{"key":1,"id":1,"type":"Document"}',
        '{"key":2,"id":2,"type":"Folder"}'
      ]

      expect(described_class.parse(params)).to eq([
        {"key" => 1, "id" => 1, "type" => "Document"},
        {"key" => 2, "id" => 2, "type" => "Folder"}
      ])
    end

    it "accepts a single JSON selection value" do
      expect(described_class.parse('{"key":1,"id":1}')).to eq([
        {"key" => 1, "id" => 1}
      ])
    end

    it "accepts hash-like entries" do
      expect(described_class.parse([{key: 1, id: 1}])).to eq([
        {key: 1, id: 1}
      ])
    end

    it "raises a clear error for invalid JSON" do
      expect do
        described_class.parse(["not-json"])
      end.to raise_error(ArgumentError, /invalid selection params JSON/)
    end

    it "raises a clear error when JSON does not parse to an object" do
      expect do
        described_class.parse(["[1,2]"])
      end.to raise_error(ArgumentError, /must parse to JSON objects/)
    end
  end
end
