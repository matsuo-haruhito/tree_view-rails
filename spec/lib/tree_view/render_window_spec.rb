# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::RenderWindow do
  let(:rows) { (1..10).to_a }

  it "returns rows for the requested offset and limit" do
    window = described_class.new(rows, offset: 2, limit: 3)

    expect(window.to_a).to eq([3, 4, 5])
    expect(window.total_count).to eq(10)
    expect(window.start_index).to eq(2)
    expect(window.end_index).to eq(5)
    expect(window.previous_offset).to eq(0)
    expect(window.next_offset).to eq(5)
  end

  it "reports previous and next availability" do
    first = described_class.new(rows, offset: 0, limit: 4)
    middle = described_class.new(rows, offset: 4, limit: 4)
    last = described_class.new(rows, offset: 8, limit: 4)

    expect(first).not_to be_previous
    expect(first).to be_next
    expect(middle).to be_previous
    expect(middle).to be_next
    expect(last).to be_previous
    expect(last).not_to be_next
  end

  it "handles offsets beyond the visible rows" do
    window = described_class.new(rows, offset: 20, limit: 5)

    expect(window).to be_empty
    expect(window.to_a).to eq([])
    expect(window.total_count).to eq(10)
    expect(window.start_index).to eq(10)
    expect(window.end_index).to eq(0)
    expect(window.next_offset).to be_nil
    expect(window.previous_offset).to eq(15)
  end

  it "rejects invalid offsets and limits" do
    expect { described_class.new(rows, offset: -1, limit: 5) }.to raise_error(ArgumentError, /offset/)
    expect { described_class.new(rows, offset: 0, limit: 0) }.to raise_error(ArgumentError, /limit/)
  end
end
