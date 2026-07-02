# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Diagnostics manifest compatibility" do
  let(:manifest_path) { File.expand_path("../config/public_api_manifest.yml", __dir__) }

  it "keeps accepted checks aligned with runtime defaults" do
    runtime_checks = TreeView::Diagnostics::DEFAULT_CHECKS.map(&:to_s)
    manifest_checks = YAML.safe_load_file(manifest_path).fetch("diagnostics").fetch("accepted_checks")
    failure_message = [
      "expected config/public_api_manifest.yml diagnostics.accepted_checks",
      "to match TreeView::Diagnostics::DEFAULT_CHECKS",
      "runtime DEFAULT_CHECKS: #{runtime_checks.inspect}",
      "manifest accepted_checks: #{manifest_checks.inspect}"
    ].join("\n")

    expect(manifest_checks).to eq(runtime_checks), failure_message
  end
end
