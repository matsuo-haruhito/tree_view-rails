# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "JavaScript remote-state value public contract" do
  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__))
  end

  def javascript_manifest
    public_api_manifest.fetch("javascript_package_root")
  end

  def javascript_entrypoint_source
    @javascript_entrypoint_source ||= File.read(File.expand_path("../app/javascript/tree_view/index.js", __dir__))
  end

  it "keeps remote-state values listed as a package-root export" do
    expect(javascript_manifest.fetch("named_exports")).to include("TreeViewRemoteStateValues")
    expect(javascript_manifest.fetch("remote_state_values")).to eq({
      "loading" => "loading",
      "loaded" => "loaded",
      "error" => "error"
    })
  end

  it "keeps the source export aligned with the manifest values" do
    expect(javascript_entrypoint_source).to include("export const TreeViewRemoteStateValues = Object.freeze({")

    javascript_manifest.fetch("remote_state_values").each do |key, value|
      expect(javascript_entrypoint_source).to include("#{key}: \"#{value}\""),
        "expected TreeViewRemoteStateValues.#{key} to stay mapped to #{value}"
    end

    expect(javascript_entrypoint_source).not_to include("retry: \"retry\""),
      "retry is an action/event, not a remote-state row value"
  end
end
