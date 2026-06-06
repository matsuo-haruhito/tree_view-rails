# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_CONFIGURATION_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

RSpec.describe "Public configuration option compatibility" do
  def configuration_option_keys
    YAML.safe_load_file(PUBLIC_CONFIGURATION_MANIFEST_PATH).fetch("configuration_options").fetch("tree_view_configure")
  end

  after do
    TreeView.reset_configuration!
  end

  it "keeps TreeView.configure options aligned with the public manifest" do
    representative_values = {
      "initial_state" => :collapsed,
      "render_log_level" => :info
    }

    expect(configuration_option_keys).to eq(representative_values.keys)

    configuration_option_keys.each do |option_name|
      expect(TreeView.configuration).to respond_to(option_name),
        "expected TreeView.configuration.#{option_name} to remain readable"
      expect(TreeView.configuration).to respond_to("#{option_name}="),
        "expected TreeView.configuration.#{option_name}= to remain writable"
    end

    TreeView.configure do |config|
      configuration_option_keys.each do |option_name|
        config.public_send("#{option_name}=", representative_values.fetch(option_name))
      end
    end

    configuration_option_keys.each do |option_name|
      expect(TreeView.configuration.public_send(option_name)).to eq(representative_values.fetch(option_name))
    end
  end
end
