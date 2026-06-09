# frozen_string_literal: true

require "spec_helper"
require "tree_view/diagnostics"
require "yaml"

RSpec.describe "Diagnostics public manifest" do
  def manifest
    @manifest ||= YAML.safe_load(File.read(File.expand_path("../config/public_api_manifest.yml", __dir__)))
  end

  it "keeps run option keys synchronized with the Diagnostics.run keyword surface" do
    diagnostics_manifest = manifest.fetch("diagnostics")
    keyword_parameters = TreeView::Diagnostics.method(:run).parameters.select do |kind, _name|
      %i[key keyreq].include?(kind)
    end
    optional_run_options = keyword_parameters.filter_map do |kind, name|
      name.to_s if kind == :key
    end

    expect(optional_run_options).to eq(%w[checks raise_errors])
    expect(diagnostics_manifest.fetch("run_options")).to eq(optional_run_options)
  end

  it "keeps accepted check names separate from run option keys" do
    diagnostics_manifest = manifest.fetch("diagnostics")

    expect(diagnostics_manifest.fetch("accepted_checks")).to eq(%w[node_keys dom_ids orphans cycles])
    expect(diagnostics_manifest.fetch("run_options")).to eq(%w[checks raise_errors])
    expect(diagnostics_manifest.fetch("accepted_checks")).not_to include("raise_errors")
  end
end
