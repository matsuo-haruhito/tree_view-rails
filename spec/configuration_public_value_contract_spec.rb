# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "configuration public value contract" do
  let(:manifest) do
    YAML.safe_load(File.read(File.expand_path("../config/public_api_manifest.yml", __dir__)))
  end

  let(:english_public_api_docs) do
    File.read(File.expand_path("../docs/en/public-api.md", __dir__))
  end

  let(:japanese_public_api_docs) do
    File.read(File.expand_path("../docs/ja/public-api.md", __dir__))
  end

  let(:english_render_log_docs) do
    File.read(File.expand_path("../docs/en/render-log-level.md", __dir__))
  end

  let(:japanese_render_log_docs) do
    File.read(File.expand_path("../docs/ja/render-log-level.md", __dir__))
  end

  it "keeps configuration option keys manifest-backed without adding a value schema section" do
    expect(manifest.fetch("configuration_options").fetch("tree_view_configure")).to eq(%w[initial_state render_log_level])
    expect(manifest).not_to have_key("configuration_option_values")
    expect(manifest.fetch("configuration_options").fetch("tree_view_configure")).to all(be_a(String))
  end

  it "keeps initial_state accepted values guarded by runtime constants and compatibility behavior" do
    expect(TreeView::Configuration::VALID_INITIAL_STATES).to eq(%i[expanded collapsed])

    config = TreeView::Configuration.new(initial_state: "collapsed")
    expect(config.initial_state).to eq(:collapsed)

    expect { TreeView::Configuration.new(initial_state: :invalid) }
      .to raise_error(TreeView::ConfigurationError, /initial_state/)
  end

  it "keeps render_log_level accepted values and nil disable path guarded by runtime constants" do
    expect(TreeView::Configuration::VALID_RENDER_LOG_LEVELS.keys).to eq(%i[debug info warn error fatal unknown])

    config = TreeView::Configuration.new(render_log_level: Logger::ERROR)
    expect(config.render_log_level).to eq(:error)

    config.render_log_level = nil
    expect(config.render_log_level).to be_nil

    expect { TreeView::Configuration.new(render_log_level: :verbose) }
      .to raise_error(TreeView::ConfigurationError, /render_log_level/)
  end

  it "keeps public API docs aligned with the docs/spec value-boundary policy" do
    [english_public_api_docs, japanese_public_api_docs].each do |document|
      expect(document).to include("initial_state")
      expect(document).to include("render_log_level")
      expect(document).to include("config/public_api_manifest.yml")
    end

    expect(english_public_api_docs).to include("The manifest tracks these option names, not their accepted value sets")
    expect(japanese_public_api_docs).to include("manifest が追跡するのはこれらの option 名であり、accepted value set ではありません")
  end

  it "keeps render log docs explicit about accepted values staying in docs and specs" do
    [english_render_log_docs, japanese_render_log_docs].each do |document|
      expect(document).to include("initial_state")
      expect(document).to include("render_log_level")
      expect(document).to include("manifest")
    end

    expect(english_render_log_docs).to include("compatibility specs and docs rather than a separate manifest value schema")
    expect(japanese_render_log_docs).to include("manifest に value schema を増やすのではなく compatibility spec と docs で守ります")
  end
end
