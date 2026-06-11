# frozen_string_literal: true

require "spec_helper"
require "yaml"

NODE_PRESENTER_PUBLIC_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)

RSpec.describe "NodePresenter public manifest" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(NODE_PRESENTER_PUBLIC_MANIFEST_PATH)
  end

  it "keeps documented builder names aligned with NodePresenter" do
    manifest_names = public_api_manifest.fetch("node_presenter_builder_names")

    expect(manifest_names).to eq(TreeView::NodePresenter::BUILDER_NAMES.map(&:to_s)),
      "expected NodePresenter builder names to stay aligned with the manifest-backed public contract"
  end
end
