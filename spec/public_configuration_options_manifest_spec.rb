# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public configuration option manifest" do
  let(:manifest_path) { File.expand_path("../config/public_api_manifest.yml", __dir__) }
  let(:configuration_option_keys) do
    YAML.safe_load_file(manifest_path).fetch("configuration_options").fetch("tree_view_configure")
  end

  it "keeps TreeView.configure option keys machine-readable" do
    expect(configuration_option_keys).to eq(%w[initial_state render_log_level])
  end

  it "keeps manifest-backed configuration options available on TreeView::Configuration" do
    configuration = TreeView::Configuration.new

    configuration_option_keys.each do |option_key|
      expect(configuration).to respond_to(option_key.to_sym),
        "expected TreeView::Configuration##{option_key} to remain public"
      expect(configuration).to respond_to(:"#{option_key}="),
        "expected TreeView::Configuration##{option_key}= to remain public"
    end
  end

  it "keeps representative TreeView.configure option behavior available" do
    configuration = TreeView::Configuration.new

    expect(configuration.initial_state).to eq(:expanded)
    expect(configuration.render_log_level).to eq(:warn)

    configuration.initial_state = :collapsed
    configuration.render_log_level = :info

    expect(configuration.initial_state).to eq(:collapsed)
    expect(configuration.render_log_level).to eq(:info)
  end
end
