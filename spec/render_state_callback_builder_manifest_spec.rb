# frozen_string_literal: true

require "spec_helper"
require "yaml"

RENDER_STATE_CALLBACK_BUILDER_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
RENDER_STATE_CALLBACK_BUILDER_KEYS = %w[
  row_class_builder
  row_data_builder
  row_event_payload_builder
  loading_builder
  error_builder
  depth_label_builder
  badge_builder
  icon_builder
  toggle_icon_builder
].freeze

RSpec.describe "RenderState callback builder public manifest" do
  def manifest_callback_builder_keys
    YAML.safe_load_file(RENDER_STATE_CALLBACK_BUILDER_MANIFEST_PATH).fetch("render_state_callback_builder_keys")
  end

  it "keeps the flat callback builder key list aligned with RenderState" do
    expect(manifest_callback_builder_keys).to eq(RENDER_STATE_CALLBACK_BUILDER_KEYS)

    builders = manifest_callback_builder_keys.to_h { |key| [key.to_sym, ->(*) {}] }
    state = TreeView::RenderState.new(
      tree: instance_double(TreeView::Tree),
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: instance_double(TreeView::UiConfig),
      **builders
    )

    manifest_callback_builder_keys.each do |key|
      expect(state.public_send(key)).to eq(builders.fetch(key.to_sym)), "expected RenderState##{key} to keep the provided builder"
    end
  end
end
