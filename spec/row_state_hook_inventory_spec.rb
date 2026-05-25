# frozen_string_literal: true

require "spec_helper"

RSpec.describe "row state hook inventory" do
  let(:stylesheet_source) { File.read(File.expand_path("../app/assets/stylesheets/tree_view.scss", __dir__)) }
  let(:default_mock_source) { File.read(File.expand_path("../docs/mockups/default-tree.html", __dir__)) }
  let(:interaction_mock_source) { File.read(File.expand_path("../docs/mockups/interaction-states.html", __dir__)) }
  let(:english_doc_source) { File.read(File.expand_path("../docs/en/accessibility-semantics.md", __dir__)) }
  let(:japanese_doc_source) { File.read(File.expand_path("../docs/ja/accessibility-semantics.md", __dir__)) }

  let(:mock_sources) { [default_mock_source, interaction_mock_source].join("\n") }
  let(:documented_row_state_hooks) do
    [
      ".is-selected",
      ".is-collapsed",
      ".is-loading",
      ".is-error",
      ".is-drop-target"
    ]
  end

  it "keeps the documented representative row state hooks in the shipped stylesheet" do
    documented_row_state_hooks.each do |hook|
      expect(stylesheet_source).to include(hook)
    end
  end

  it "keeps the same representative row state hooks visible in the static mockups" do
    documented_row_state_hooks.each do |hook|
      expect(mock_sources).to include(hook.delete_prefix("."))
    end
  end

  it "documents the same representative row state hooks in both accessibility guides" do
    documented_row_state_hooks.each do |hook|
      expect(english_doc_source).to include(hook)
      expect(japanese_doc_source).to include(hook)
    end
  end

  it "keeps current-row semantics separate from class-based row state hooks" do
    expect(stylesheet_source).to include('[aria-current="page"]')
    expect(english_doc_source).to include('`aria-current="page"`')
    expect(japanese_doc_source).to include('`aria-current="page"`')
  end
end
