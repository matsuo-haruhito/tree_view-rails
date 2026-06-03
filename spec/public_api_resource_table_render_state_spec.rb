# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "ResourceTableRenderState public call contract" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__)).fetch("resource_table_render_state_call")
  end

  let(:call_parameters) do
    TreeView::ResourceTableRenderState.method(:call).parameters
  end

  def keyword_parameter_names(kind)
    call_parameters.each_with_object([]) do |parameter, names|
      parameter_kind, name = parameter
      names << name.to_s if parameter_kind == kind
    end
  end

  it "keeps required and optional call keywords aligned with the manifest" do
    expect(keyword_parameter_names(:keyreq)).to eq(manifest.fetch("required_keywords"))
    expect(keyword_parameter_names(:key)).to eq(manifest.fetch("optional_keywords"))
    expect(keyword_parameter_names(:keyrest)).to eq(["render_options"])
  end

  it "documents render options as a RenderState pass-through instead of duplicating that surface" do
    expect(manifest.fetch("render_options_contract")).to eq("render_state_pass_through")
    expect(manifest.fetch("optional_keywords")).not_to include("initial_expansion")
    expect(manifest.fetch("optional_keywords")).not_to include("selection")
    expect(manifest.fetch("optional_keywords")).not_to include("lazy_loading")
  end
end
