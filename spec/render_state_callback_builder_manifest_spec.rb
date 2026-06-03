# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "RenderState callback builder public manifest" do
  MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

  def manifest_callback_builder_keys
    YAML.safe_load_file(MANIFEST_PATH).fetch("render_state_callback_builder_keys")
  end

  it "keeps the flat callback builder key list aligned with RenderState" do
    expected_keys = %w[
      row_class_builder
      row_data_builder
      row_event_payload_builder
      loading_builder
      error_builder
      depth_label_builder
      badge_builder
      icon_builder
      toggle_icon_builder
    ]

    expect(manifest_callback_builder_keys).to eq(expected_keys)

    initializer_keywords = TreeView::RenderState.instance_method(:initialize).parameters
      .select { |kind, _name| kind == :key || kind == :keyreq }
      .map { |_kind, name| name.to_s }

    manifest_callback_builder_keys.each do |key|
      expect(initializer_keywords).to include(key), "expected RenderState initializer to keep #{key}"
      expect(TreeView::RenderState.public_instance_methods).to include(key.to_sym), "expected RenderState##{key} reader to remain public"
    end
  end
end
