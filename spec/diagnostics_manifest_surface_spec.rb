# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Diagnostics manifest surface" do
  MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  RUN_INPUT_KEYS = %w[tree render_state].freeze

  def diagnostics_manifest
    YAML.safe_load_file(MANIFEST_PATH).fetch("diagnostics")
  end

  def runtime_run_options
    TreeView::Diagnostics.method(:run).parameters.filter_map do |parameter_type, parameter_name|
      next unless %i[key keyreq].include?(parameter_type)

      parameter_name.to_s
    end - RUN_INPUT_KEYS
  end

  def runtime_result_attributes
    TreeView::Diagnostics::Result.members.map(&:to_s)
  end

  def runtime_result_methods
    TreeView::Diagnostics::Result.instance_methods(false).map(&:to_s).sort
  end

  it "keeps Diagnostics.run public options aligned with the manifest" do
    manifest_options = diagnostics_manifest.fetch("run_options")

    expect(runtime_run_options).to eq(manifest_options), <<~MESSAGE
      expected TreeView::Diagnostics.run public options to match diagnostics.run_options
      runtime: #{runtime_run_options.inspect}
      manifest: #{manifest_options.inspect}
    MESSAGE
  end

  it "keeps Diagnostics::Result surface aligned with the manifest" do
    manifest_surface = diagnostics_manifest.fetch("result_surface")
    manifest_attributes = manifest_surface.fetch("attributes")
    manifest_methods = manifest_surface.fetch("methods").sort

    expect(runtime_result_attributes).to eq(manifest_attributes), <<~MESSAGE
      expected TreeView::Diagnostics::Result attributes to match diagnostics.result_surface.attributes
      runtime: #{runtime_result_attributes.inspect}
      manifest: #{manifest_attributes.inspect}
    MESSAGE

    expect(runtime_result_methods).to eq(manifest_methods), <<~MESSAGE
      expected TreeView::Diagnostics::Result methods to match diagnostics.result_surface.methods
      runtime: #{runtime_result_methods.inspect}
      manifest: #{manifest_methods.inspect}
    MESSAGE
  end
end
