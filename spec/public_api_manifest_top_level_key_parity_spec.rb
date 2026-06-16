# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Public API manifest top-level key parity" do
  MANIFEST_STRUCTURE_SPEC_PATH = File.expand_path("public_api_manifest_structure_spec.rb", __dir__)
  MANIFEST_STRUCTURE_SMOKE_PATH = File.expand_path("../script/test_public_api_manifest_structure.mjs", __dir__)

  def ruby_expected_top_level_keys
    source = File.read(MANIFEST_STRUCTURE_SPEC_PATH)
    match = source.match(/PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS = %w\[\n(?<keys>.*?)\n\]\.freeze/m)

    raise "Could not find PUBLIC_API_MANIFEST_TOP_LEVEL_KEYS literal in #{MANIFEST_STRUCTURE_SPEC_PATH}" unless match

    match[:keys].lines.map(&:strip).reject(&:empty?)
  end

  def node_expected_top_level_keys
    source = File.read(MANIFEST_STRUCTURE_SMOKE_PATH)
    match = source.match(/const expectedKeys = \[\n(?<keys>.*?)\n  \]/m)

    raise "Could not find assertTopLevelKeys expectedKeys literal in #{MANIFEST_STRUCTURE_SMOKE_PATH}" unless match

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
