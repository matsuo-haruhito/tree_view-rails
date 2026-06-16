# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Public API manifest top-level key parity" do
  let(:manifest_structure_spec_path) { File.expand_path("public_api_manifest_structure_spec.rb", __dir__) }
  let(:manifest_structure_smoke_path) { File.expand_path("../script/test_public_api_manifest_structure.mjs", __dir__) }

  def ruby_expected_top_level_keys
    source = File.read(manifest_structure_spec_path)
    match = source.match(/PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS = %w\[\n(?<keys>.*?)\n\]\.freeze/m)

    raise "Could not find PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS literal in #{manifest_structure_spec_path}" unless match

    match[:keys].lines.map(&:strip).reject(&:empty?)
  end

  def node_expected_top_level_keys
    source = File.read(manifest_structure_smoke_path)
    match = source.match(/const expectedKeys = \[\n(?<keys>.*?)\n  \]/m)

    raise "Could not find assertTopLevelKeys expectedKeys literal in #{manifest_structure_smoke_path}" unless match

    match[:keys].scan(/"([^"]+)"/).flatten
  end

  it "keeps Ruby and Node manifest top-level section guards synchronized" do
    ruby_keys = ruby_expected_top_level_keys
    node_keys = node_expected_top_level_keys

    expect(node_keys).to eq(ruby_keys), <<~MESSAGE
      expected script/test_public_api_manifest_structure.mjs assertTopLevelKeys expectedKeys
      to match spec/public_api_manifest_structure_spec.rb PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS.
      missing from Node smoke: #{(ruby_keys - node_keys).inspect}
      extra in Node smoke: #{(node_keys - ruby_keys).inspect}
    MESSAGE
  end
end
