# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "NodePresenter builder names public contract" do
  it "keeps builder names aligned with the public API manifest" do
    manifest_path = File.expand_path("../config/public_api_manifest.yml", __dir__)
    manifest_names = YAML.safe_load_file(manifest_path).fetch("node_presenter_builder_names")

    expect(manifest_names).to eq(TreeView::NodePresenter::BUILDER_NAMES.map(&:to_s)),
      "expected NodePresenter builder names to stay aligned with the manifest-backed public contract"
  end
end
