# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "JavaScript event docs compatibility" do
  PUBLIC_API_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  JAVASCRIPT_EVENT_DOC_PATHS = {
    "English docs" => File.expand_path("../docs/en/js-events.md", __dir__),
    "Japanese docs" => File.expand_path("../docs/ja/js-events.md", __dir__)
  }.freeze

  def public_api_manifest
    @public_api_manifest ||= YAML.safe_load_file(PUBLIC_API_MANIFEST_PATH)
  end

  def public_javascript_manifest
    public_api_manifest.fetch("javascript_package_root")
  end

  def public_javascript_event_names
    public_javascript_manifest.fetch("event_names")
  end

  def public_javascript_event_detail_keys
    public_javascript_manifest.fetch("event_detail_keys")
  end

  def javascript_event_docs
    @javascript_event_docs ||= JAVASCRIPT_EVENT_DOC_PATHS.transform_values { |path| File.read(path) }
  end

  def event_section(source, event_name)
    lines = source.lines
    start_index = lines.index { |line| line.start_with?("### ") && line.include?("`#{event_name}`") }

    return nil unless start_index

    next_heading_offset = lines[(start_index + 1)..].index do |line|
      line.start_with?("### ") || line.start_with?("## ")
    end
    end_index = next_heading_offset ? start_index + 1 + next_heading_offset : lines.length

    lines[start_index...end_index].join
  end

  it "keeps manifest JavaScript event names documented in both event docs" do
    public_javascript_event_names.each do |group_name, events|
      events.each_value do |event_name|
        javascript_event_docs.each do |doc_label, source|
          expect(event_section(source, event_name)).not_to be_nil,
            "expected #{doc_label} to document #{event_name} from the #{group_name} event manifest"
        end
      end
    end
  end

  it "keeps manifest JavaScript event detail keys documented near their events" do
    public_javascript_event_detail_keys.each do |group_name, events|
      events.each do |event_key, detail_keys|
        event_name = public_javascript_event_names.fetch(group_name).fetch(event_key)

        javascript_event_docs.each do |doc_label, source|
          section = event_section(source, event_name)

          expect(section).not_to be_nil,
            "expected #{doc_label} to document #{event_name} before checking detail keys"

          detail_keys.each do |detail_key|
            expect(section).to include("`#{detail_key}`"),
              "expected #{doc_label} to document #{detail_key} near #{event_name}"
          end
        end
      end
    end
  end
end
