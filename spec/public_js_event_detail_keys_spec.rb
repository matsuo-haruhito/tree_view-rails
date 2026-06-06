# frozen_string_literal: true

require "spec_helper"
require "yaml"

PUBLIC_JS_EVENT_DETAIL_KEYS_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
PUBLIC_JS_EVENT_DETAIL_KEYS_ENTRYPOINT_PATH = File.expand_path("../app/javascript/tree_view/index.js", __dir__)

RSpec.describe "Public JavaScript event detail keys" do
  def javascript_manifest
    @javascript_manifest ||= YAML.safe_load_file(PUBLIC_JS_EVENT_DETAIL_KEYS_MANIFEST_PATH).fetch("javascript_package_root")
  end

  def event_detail_keys
    javascript_manifest.fetch("event_detail_keys")
  end

  def event_names
    javascript_manifest.fetch("event_names")
  end

  def entrypoint_source
    @entrypoint_source ||= File.read(PUBLIC_JS_EVENT_DETAIL_KEYS_ENTRYPOINT_PATH)
  end

  def camelize_manifest_key(value)
    value.to_s.gsub(/_([a-z])/) { Regexp.last_match(1).upcase }
  end

  it "keeps TreeViewEventDetailKeys listed as a package-root export" do
    expect(javascript_manifest.fetch("named_exports")).to include("TreeViewEventDetailKeys")
    expect(entrypoint_source).to include("export const TreeViewEventDetailKeys = Object.freeze({")
  end

  it "keeps the exported detail-key groups aligned with documented event groups" do
    event_detail_keys.each do |group_name, events|
      export_group = camelize_manifest_key(group_name)

      expect(event_names).to have_key(group_name), "expected #{group_name} detail keys to have documented event names"
      expect(entrypoint_source).to include("#{export_group}: Object.freeze({"),
        "expected TreeViewEventDetailKeys to keep the #{export_group} group"

      events.each_key do |event_key|
        export_event = camelize_manifest_key(event_key)

        expect(event_names.fetch(group_name)).to have_key(event_key),
          "expected #{group_name}.#{event_key} detail keys to have a documented event name"
        expect(entrypoint_source).to include("#{export_event}: Object.freeze(["),
          "expected TreeViewEventDetailKeys.#{export_group}.#{export_event} to remain exported"
      end
    end
  end

  it "keeps manifest detail key strings available through TreeViewEventDetailKeys" do
    event_detail_keys.each do |group_name, events|
      export_group = camelize_manifest_key(group_name)

      events.each do |event_key, detail_keys|
        export_event = camelize_manifest_key(event_key)
        expected_list = detail_keys.map { |detail_key| %("#{detail_key}") }.join(", ")
        expected_export = "#{export_event}: Object.freeze([#{expected_list}])"

        expect(entrypoint_source).to include(expected_export),
          "expected TreeViewEventDetailKeys.#{export_group}.#{export_event} to match manifest detail keys"
      end
    end
  end
end
