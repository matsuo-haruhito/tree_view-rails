# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "TreeView controller entries public export" do
  let(:manifest) do
    YAML.safe_load_file(File.expand_path("../config/public_api_manifest.yml", __dir__)).fetch("javascript_package_root")
  end

  let(:entrypoint_source) do
    File.read(File.expand_path("../app/javascript/tree_view/index.js", __dir__))
  end

  it "keeps controller entries aligned with the documented registration order" do
    expect(manifest.fetch("named_exports")).to include("TreeViewControllerEntries")
    expect(entrypoint_source).to include("export const TreeViewControllerEntries = Object.freeze([")

    entries_start = entrypoint_source.index("export const TreeViewControllerEntries")
    register_start = entrypoint_source.index("export function registerTreeViewControllers")
    entries_source = entrypoint_source[entries_start...register_start]

    previous_index = -1

    manifest.fetch("controller_registrations").each do |registration|
      key = registration.fetch("key")
      identifier = registration.fetch("identifier")
      export_name = registration.fetch("export")

      key_index = entries_source.index("key: \"#{key}\"")

      expect(key_index).not_to be_nil
      expect(key_index).to be > previous_index
      expect(entries_source).to include("identifier: TreeViewControllerIdentifiers.#{key}")
      expect(entries_source).to include("controller: #{export_name}")
      expect(entrypoint_source).to include("application.register(\"#{identifier}\", #{export_name})")

      previous_index = key_index
    end
  end
end
